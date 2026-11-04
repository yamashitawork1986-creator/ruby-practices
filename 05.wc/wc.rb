# frozen_string_literal: true

require 'optparse'

def count_text(text)
  line_count = text.count("\n")
  word_count = text.split.length
  byte_count = text.bytesize

  [line_count, word_count, byte_count]
end

def select_counts(counts, options)
  results = []
  results << counts[0] if options[:lines]
  results << counts[1] if options[:words]
  results << counts[2] if options[:bytes]
  results
end

options = {}

OptionParser.new do |opts|
  opts.on('-l') { options[:lines] = true }
  opts.on('-w') { options[:words] = true }
  opts.on('-c') { options[:bytes] = true }
end.parse!

if options.empty?
  options[:lines] = true
  options[:words] = true
  options[:bytes] = true
end

total_lines = 0
total_words = 0
total_bytes = 0

if ARGV.empty?
  text = $stdin.read
  results = select_counts(count_text(text), options)

  puts results.map { |count| format('%7d', count) }.join(' ')
end

ARGV.each do |filename|
  text = File.read(filename)
  line_count, word_count, byte_count = count_text(text)

  total_lines += line_count
  total_words += word_count
  total_bytes += byte_count

  results = select_counts([line_count, word_count, byte_count], options)
  puts "#{results.map { |count| format('%7d', count) }.join(' ')} #{filename}"
end

total_results = select_counts([total_lines, total_words, total_bytes], options)

puts "#{total_results.map { |count| format('%7d', count) }.join(' ')} total" if ARGV.length > 1
