import input
from collections import defaultdict

PROBLEM_NUMBER = 22

def sum_random_numbers(number_index):
    return sum(generate_random_number(seed, number_index) for seed in input.read_numbers(problem_number = PROBLEM_NUMBER))

def find_best_sequence(max_number_index):
    sequences = defaultdict(int)
    numbers = input.read_numbers(problem_number = PROBLEM_NUMBER)
    for secret_number in numbers:
        diffs = []
        previous_last_digit = str(secret_number)
        previous_last_digit = int(previous_last_digit[len(previous_last_digit) - 1])
        used_sequences = set()
        for number_index in range(1, max_number_index):
            new_secret_number = ((secret_number << 6) ^ secret_number) & 16777215
            new_secret_number = ((new_secret_number >> 5) ^ new_secret_number) & 16777215
            secret_number = ((new_secret_number << 11) ^ new_secret_number) & 16777215
            last_digit = str(secret_number)
            last_digit = int(last_digit[len(last_digit) - 1])
            diffs.append(last_digit - previous_last_digit)
            if number_index >= 4:
                last_diffs_index = len(diffs) - 1
                sequence = (diffs[last_diffs_index - 3], diffs[last_diffs_index - 2], diffs[last_diffs_index - 1], diffs[last_diffs_index])
                if sequence not in used_sequences:
                    sequences[sequence] += last_digit
                    used_sequences.add(sequence)
            previous_last_digit = last_digit
    return max(sequence_value for sequence_value in sequences.values())

def generate_random_number(secret_number, number_index):
    for _ in range(0, number_index):
        new_secret_number = ((secret_number << 6) ^ secret_number) & 16777215
        new_secret_number = ((new_secret_number >> 5) ^ new_secret_number) & 16777215
        secret_number = ((new_secret_number << 11) ^ new_secret_number) & 16777215
    return secret_number

print("Part 1: " + str(sum_random_numbers(2000)))
print("Part 2: " + str(find_best_sequence(2000)))