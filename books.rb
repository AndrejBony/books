#!/usr/bin/env ruby
require 'csv'
require 'optparse'

BOOKS_FILE = File.expand_path("../books.csv", __FILE__)
books = []
authors = []
books_authors = []
languages = []
publishers = []
# f = CSV.read(BOOKS_FILE, encoding: "UTF-8")

def parse_csv(b, a, b_a, l, p)
  keys = ["books", "authors", "books_authors", "languages", "publishers"]
  x = 0
  CSV.foreach(BOOKS_FILE, encoding: "UTF-8") do |col|
    if "====== " + keys[x].to_s + " ======" == col[0]
      x += 1
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
    if row[1].eql? opt
      var[row.first] = opt
      break
    end
  end
  return var
end

def specify_array(arr, var, num)
  arr.delete_if { |row| row[num] != var.keys.first }
  return arr
end

parse_csv(books, authors, books_authors, languages, publishers)
options = {}
arguments(options)

if !options[:author].nil? || !options[:author].to_s.empty?
  author = {}
  add_arguments(authors, author, options[:author])
end

if !options[:language].nil? || !options[:language].to_s.empty?
  language = {}
  add_arguments(languages, language, options[:language])
end

if !options[:publisher].nil? || !options[:publisher].to_s.empty?
  publisher = {}
  add_arguments(publishers, publisher, options[:publisher])
end

ids_of_books = Hash.new { |hsh, key| hsh[key] = [] }
books_authors.each do |row|
  if author.keys.first == row[1]
    ids_of_books[row[2]]
  end
end

found_books = []
books.each do |row|
  ids_of_books.each do |key, _value|
    if key == row[0]
      found_books.push(row)
    end
  end
end
found_books.sort!

if !language.nil? || !language.to_s.empty?
  specify_array(found_books, language, 2)
end

if !publisher.nil? || !publisher.to_s.empty?
  specify_array(found_books, publisher, 3)
end

books_authors.each do |row|
  ids_of_books.each do |key, _value|
    if key == row[2]
      ids_of_books[key] << row[1]
    end
  end
end

found_authors = Hash.new { |hsh, key| hsh[key] = [] }
ids_of_books.each do |key, value|
  value.each do |v|
    authors.each do |row|
      if v == row[0]
        found_authors[key] << row[1]
      end
    end
  end
end

output = ""
found_books.each do |row|
  found_authors.each do |key, value|
    if key == row[0]
      value.each do |v|
        output << v + ", "
      end
      output = output[0...-2]
      output << " (" + row[4].to_s + "): "
      output << row[1].to_s + "\n"
    end
  end
end

puts output
