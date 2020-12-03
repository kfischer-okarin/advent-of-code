# frozen_string_literal: true

def read_input_lines(filename)
  input_filename = filename.gsub('.rb', '-input.txt')
  File.open(input_filename) do |f|
    f.readlines.map(&:strip)
  end
end
