import input
from collections import defaultdict

PROBLEM_NUMBER = 21

def execute(is_part_two):
    player_positions = read_player_positions(input.read_lines(problem_number = PROBLEM_NUMBER))
    player_scores = defaultdict(int)

    if not is_part_two:
        dice_rolls = play(player_positions, player_scores)
        return dice_rolls * min(player_scores.values())
    else:
        dice_results = calculate_quantum_combinations(0, 0)
        dice_result_to_count = defaultdict(int)
        for dice_result in dice_results:
            dice_result_to_count[dice_result] += 1
        player_wins = defaultdict(int)
        play_recursively(1, player_positions, player_scores, dice_result_to_count, player_wins, 1)
        return max(player_wins.values())

def play(player_positions, player_scores):
    dice_rolls = 0

    last_dice_value = 0
    finished = False
    while not finished:
        for player, position in player_positions.items():
            new_position = position
            if last_dice_value > 97:
                diff = 100 - last_dice_value
                for aux in range(diff):
                    new_position += last_dice_value + aux + 1
                for aux in range(3 - diff):
                    new_position += aux + 1
            else:
                new_position += (last_dice_value + 1) + (last_dice_value + 2) + (last_dice_value + 3)

            new_position %= 10
            corrected_new_position = new_position if new_position != 0 else 10

            player_positions[player] = corrected_new_position
            player_scores[player] += corrected_new_position
            dice_rolls += 3
            last_dice_value += 3
            last_dice_value = last_dice_value if last_dice_value < 101 else (last_dice_value % 100)
            if player_scores[player] >= 1000:
                finished = True
                break

    return dice_rolls

def play_recursively(player, player_positions, player_scores, dice_result_to_count, player_wins, previous_count):
    for dice_result, count in dice_result_to_count.items():
        old_position = player_positions[player]
        old_score = player_scores[player]

        new_position = (old_position + dice_result) % 10
        corrected_new_position = new_position if new_position != 0 else 10

        player_positions[player] = corrected_new_position
        player_scores[player] += corrected_new_position

        if player_scores[player] >= 21:
            player_wins[player] += count * previous_count
        else:
            next_player = (player + 1) % len(player_positions.keys())
            next_player = next_player if next_player != 0 else 2
            play_recursively(next_player, player_positions, player_scores, dice_result_to_count, player_wins, count * previous_count)

        player_scores[player] = old_score
        player_positions[player] = old_position

def calculate_quantum_combinations(index, last_result):
    results = []

    for dice_roll in [1, 2, 3]:
        result = last_result + dice_roll
        if index == 2:
            results.append(result)
        else:
            results.extend(calculate_quantum_combinations(index + 1, result))

    return results

def read_player_positions(lines):
    return { int(player): int(position) for player, position in [line.replace('Player ', '').replace('starting position: ', '').split(' ') for line in lines] }

print("Part 1: " + str(execute(is_part_two = False)))
print("Part 2: " + str(execute(is_part_two = True)))