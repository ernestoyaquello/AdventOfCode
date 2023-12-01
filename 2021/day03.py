import input

PROBLEM_NUMBER = 3

def execute(is_part_two):
    numbers = input.read_lines(problem_number = PROBLEM_NUMBER) # They are actually strings, but whatever
    return calculate_power_consumption(numbers) if not is_part_two else calculate_life_support_rating(numbers)

def calculate_power_consumption(numbers):
    ones_per_position = [sum([int(number[char_position]) for number in numbers]) for char_position in range(len(numbers[0]))]
    gamma_rate = ''.join([('1' if ones > (len(numbers) / 2) else '0') for ones in ones_per_position])
    epsilon_rate = ''.join([('1' if digit == '0' else '0') for digit in gamma_rate])
    return int(gamma_rate, 2) * int(epsilon_rate, 2)

def calculate_life_support_rating(numbers):
    oxygen_generator_rating = find_number(numbers, char_position = 0, use_most_common_bit = True)
    co2_scrubber_rating = find_number(numbers, char_position = 0, use_most_common_bit = False)
    return int(oxygen_generator_rating, 2) * int(co2_scrubber_rating, 2)

def find_number(numbers, char_position, use_most_common_bit):
    if (len(numbers) == 1):
        return numbers[0]
    else:
        desired_bit = '1' if sum([int(number[char_position]) for number in numbers]) >= (len(numbers) / 2) else '0'
        desired_bit = desired_bit if use_most_common_bit else ('1' if desired_bit == '0' else '0')
        filtered_numbers = list(filter(lambda number: number[char_position] == desired_bit, numbers))
        return find_number(filtered_numbers, char_position + 1, use_most_common_bit)

print("Part 1: " + str(execute(is_part_two = False)))
print("Part 2: " + str(execute(is_part_two = True)))