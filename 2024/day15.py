import input

PROBLEM_NUMBER = 15
MOVES = {"<": (-1, 0), "^": (0, -1), ">": (1, 0), "v": (0, 1)}

def move_robot(expand_map):
    if not expand_map:
        return move_robot_in_default_map()
    else:
        return move_robot_in_expanded_map()

def move_robot_in_default_map():
    map, robot_position, moves = read_data(expand_map = False)
    for move in moves:
        if move in map[robot_position]["neighbors"]:
            # Find the next position that is free in the direction in which the robot is trying to move
            next_free_position = map[robot_position]["neighbors"][move]
            while next_free_position in map and map[next_free_position]["type"] == "O":
                next_free_position = (next_free_position[0] + MOVES[move][0], next_free_position[1] + MOVES[move][1])

            # If there is a free position somewhere, it means that the move is doable
            if next_free_position in map:
                # If the next free position is further than where the robot wants to move to,
                # that means that boxes will need to be pushed, so we push them, ensuring we
                # leave an empty space in the position where the robot will end up
                next_robot_position = map[robot_position]["neighbors"][move]
                if next_free_position != next_robot_position:
                    map[next_robot_position]["type"] = "."
                    map[next_free_position]["type"] = "O"

                # Finally, we move the robot to its new position
                robot_position = next_robot_position
    return sum((position[0] + (100 * position[1])) if tile["type"] == "O" else 0 for position, tile in map.items())

def move_robot_in_expanded_map():
    map, robot_position, moves = read_data(expand_map = True)
    for move in moves:
        if move in map[robot_position]["neighbors"]:
            next_robot_position = map[robot_position]["neighbors"][move]
            if next_robot_position in map and (map[next_robot_position]["type"] == "." or try_push_expanded_box(map, next_robot_position, MOVES[move])):
                robot_position = next_robot_position
    return sum((position[0] + (100 * position[1])) if tile["type"] == "[" else 0 for position, tile in map.items())

def try_push_expanded_box(map, box_position, move):
    if move[0] != 0:
        moved = False

        # Find the next empty position for this horizontal move, if any
        next_free_position = (box_position[0] + move[0], box_position[1] + move[1])
        while next_free_position in map and map[next_free_position]["type"] != ".":
            next_free_position = (next_free_position[0] + move[0], next_free_position[1])

        # Shift the boxes one by one if able
        while next_free_position in map and map[next_free_position]["type"] == "." and next_free_position != box_position:
            next_next_free_position = (next_free_position[0] - move[0], next_free_position[1])
            map[next_free_position]["type"] = map[next_next_free_position]["type"]
            map[next_next_free_position]["type"] = "."
            next_free_position = next_next_free_position
            moved = True

        return moved
    else:
        # Perform this vertical move, which might involve pushing boxes that form a pyramid with each other
        current_left_position = box_position if map[box_position]["type"] == "[" else (box_position[0] - 1, box_position[1])
        current_right_position = (current_left_position[0] + 1, current_left_position[1])
        next_left_position = (current_left_position[0] + move[0], current_left_position[1] + move[1])
        next_right_position = (next_left_position[0] + 1, next_left_position[1])
        if next_left_position in map and next_right_position in map:
            map_types_backup = {position: tile["type"] for position, tile in map.items()}
            # If the movement isn't possible directly because there are other boxes in the way, try to move them recursively
            if (map[next_left_position]["type"] == "." or try_push_expanded_box(map, next_left_position, move)) and (map[next_right_position]["type"] == "." or try_push_expanded_box(map, next_right_position, move)):
                # The movement is possible, so we actually move the box
                map[next_left_position]["type"] = map[current_left_position]["type"]
                map[next_right_position]["type"] = map[current_right_position]["type"]
                map[current_left_position]["type"] = "."
                map[current_right_position]["type"] = "."
                return True
            else:
                # The movement wasn't possible, so we restore the map to what it was before we attempted it
                for position, type in map_types_backup.items():
                    map[position]["type"] = type
                return False
        else:
            # The position to move to was out of bounds
            return False

def read_data(expand_map):
    # Read basic data from the input
    divided_input = input.read(PROBLEM_NUMBER).split("\n\n")
    layout = divided_input[0].split("\n")
    if expand_map:
        layout = [row.replace("#", "##").replace("O", "[]").replace(".", "..").replace("@", "@.") for row in layout]
    moves = divided_input[1].replace("\n", "")

    # Create a map from the layout where each tile has information about its position, accessible neighbors, and content
    map = {}
    robot_position = None
    for y in range(len(layout)):
        for x in range(len(layout[y])):
            character = layout[y][x]
            if character == "@":
                robot_position = (x,y)
                character = "."
            if character != "#":
                move_key_to_neighbor_position = {}
                for move_key, move in MOVES.items():
                    neighbor_position = (x + move[0], y + move[1])
                    if neighbor_position[0] >= 0 and neighbor_position[0] < len(layout[y]) and neighbor_position[1] >= 0 and neighbor_position[1] < len(layout) and layout[neighbor_position[1]][neighbor_position[0]] != "#":
                        move_key_to_neighbor_position[move_key] = neighbor_position
                map[(x,y)] = {"position": (x,y), "type": character, "neighbors": move_key_to_neighbor_position}

    # Return all the data read and processed above
    return map, robot_position, moves

print("Part 1: " + str(move_robot(expand_map = False)))
print("Part 2: " + str(move_robot(expand_map = True)))