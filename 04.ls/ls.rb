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
  file_infos = files.map do |file|
    stat = File.lstat(file)

    {
      file: file,
      permission: format_permissions(stat),
      nlink: stat.nlink,
      owner: Etc.getpwuid(stat.uid).name,
      group: Etc.getgrgid(stat.gid).name,
      size: stat.size,
      mtime: stat.mtime,
      blocks: stat.blocks
    }
  end

  total = file_infos.sum { |file_info| file_info[:blocks] }
  puts "total #{total}"

  nlink_width = file_infos.map { |file_info| file_info[:nlink].to_s.length }.max
  owner_width = file_infos.map { |file_info| file_info[:owner].length }.max
  group_width = file_infos.map { |file_info| file_info[:group].length }.max
  size_width = file_infos.map { |file_info| file_info[:size].to_s.length }.max

  file_infos.each do |file_info|
    file = file_info[:file]
    permission = file_info[:permission]
    owner = file_info[:owner]
    group = file_info[:group]
    nlink = file_info[:nlink].to_s.rjust(nlink_width)
    size = file_info[:size].to_s.rjust(size_width)
    mtime = file_info[:mtime].strftime('%b %e %H:%M')

    puts "#{permission} #{nlink} #{owner.ljust(owner_width)} #{group.ljust(group_width)} #{size} #{mtime} #{file}"
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
