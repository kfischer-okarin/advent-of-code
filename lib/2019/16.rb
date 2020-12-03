require_relative 'common'

module Task16
  class Pattern
    def initialize(length, base: nil)
      @length = length
      @base = base || [0, 1, 0, -1]
    end

    def for_index(index)
      pattern = repeated_base(index + 1)
      result = pattern * ((length / pattern.size) + 1)
      result[1..length]
    end

    def positive_indexes(result_index)
      Enumerator.new do |y|
        start = result_index
        loop do
          (start..(start + result_index)).each do |k|
            y << k
          end
          start += (result_index + 1) * 4
        end
      end
    end

    def negative_indexes(result_index)
      Enumerator.new do |y|
        start = ((result_index + 1) * 3) - 1
        loop do
          (start..(start + result_index)).each do |k|
            y << k
          end
          start += (result_index + 1) * 4
        end
      end
    end

    private

    attr_reader :base, :length

    def repeated_base(repetitions)
      [].tap do |result|
        base.each { |k| result.concat([k] * repetitions) }
      end
    end
  end

  class FFT
    def initialize(input, pattern: nil)
      @value = input
      @pattern = Pattern.new(value.size, base: pattern)
    end

    def calculate_phases(count)
      count.times { calculate_next }
    end

    def first_eight
      value[0..7].join('')
    end

    private

    attr_reader :pattern, :value

    def calculate_next
      result = Array.new(value.size)
      value.size.times do |index|
        calc_result = sum_indexes(pattern.positive_indexes(index)) - sum_indexes(pattern.negative_indexes(index))
        result[index] = calc_result.abs % 10
      end
      @value = result
    end

    def sum_indexes(indexes)
      result = 0
      indexes.each do |i|
        break if i > value.size - 1
        result += value[i]
      end
      result
    end

    def calc_cross(arr_a, arr_b)
      arr_a.zip(arr_b).map { |a, b| a * b }.sum
    end
  end

  module_function

  def calc_back_half(data)
    # Back half of signal is just sum of all remaining elements mod 10
    new_data = Array.new(data.size)
    new_data[data.size - 1] = data[data.size - 1]
    (0..(data.size - 2)).reverse_each do |i|
      new_data[i] = (new_data[i + 1] + data[i]) % 10
    end
    new_data
  end

  def task2(data)
    skip = data[0..6].join('').to_i

    # Skipped digits is greater than half of the length so calculating the back half is enough
    relevant_data = data[skip..-1]
    100.times do |k|
      relevant_data = calc_back_half(relevant_data)
    end
    relevant_data[0..7].join('').to_i
  end


  if $PROGRAM_NAME == __FILE__
    data = read_input_lines('16')[0].chars.map(&:to_i)
    fft = FFT.new(data)
    fft.calculate_phases(100)

    puts "1) After 100 phases: #{fft.first_eight}"

    result_2 = Task16::task2((data * 10000))
    puts "2) 10000 times repeated After 100 phases: #{result_2}"
  end
end
