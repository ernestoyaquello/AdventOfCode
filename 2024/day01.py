import input
from collections import defaultdict

PROBLEM_NUMBER = 1

def calculate_total_distance(locations, other_locations):
    return sum(abs(loc - o_loc) for loc, o_loc in zip(locations, other_locations))

def calculate_similarity_score(locations, other_locations):
    # Count the occurrences of each location and store it for efficiency (no need to count them ever again later)
    location_to_occurrences = defaultdict(int)
    for location in locations:
        location_to_occurrences[location] += 1

    # Calculate the similarity score using the occurrence counts found above
    return sum(o_loc * location_to_occurrences[o_loc] for o_loc in other_locations)

# Get inputs
lines = input.read_lines(problem_number = PROBLEM_NUMBER)
locations = sorted([int(line.split()[0]) for line in lines])
other_locations = sorted([int(line.split()[1]) for line in lines])

# Calculate results
result_part_one = calculate_total_distance(locations, other_locations)
result_part_two = calculate_similarity_score(locations, other_locations)

print("Part 1: " + str(result_part_one))
print("Part 2: " + str(result_part_two))