# frozen_string_literal: true

require 'optparse'

options = {}

OptionParser.new do |opts|
  opts.on('-a') do
    options[:all] = true
  end

  opts.on('-r') do
    options[:reverse] = true
  end
end.parse!

flags = options[:all] ? File::FNM_DOTMATCH : 0
files = Dir.glob('*', flags)
files.reverse! if options[:reverse]

COLUMNS = 3

def calculate_rows(files, columns)
  files.length.ceildiv(columns)
end

rows = calculate_rows(files, COLUMNS)

def calculate_column_width(files)
  max_length = files.map(&:length).max || 0
  max_length + 2
end

column_width = calculate_column_width(files)

rows.times do |row|
  COLUMNS.times do |column|
    index = row + rows * column
    print files[index].ljust(column_width) if files[index]
  end

  puts
end