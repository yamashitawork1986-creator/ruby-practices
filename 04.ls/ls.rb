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

def format_permissions(stat)
  file_type = stat.directory? ? 'd' : '-'

  owner_permission = ''
  owner_permission += permission_char(stat.mode, 0o400, 'r')
  owner_permission += permission_char(stat.mode, 0o200, 'w')
  owner_permission += permission_char(stat.mode, 0o100, 'x')

  group_permission = ''
  group_permission += permission_char(stat.mode, 0o040, 'r')
  group_permission += permission_char(stat.mode, 0o020, 'w')
  group_permission += permission_char(stat.mode, 0o010, 'x')

  other_permission = ''
  other_permission += permission_char(stat.mode, 0o004, 'r')
  other_permission += permission_char(stat.mode, 0o002, 'w')
  other_permission += permission_char(stat.mode, 0o001, 'x')

  file_type + owner_permission + group_permission + other_permission
end

column_width = calculate_column_width(files)

if options[:long]
  total = files.sum { |file| File.stat(file).blocks }
  puts "total #{total}"

  size_width = files.map { |file| File.stat(file).size.to_s.length }.max

  files.each do |file|
    stat = File.stat(file)
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
