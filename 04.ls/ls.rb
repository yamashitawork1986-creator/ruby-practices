# frozen_string_literal: true

files = Dir.glob('*').sort
columns = 3

def calculate_rows(files, columns)
  (files.length.to_f / columns).ceil
end

rows = calculate_rows(files, columns)

def calculate_column_width(files)
  max_length = files.map(&:length).max
  max_length + 2
end

column_width = calculate_column_width(files)

rows.times do |row|
  columns.times do |column|
    index = row + rows * column
    print files[index].ljust(column_width) if files[index]
  end

  puts
end
