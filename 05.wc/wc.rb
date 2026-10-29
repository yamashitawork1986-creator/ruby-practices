# frozen_string_literal: true

require 'optparse'

options = {}

OptionParser.new do |opts|
  opts.on('-l') { options[:lines] = true }
  opts.on('-w') { options[:words] = true }
  opts.on('-c') { options[:bytes] = true }
end.parse!

total_lines = 0
total_words = 0
total_bytes = 0

if ARGV.empty?
  text = $stdin.read

  line_count = text.count("\n")
  word_count = text.split.length
  byte_count = text.bytesize

  results = []
  results << line_count if options[:lines]
  results << word_count if options[:words]
  results << byte_count if options[:bytes]

  if results.empty?
    results << line_count
    results << word_count
    results << byte_count
  end

  puts results.join(' ')
end

ARGV.each do |filename|
  text = File.read(filename)
  line_count = text.count("\n")
  total_lines += line_count

  word_count = text.split.length
  total_words += word_count

  byte_count = text.bytesize
  total_bytes += byte_count

  results = []

  results << line_count if options[:lines]

  results << word_count if options[:words]

  results << byte_count if options[:bytes]

  if results.empty?
    results << line_count
    results << word_count
    results << byte_count
  end

  puts "#{results.join(' ')} #{filename}"
end

total_results = []

total_results << total_lines if options[:lines]

total_results << total_words if options[:words]

total_results << total_bytes if options[:bytes]

if total_results.empty?
  total_results << total_lines
  total_results << total_words
  total_results << total_bytes
end

puts "#{total_results.join(' ')} total" if ARGV.length > 1
