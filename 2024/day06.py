import input
import sys

PROBLEM_NUMBER = 6
RIGHT_TURN = { (-1, 0): (0, -1), (0, -1): (1, 0), (1, 0): (0, 1), (0, 1): (-1, 0) }

def get_data():
    data = {}

    # Read the map
    lines = input.read_lines(problem_number = PROBLEM_NUMBER)
    data["max_x"] = len(lines[0]) - 1
    data["max_y"] = len(lines) - 1
    data["positions_with_obstacles"] = set()
    for x in range(0, data["max_x"] + 1):
        for y in range(0, data["max_y"] + 1):
            position = (x, y)
            if lines[y][x] == "#":
                data["positions_with_obstacles"].add(position)
            elif lines[y][x] == "^":
                data["guard_position"] = position

    # Calculate the path to the nearest obstacle for each position and direction
    data["position_and_direction_to_obstacle_path"] = {}
    for x in range(0, data["max_x"] + 1):
        for y in range(0, data["max_y"] + 1):
            position = (x, y)
            for direction in [(-1, 0), (0, -1), (1, 0), (0, 1)]:
                obstacle_path = calculate_obstacle_path(position, direction, data["max_x"], data["max_y"], data["positions_with_obstacles"])
                data["position_and_direction_to_obstacle_path"][(position, direction)] = obstacle_path

    return data

def calculate_obstacle_path(position, direction, max_x, max_y, positions_with_obstacles):
    obstacle_path = None

    if position not in positions_with_obstacles:
        next_x = position[0] + direction[0]
        next_y = position[1] + direction[1]
        obstacle_path = [(next_x, next_y)]
        while (next_x, next_y) not in positions_with_obstacles:
            if next_x < 0 or next_x > max_x or next_y < 0 or next_y > max_y:
                # We got out of bounds before being able to find an obstacle
                obstacle_path = None
                break
            next_x += direction[0]
            next_y += direction[1]
            obstacle_path.append((next_x, next_y))

        # Remove the last position, which is the obstacle itself
        if obstacle_path is not None and len(obstacle_path) > 0:
            obstacle_path.pop()

    return obstacle_path

def count_unique_positions(data):
    visited_positions = get_visited_positions(data)
    if visited_positions is not None:
        # Count the unique positions that were visited
        return len({position for position, _ in get_visited_positions(data)})

    # A loop was detected, so we return the maximum possible value
    return sys.maxsize

def get_visited_positions(data):
    guard_position = data["guard_position"]
    guard_direction = (0, -1)
    guard_visited_positions = { (guard_position, guard_direction) }

    # The guard will visit each position following their instructions until they exit the map 
    while data["position_and_direction_to_obstacle_path"][(guard_position, guard_direction)] is not None:
        obstacle_path = data["position_and_direction_to_obstacle_path"][(guard_position, guard_direction)]
        for path_position in obstacle_path:
            # If the guard has already visited this position with the same direction, then we are in a loop
            if (path_position, guard_direction) in guard_visited_positions:
                return None

            guard_visited_positions.add((path_position, guard_direction))

        # Jump directly in front of the obstacle, then turn right
        guard_position = (guard_position[0] + (guard_direction[0] * len(obstacle_path)), guard_position[1] + (guard_direction[1] * len(obstacle_path)))
        guard_direction = RIGHT_TURN[guard_direction]

    # Also take into account the walk to exit the map
    next_guard_position = (guard_position[0] + guard_direction[0], guard_position[1] + guard_direction[1])
    while next_guard_position[0] >= 0 and next_guard_position[0] <= data["max_x"] and next_guard_position[1] >= 0 and next_guard_position[1] <= data["max_y"]:
        guard_visited_positions.add((next_guard_position, guard_direction))
        next_guard_position = (next_guard_position[0] + guard_direction[0], next_guard_position[1] + guard_direction[1])

    return guard_visited_positions

def count_possible_loops(data):
    number_of_possible_loops = 0

    # Try adding obstacles in the positions where we know the guard might end up
    unique_visited_positions = {position for position, _ in get_visited_positions(data)}
    for x, y in unique_visited_positions:
        position = (x, y)
        if position not in data["positions_with_obstacles"] and position != data["guard_position"]:
            # Add an obstacle at this position
            data["positions_with_obstacles"].add(position)
            position_and_direction_to_obstacle_path_backup = data["position_and_direction_to_obstacle_path"].copy()

            # Update the paths to/from the obstacle
            positions_to_update = [(inner_x, y) for inner_x in range(0, position[0])]
            positions_to_update.extend([(inner_x, y) for inner_x in range(position[0] + 1, data["max_x"] + 1)])
            positions_to_update.extend([(x, inner_y) for inner_y in range(0, position[1])])
            positions_to_update.extend([(x, inner_y) for inner_y in range(position[1] + 1, data["max_y"] + 1)])
            for position_to_update in positions_to_update:
                for direction in [(-1, 0), (0, -1), (1, 0), (0, 1)]:
                    obstacle_path = calculate_obstacle_path(position_to_update, direction, data["max_x"], data["max_y"], data["positions_with_obstacles"])
                    data["position_and_direction_to_obstacle_path"][(position_to_update, direction)] = obstacle_path

            # Check if this obstacle causes a loop
            if count_unique_positions(data) == sys.maxsize:
                number_of_possible_loops += 1

            data["position_and_direction_to_obstacle_path"] = position_and_direction_to_obstacle_path_backup
            data["positions_with_obstacles"].remove(position)

    return number_of_possible_loops

data = get_data()
print("Part 1: " + str(count_unique_positions(data)))
print("Part 2: " + str(count_possible_loops(data)))