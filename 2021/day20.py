import input

PROBLEM_NUMBER = 20

SUBMATRIX_DIFFS = [
    (-1, -1), # R: Top,    C: Left
    (-1,  0), # R: Top,    C: Center
    (-1, +1), # R: Top,    C: Right
    (0,  -1), # R: Center, C: Left
    (0,   0), # R: Center, C: Center
    (0,  +1), # R: Center, C: Right
    (+1, -1), # R: Bottom, C: Left
    (+1,  0), # R: Bottom, C: Center
    (+1, +1), # R: Bottom, C: Right
]

def execute(is_part_two):
    lines = input.read_lines(problem_number = PROBLEM_NUMBER)
    enhancing_string = lines[0]

    image = ('.', []) # Outside character, image content
    for image_row in lines[2:]:
        image[1].append(list(image_row))

    for _ in range(2 if not is_part_two else 50):
        image = enhance(image, enhancing_string)

    return count_lit_pixels(image)

def enhance(image, enhancing_string):
    enhanced_image = []

    outside_character = image[0]
    image_content = image[1]
    for row in range(-1, len(image_content) + 1):
        enhanced_image.append([])
        for column in range(-1, len(image_content[0]) + 1):
            bits = []
            for row_diff, column_diff in SUBMATRIX_DIFFS:
                pixel = outside_character
                if 0 <= (row + row_diff) < len(image_content) and 0 <= (column + column_diff) < len(image_content[0]):
                    pixel = image_content[row + row_diff][column + column_diff]
                bits.append('1' if pixel == '#' else '0')
            enhancing_string_index = int(''.join(bits), 2)
            enhanced_image[row + 1].append(enhancing_string[enhancing_string_index])

    new_outside_character_index = int(('1' if outside_character == '#' else '0') * 9, 2)
    new_outside_character = enhancing_string[new_outside_character_index]

    return (new_outside_character, enhanced_image)

def count_lit_pixels(image):
    count = 0

    image_content = image[1]
    for row in range(len(image_content)):
        for column in range(len(image_content[0])):
            count += 1 if image_content[row][column] == '#' else 0

    return count

print("Part 1: " + str(execute(is_part_two = False)))
print("Part 2: " + str(execute(is_part_two = True)))