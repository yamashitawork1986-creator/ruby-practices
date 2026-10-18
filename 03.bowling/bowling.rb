#!/usr/bin/env ruby
# frozen_string_literal: true

score = ARGV[0]
scores = score.split(',')

shots = []

scores.each do |s|
  shots << if s == 'X'
             10
           else
             s.to_i
           end
end

frames = []
index = 0

9.times do
  if shots[index] == 10
    frames << [10]
    index += 1
  else
    frames << [shots[index], shots[index + 1]]
    index += 2
  end
end

frames << shots[index..]

point = 0

frames.each_with_index do |frame, index|
  point += if index == 9
             frame.sum
           elsif frame[0] == 10
             if frames[index + 1].length >= 2
               10 + frames[index + 1][0] + frames[index + 1][1]
             else
               10 + frames[index + 1][0] + frames[index + 2][0]
             end

           elsif frame.sum == 10
             frame.sum + frames[index + 1][0]
           else
             frame.sum
           end
end

puts point
