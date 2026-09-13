# frozen_string_literal: true

require 'optparse'
options = {}
OptionParser.new do |opts|
  opts.on('-a') do
    options[:all] = true
  end
end.parse!

if options[:all]
  files = Dir.glob('*', File::FNM_DOTMATCH)
  files << '..'
else
  files = Dir.glob('*')
end
files.sort!

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
