# frozen_string_literal: true

def input_filename(source_filename)
  source_filename.gsub('.rb', '-input.txt')
end

def read_input(source_filename)
  File.read input_filename(source_filename)
end

def read_input_lines(source_filename)
  File.open(input_filename(source_filename)) do |f|
    f.readlines.map(&:strip)
  end
end
