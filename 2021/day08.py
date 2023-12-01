import input

PROBLEM_NUMBER = 8

def execute():
    lines = input.read_lines(problem_number = PROBLEM_NUMBER)
    data = [list(map(lambda digit_segments: [''.join(sorted(list(segment))) for segment in digit_segments.split(" ")], digit_segments)) for digit_segments in [line.split(" | ") for line in lines]]

    standard_digit_to_segment = {
        0: 'abcefg',
        1: 'cf',
        2: 'acdeg',
        3: 'acdfg',
        4: 'bcdf',
        5: 'abdfg',
        6: 'abdefg',
        7: 'acf',
        8: 'abcdefg',
        9: 'abcdfg',
    }
    segment_length_to_digits = get_segment_length_to_digits(standard_digit_to_segment)
    digit_to_contained_digits = get_digit_to_contained_digits(standard_digit_to_segment)
    digit_to_containing_digits = get_digit_to_containing_digits(standard_digit_to_segment)

    filter_digits = [1, 4, 7, 8]
    total_filtered_digits_appearances = 0
    total_digits_sum = 0
    for (all_segments, segments_to_decode) in data:
        segment_to_digit = get_segment_to_digit(all_segments, segment_length_to_digits, digit_to_contained_digits, digit_to_containing_digits)
        total_filtered_digits_appearances += sum([1 if segment_to_digit[segment] in filter_digits else 0 for segment in segments_to_decode])
        total_digits_sum += int(''.join(list(map(lambda segment: str(segment_to_digit[segment]), segments_to_decode))))

    print("Part 1: " + str(total_filtered_digits_appearances))
    print("Part 2: " + str(total_digits_sum))

def get_segment_length_to_digits(digit_to_segment):
    segment_length_to_digits = {}

    for digit, digit_segments in digit_to_segment.items():
        if len(digit_segments) not in segment_length_to_digits:
            segment_length_to_digits[len(digit_segments)] = [digit]
        else:
            segment_length_to_digits[len(digit_segments)].append(digit)

    return segment_length_to_digits

def get_digit_to_contained_digits(digit_to_segment):
    digit_to_contained_digits = {}

    segment_to_digit = { s: d for d, s in digit_to_segment.items() }
    for digit in range(10):
        other_digit_to_segment = list(filter(lambda digit_segment: digit_segment != digit_to_segment[digit], digit_to_segment.values()))
        digit_to_contained_digits[digit] = list(filter(lambda digit_segment: all(inner_digit_segment in list(digit_to_segment[digit]) for inner_digit_segment in list(digit_segment)), other_digit_to_segment))
        digit_to_contained_digits[digit] = list(map(lambda segment: segment_to_digit[segment], digit_to_contained_digits[digit]))

    return digit_to_contained_digits

def get_digit_to_containing_digits(digit_to_segment):
    digit_to_containing_digits = {}

    segment_to_digit = { s: d for d, s in digit_to_segment.items() }
    for digit in range(10):
        other_digit_to_segment = list(filter(lambda digit_segment: digit_segment != digit_to_segment[digit], digit_to_segment.values()))
        digit_to_containing_digits[digit] = list(filter(lambda digit_segment: all(inner_digit_segment in list(digit_segment) for inner_digit_segment in list(digit_to_segment[digit])), other_digit_to_segment))
        digit_to_containing_digits[digit] = list(map(lambda segment: segment_to_digit[segment], digit_to_containing_digits[digit]))

    return digit_to_containing_digits

def get_segment_to_digit(all_segments, segment_length_to_digits, digit_to_contained_digits, digit_to_containing_digits):
    # Get the digits that have the potential to represent each segment based on the length of the segment
    segment_to_candidate_digits = {}
    for segment in all_segments:
        segment_to_candidate_digits[segment] = segment_length_to_digits[len(segment)]

    # While there are segments with more than one candidate digit, let's keep iterating to narrow down the results
    while any(len(cd) > 1 for cd in segment_to_candidate_digits.values()):
        for segment, candidate_digits in filter(lambda s_cd: len(s_cd[1]) > 1, segment_to_candidate_digits.items()):
            updated_candidate_digits = candidate_digits.copy()

            # Remove candidates that do not contain the expected segments
            for candidate_digit in filter(lambda _: len(candidate_digits) > 1, candidate_digits):
                expected_contained_digits = digit_to_contained_digits[candidate_digit]
                for expected_contained_digit in expected_contained_digits:
                    expected_contained_segments = list(map(lambda s_cd: s_cd[0], list(filter(lambda s_cd: expected_contained_digit in s_cd[1], segment_to_candidate_digits.items()))))
                    if not any(all(s in list(segment) for s in list(expected_contained_segment)) for expected_contained_segment in expected_contained_segments):
                        updated_candidate_digits.remove(candidate_digit)
                        break

            # Remove candidates that are not contained by the expected segments
            for candidate_digit in filter(lambda _: len(updated_candidate_digits) > 1, updated_candidate_digits):
                expected_containing_digits = digit_to_containing_digits[candidate_digit]
                for expected_containing_digit in expected_containing_digits:
                    expected_containing_segments = list(map(lambda s_cd: s_cd[0], list(filter(lambda s_cd: expected_containing_digit in s_cd[1], segment_to_candidate_digits.items()))))
                    if not any(all(s in list(expected_containing_segment) for s in list(segment)) for expected_containing_segment in expected_containing_segments):
                        updated_candidate_digits.remove(candidate_digit)
                        break

            # Set the updated values in the map
            segment_to_candidate_digits[segment] = updated_candidate_digits

            # For candidate digits that aren't repeated anywhere else, we can be sure we have found the right and only valid candidate digit
            for candidate_digit in updated_candidate_digits:
                if not any((s != segment and candidate_digit in cd) for s, cd in segment_to_candidate_digits.items()):
                    segment_to_candidate_digits[segment] = [candidate_digit]
                    break

    # Each collection of candidate digits should now have only one candidate digit, so we simplify the map before returning it
    return { s: d[0] for s, d in segment_to_candidate_digits.items() }

execute()