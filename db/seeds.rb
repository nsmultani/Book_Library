require 'httparty'
require 'csv'

Review.destroy_all
BookSubject.destroy_all
BookAuthor.destroy_all
User.destroy_all
Book.destroy_all
Author.destroy_all
Publisher.destroy_all
Subject.destroy_all

csv_data = <<~CSV
  name,description,difficulty_level
  Fiction,Literary and genre fiction,Intermediate
  Science Fiction,Future and space exploration themes,Intermediate
  Fantasy,Magic and mythical worlds,Beginner
  Mystery,Crime and detective stories,Intermediate
  Romance,Love and relationship stories,Beginner
  Thriller,Suspense and action-packed stories,Advanced
  Biography,Life stories of real people,Intermediate
  History,Historical events and periods,Advanced
  Science,Scientific concepts and discoveries,Expert
  Philosophy,Philosophical thoughts and ideas,Expert
  Young Adult,Stories for teenage readers,Beginner
  Children,Books for young children,Beginner
  Poetry,Collection of poems,Intermediate
  Self-Help,Personal development and improvement,Beginner
  Cookbook,Recipes and cooking instructions,Beginner
CSV

CSV.parse(csv_data, headers: true) do |row|
  Subject.create!(
    name: row['name'],
    description: row['description'],
    difficulty_level: row['difficulty_level']
  )
end


class OpenLibraryService
  include HTTParty
  base_uri 'https://openlibrary.org'

  def self.search_books(query, limit = 20)
    response = get("/search.json", {
      query: { 
        q: query, 
        limit: limit,
        fields: 'key,title,author_name,author_key,first_publish_year,isbn,number_of_pages_median,publisher,subject,language,cover_i'
      }
    })
    
    return [] unless response.success?
    response.parsed_response['docs'] || []
  end

  def self.get_author_details(author_key)
    response = get("/authors/#{author_key}.json")
    return {} unless response.success?
    response.parsed_response
  end
end

search_terms = [
  'fiction bestseller', 'science fiction classic', 'fantasy adventure',
  'mystery detective', 'romance novel', 'biography famous',
  'history world war', 'philosophy ethics', 'young adult dystopia',
  'children picture book'
]

all_books_data = []
search_terms.each do |term|
  puts "Searching for: #{term}"
  books = OpenLibraryService.search_books(term, 8)
  all_books_data.concat(books)
  sleep(1)
end


publishers_data = all_books_data.flat_map { |book| book['publisher'] || [] }.uniq.compact
publishers_data.first(25).each do |publisher_name|
  next if publisher_name.blank?
  
  Publisher.find_or_create_by(name: publisher_name) do |publisher|
    publisher.founded_year = rand(1800..2020).to_s
  end
end


authors_data = {}
all_books_data.each do |book_data|
  next unless book_data['author_key']
  
  book_data['author_key'].each_with_index do |author_key, index|
    next if authors_data[author_key]
    
    author_name = book_data['author_name'] ? book_data['author_name'][index] : "Unknown Author"
    authors_data[author_key] = author_name
  end
end

authors_data.each do |author_key, author_name|
  next if Author.exists?(openlibrary_key: author_key)
  
  author_details = OpenLibraryService.get_author_details(author_key)
  
  Author.create!(
    name: author_name,
    bio: author_details['bio'].is_a?(String) ? author_details['bio'] : author_details.dig('bio', 'value'),
    birth_date: author_details['birth_date'],
    death_date: author_details['death_date'],
    photo_url: author_details['photos'] ? "https://covers.openlibrary.org/a/id/#{author_details['photos'].first}-M.jpg" : nil,
    openlibrary_key: author_key
  )
  
  sleep(0.5)
end


created_books = []
all_books_data.first(60).each do |book_data|
  next if book_data['title'].blank?
  
  publisher_name = book_data['publisher']&.first
  publisher = Publisher.find_by(name: publisher_name) || Publisher.first
  
  isbn_10 = book_data['isbn']&.find { |isbn| isbn.length == 10 }
  isbn_13 = book_data['isbn']&.find { |isbn| isbn.length == 13 }
  
  book = Book.create!(
    title: book_data['title'],
    isbn_10: isbn_10,
    isbn_13: isbn_13,
    description: "A #{book_data['subject']&.first || 'fascinating'} book that explores #{book_data['title'].downcase}. This engaging read offers insights and entertainment for readers interested in this subject.",
    number_of_pages: book_data['number_of_pages_median'] || rand(150..500),
    publish_date: book_data['first_publish_year']&.to_s || rand(1980..2024).to_s,
    cover_small_url: book_data['cover_i'] ? "https://covers.openlibrary.org/b/id/#{book_data['cover_i']}-S.jpg" : nil,
    cover_medium_url: book_data['cover_i'] ? "https://covers.openlibrary.org/b/id/#{book_data['cover_i']}-M.jpg" : nil,
    cover_large_url: book_data['cover_i'] ? "https://covers.openlibrary.org/b/id/#{book_data['cover_i']}-L.jpg" : nil,
    language: book_data['language']&.first || 'eng',
    publisher: publisher
  )
  
  if book_data['author_key']
    book_data['author_key'].each do |author_key|
      author = Author.find_by(openlibrary_key: author_key)
      if author
        begin
          BookAuthor.find_or_create_by(book: book, author: author)
        rescue ActiveRecord::RecordInvalid
        end
      end
    end
  end
  
  if book_data['subject']
    book_data['subject'].first(3).each do |subject_name|
      subject = Subject.where("name LIKE ?", "%#{subject_name}%").first || Subject.all.sample
      if subject
        begin
          BookSubject.find_or_create_by(book: book, subject: subject)
        rescue ActiveRecord::RecordInvalid
        end
      end
    end
  else
    subjects = Subject.all.sample(rand(1..3))
    subjects.each do |subject|
      begin
        BookSubject.find_or_create_by(book: book, subject: subject)
      rescue ActiveRecord::RecordInvalid
      end
    end
  end
  
  created_books << book
end

25.times do
  User.create!(
    name: Faker::Name.name,
    email: Faker::Internet.unique.email,
    favorite_genre: Subject.all.sample.name
  )
end

users = User.all
books = Book.all

80.times do
  Review.create!(
    rating: rand(1..5),
    content: Faker::Lorem.paragraph(sentence_count: rand(2..6)),
    book: books.sample,
    user: users.sample
  )
end

