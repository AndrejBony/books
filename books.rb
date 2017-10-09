#!/usr/bin/env ruby
require 'csv'
require 'optparse'

BOOKS_FILE = File.expand_path("../books.csv", __FILE__)
books = []
authors = []
books_authors = []
languages = []
publishers = []
keywords = ["====== books ======", "====== authors ======","====== books_authors ======","====== languages ======","====== publishers ======"]

def parse_csv(csv_file, k, b, a, b_a, l, p)
	x = 0
	CSV.foreach(csv_file, encoding: "UTF-8") do |col|
		if k.include?(col[0]) 
			x +=1
			next
		end
	
		case x
		when 1 then
			b.push(col)
		when 2 then
			a.push(col)
		when 3 then
			b_a.push(col)
		when 4 then
			l.push(col)
		when 5 then
			p.push(col)
		else
		end
	end
	return b, a, b_a, l, p
end

def arguments(options) 	
	optparse = OptionParser.new do |opts|
  		opts.on('-a', '--author AUTHOR', "Name of author") do |a|
			options[:author] = a
  		end
	
		opts.on('-l', '--language LANGUAGE', "Language of book") do |l|
			options[:language] = l
  		end

		opts.on('-p', '--publisher PUBLISHER', "Publisher of book") do |p|
			options[:publisher] = p
  		end
	end
	optparse.parse!
	return options
end

def add_arguments(array, var, opt)
	array.each do |row|
		if row.last.eql? opt
			var[row.first] = opt
			break
		end
	end
	return var
end

parse_csv(BOOKS_FILE, keywords, books, authors, books_authors, languages, publishers)
options = {}
arguments(options)

if !options[:author].nil? || !options[:author].to_s.empty?
	author = Hash.new
	add_arguments(authors, author, options[:author])
end

if !options[:language].nil? || !options[:language].to_s.empty?
	language = Hash.new
	add_arguments(languages, language, options[:language])
end

if !options[:publisher].nil? || !options[:publisher].to_s.empty?
	publisher = Hash.new
	add_arguments(publishers, publisher, options[:publisher])
end


ids_of_books = Hash.new{|hsh,key| hsh[key] = [] }
books_authors.each do |row|
	if author.keys.first.to_s == row[1]
		ids_of_books[row[2]]
	end
end

found_books = []
books.each do |row|
	if ids_of_books.include? (row[0])
		found_books.push(row)
	end
end

books_authors.each do |row|
	ids_of_books.each do |key, value|
		if key == row[2]
			ids_of_books[key] << row[1]
		end		
	end
end

puts "Found books = #{found_books}"
puts "id of books = #{ids_of_books}"
puts "Author = #{author}"
puts "Language = #{language}"
puts "Publisher = #{publisher}"

