import input

PROBLEM_NUMBER = 10

PAIRS = { '(': ')', '[': ']', '{': '}', '<': '>' }
ERROR_SCORES = { ')': 3, ']': 57, '}': 1197, '>': 25137 }
AUTOCOMPLETE_SCORES = { ')': 1, ']': 2, '}': 3, '>': 4 }

def execute(is_part_two):
    lines = input.read_lines(problem_number = PROBLEM_NUMBER)

    autocomplete_scores = []
    syntax_errors_score = 0

    for line in lines:
        illegal_characters = []
        characters = list(line)
        traverse_character_pairs(characters, 0, -1, illegal_characters)

        if len(illegal_characters) > 0:
            syntax_errors_score += ERROR_SCORES[illegal_characters[0]]
        else:
            autocomplete_score = 0
            for missing_character_index in range(len(line), len(characters)):
                missing_character = characters[missing_character_index]
                autocomplete_score = (autocomplete_score * 5) + AUTOCOMPLETE_SCORES[missing_character]
            autocomplete_scores.append(autocomplete_score)
    
    if not is_part_two:
        return syntax_errors_score
    else:
        autocomplete_scores.sort()
        return autocomplete_scores[int(len(autocomplete_scores) / 2)]

# Goes through the tree of matching pairs, adds the missing ones, and detect the illegal ones
def traverse_character_pairs(characters, index, last_expected_closing_character, illegal_characters):

    # If the index to use is out of range, then the expected closing character is missing from the array, so we add it
    if index >= len(characters):
        characters.append(last_expected_closing_character)

    character = characters[index]

    if character in PAIRS.keys():
        # The character is an opening character, so we look for its closing pair by going down the tree
        expected_closing_character = PAIRS[character]
        closing_character_index = traverse_character_pairs(characters, index + 1, expected_closing_character, illegal_characters)
        closing_character = characters[closing_character_index]

        # If the closing character we have found is not the expected one, we add it to the list of illegal characters
        if closing_character != expected_closing_character:
            illegal_characters.append(closing_character)

        # If there is still a closing character waiting to be found, we continue the search, starting from the next character
        if last_expected_closing_character != -1:
            return traverse_character_pairs(characters, closing_character_index + 1, last_expected_closing_character, illegal_characters)

    # The character is a closing character, so we just return its index to the level above in the three
    return index

print("Part 1: " + str(execute(is_part_two = False)))
print("Part 2: " + str(execute(is_part_two = True)))