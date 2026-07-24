# frozen_string_literal: true

require 'date'
require 'optparse'

today = Date.today
year = today.year
month = today.month

OptionParser.new do |opts|
  opts.on('-m MONTH', Integer) do |value|
    month = value
  end

  opts.on('-y YEAR', Integer) do |value|
    year = value
  end
end.parse!

puts "#{Date::MONTHNAMES[month]} #{year}"
puts 'Su Mo Tu We Th Fr Sa'

first_day = Date.new(year, month, 1)

first_day.wday.times do
  print '   '
end

last_day = Date.new(year, month, -1).day
(1..last_day).each do |day|
  print format('%2d ', day)

  date = Date.new(year, month, day)
  puts if date.wday == 6
end

puts
