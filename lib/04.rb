range = 145852..616942

def non_decreasing_digits(number_string)
  (0..4).all? { |k| number_string[k] <= number_string[k + 1] }
end


def two_adjacent_digits_are_same(number_string)
  (0..4).any? { |k| number_string[k] == number_string[k + 1] }
end

fitting_passwords1 = range.select { |pw|
  number_string = pw.to_s
  non_decreasing_digits(number_string) && two_adjacent_digits_are_same(number_string)
}

def only_two_adjacent_digits_are_same(number_string)
  (0..4).any? { |k|
    (number_string[k] == number_string[k + 1]) &&
    (k == 0 || number_string[k - 1] != number_string[k]) &&
    (k == 4 || number_string[k + 1] != number_string[k + 2])
  }
end

fitting_passwords2 = range.select { |pw|
  number_string = pw.to_s
  non_decreasing_digits(number_string) && only_two_adjacent_digits_are_same(number_string)
}

p "1) Number of valid passwords: #{fitting_passwords1.size}"
p "2) Number of valid passwords: #{fitting_passwords2.size}"
