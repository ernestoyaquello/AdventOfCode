import input
from collections import defaultdict

PROBLEM_NUMBER = 1

def calculate_total_distance(locations, other_locations):
    total_distance = 0

    for index in range(len(locations)):
        location = locations[index]
        other_location = other_locations[index]
        total_distance += abs(location - other_location)

    return total_distance

def calculate_similarity_score(locations, other_locations):
    similarity_score = 0

    location_to_occurrences = defaultdict(int)
    for location in locations:
        location_to_occurrences[location] += 1

    for other_location in other_locations:
        if other_location in location_to_occurrences:
            occurrences = location_to_occurrences[other_location]
            similarity_score += other_location * occurrences

    return similarity_score

lines = input.read_lines(problem_number = PROBLEM_NUMBER)
locations = sorted([int(line.split()[0]) for line in lines])
other_locations = sorted([int(line.split()[1]) for line in lines])

result_part_one = calculate_total_distance(locations, other_locations)
result_part_two = calculate_similarity_score(locations, other_locations)

print("Part 1: " + str(result_part_one))
print("Part 1: " + str(result_part_two))