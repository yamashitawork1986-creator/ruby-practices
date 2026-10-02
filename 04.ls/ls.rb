# frozen_string_literal: true

require 'optparse'
require 'etc'

options = {}

OptionParser.new do |opts|
  opts.on('-a') do
    options[:all] = true
  end

  opts.on('-r') do
    options[:reverse] = true
  end

  opts.on('-l') do
    options[:long] = true
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

def permission_char(mode, mask, char)
  mode & mask != 0 ? char : '-'
end

def file_type_char(stat)
  file_types = {
    'file' => '-',
    'directory' => 'd',
    'link' => 'l',
    'characterSpecial' => 'c',
    'blockSpecial' => 'b',
    'fifo' => 'p',
    'socket' => 's'
  }
  file_types.fetch(stat.ftype, '?')
end

def format_permissions(stat)
  file_type = file_type_char(stat)

  permissions = ''
  mask = 0o400
  ('rwx' * 3).each_char do |char|
    permissions += permission_char(stat.mode, mask, char)
    mask >>= 1
  end
  file_type + permissions
end

column_width = calculate_column_width(files)

if options[:long]
  total = files.sum { |file| File.lstat(file).blocks }
  puts "total #{total}"

  size_width = files.map { |file| File.lstat(file).size.to_s.length }.max
  files.each do |file|
    stat = File.lstat(file)
    permission = format_permissions(stat)
    owner = Etc.getpwuid(stat.uid).name
    group = Etc.getgrgid(stat.gid).name
    mtime = stat.mtime.strftime('%b %e %H:%M')
    puts "#{permission} #{stat.nlink} #{owner} #{group} #{stat.size.to_s.rjust(size_width)} #{mtime} #{file}"
  end
else
  rows.times do |row|
    COLUMNS.times do |column|
      index = row + rows * column
      print files[index].ljust(column_width) if files[index]
    end

    puts
  end
end
