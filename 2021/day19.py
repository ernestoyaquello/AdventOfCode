import input
from collections import defaultdict

PROBLEM_NUMBER = 19

def execute(is_part_two):
    lines = input.read_lines(problem_number = PROBLEM_NUMBER)
    scanners = read_scanners(lines)
    scanner_number_to_variations = get_scanner_number_to_variations(scanners)
    scanners_data = get_scanners_data(scanner_number_to_variations)
    map = get_map(scanners_data)

    return len(map) if not is_part_two else get_largest_manhattan_distance(scanners_data)

def get_scanners_data(scanner_number_to_variations):
    scanners_data = { 0: ((0, 0, 0), scanner_number_to_variations[0][0]) } # Scanner number: diff, correct variation

    scanner_numbers_used_as_reference = []
    while len(scanner_numbers_used_as_reference) < len(scanner_number_to_variations):
        reference_scanner_number = -1
        for candidate_reference_scanner_number in scanners_data.keys():
            if candidate_reference_scanner_number not in scanner_numbers_used_as_reference:
                reference_scanner_number = candidate_reference_scanner_number

        reference_scanner_diff = scanners_data[reference_scanner_number][0]
        reference_scanner = scanners_data[reference_scanner_number][1]

        # Compare each scanner reading to the reference one and see if at least 12 coordinates are at the exact same distance
        for scanner_number, scanner_variations in scanner_number_to_variations.items():
            if scanner_number in scanners_data.keys():
                continue

            overlap_found = False
            for scanner_variation in scanner_variations:
                coordinate_diffs = defaultdict(int)
                for coordinate in scanner_variation:
                    for reference_scanner_coordinate in reference_scanner:
                        coordinate_diff = (
                            reference_scanner_diff[0] + reference_scanner_coordinate[0] - coordinate[0],
                            reference_scanner_diff[1] + reference_scanner_coordinate[1] - coordinate[1],
                            reference_scanner_diff[2] + reference_scanner_coordinate[2] - coordinate[2],
                        )
                        coordinate_diffs[coordinate_diff] += 1
                        if coordinate_diffs[coordinate_diff] == 12:
                            # There are at least 12 coordinates that are shifted the same way in both scanner readings, so we have found an overlap
                            scanners_data[scanner_number] = (coordinate_diff, scanner_variation)
                            overlap_found = True
                            break
                    if overlap_found:
                        break
                if overlap_found:
                    break

        # Save the reference scanner number in this list to avoid using it as a reference again
        scanner_numbers_used_as_reference.append(reference_scanner_number)

    return scanners_data

def get_map(scanners_data):
    all_coordinates = []

    for scanner_number, (diff, correct_variation) in scanners_data.items():
        for coordinate in correct_variation:
            corrected_coordinate = (coordinate[0] + diff[0], coordinate[1] + diff[1], coordinate[2] + diff[2])
            if corrected_coordinate not in all_coordinates:
                all_coordinates.append(corrected_coordinate)

    return all_coordinates

def get_largest_manhattan_distance(scanners_data):
    largest_distance = 0
    
    for scanner_number, (diff, correct_variation) in scanners_data.items():
        for scanner_number2, (diff2, correct_variation2) in scanners_data.items():
            if scanner_number != scanner_number2:
                distance = abs(diff[0] - diff2[0]) + abs(diff[1] - diff2[1]) + abs(diff[2] - diff2[2])
                largest_distance = max(largest_distance, distance)

    return largest_distance

def get_scanner_number_to_variations(scanners):
    scanner_number_to_variations = defaultdict(list)

    for scanner_number, scanner in scanners.items():
        scanner_number_to_variations[scanner_number] = calculate_variations([], scanner)

    return scanner_number_to_variations

def calculate_variations(rotations_per_axis, scanner):
    scanner_variations = []

    # Use brute force to calculate all the possible variations based on rotations (4 x 4 x 4 = 64 in total).
    # Ideally, I would do something clever here to calculate only the 24 non-repeated variations there really are,
    # but I couldn't figure out how to do it, so I brute-forced my way out of the problem. Nasty, but it works.
    for number_of_rotations in [0, 1, 2, 3]:
        rotations_per_axis.append(number_of_rotations)
        if len(rotations_per_axis) == 3:
            rotated_scanner = []
            for coordinate in scanner:
                rotated_coordinate = [coordinate[0], coordinate[1], coordinate[2]]
                for rotation_axis_index, rotating_axis_indices in enumerate([[2, 1], [0, 2], [1, 0]]):
                    number_of_rotations = rotations_per_axis[rotation_axis_index]
                    while number_of_rotations > 0:
                        aux = rotated_coordinate[rotating_axis_indices[0]]
                        rotated_coordinate[rotating_axis_indices[0]] = rotated_coordinate[rotating_axis_indices[1]]
                        rotated_coordinate[rotating_axis_indices[1]] = -aux
                        number_of_rotations -= 1
                rotated_scanner.append((rotated_coordinate[0], rotated_coordinate[1], rotated_coordinate[2]))
            scanner_variations.append(rotated_scanner)
        else:
            scanner_variations.extend(calculate_variations(rotations_per_axis, scanner))
        rotations_per_axis.pop()

    # Remove variations that are repeated so we can have only the 24 unique ones we were looking for
    if len(rotations_per_axis) == 0:
        scanner_unique_variations = []
        for scanner_variation in scanner_variations:
            if scanner_variation not in scanner_unique_variations:
                scanner_unique_variations.append(scanner_variation)
        scanner_variations = scanner_unique_variations

    return scanner_variations

def read_scanners(lines):
    scanners = defaultdict(list)

    scanner_number = -1
    for line in lines:
        if '---' in line:
            scanner_number = int(line.replace('--- scanner ', '').replace(' ---', ''))
        elif line:
            coordinates = line.split(',')
            scanners[scanner_number].append((int(coordinates[0]), int(coordinates[1]), int(coordinates[2])))

    return scanners

print("Part 1: " + str(execute(is_part_two = False)))
print("Part 2: " + str(execute(is_part_two = True)))