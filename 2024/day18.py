import input
import sys
from collections import defaultdict

PROBLEM_NUMBER = 18
MAP_WIDTH, MAP_HEIGHT = 71, 71

def count_steps_to_exit(nanoseconds):
    initial_position = (0, 0)
    exit_position = (MAP_WIDTH - 1, MAP_HEIGHT - 1)
    map = generate_map(read_byte_positions(), nanoseconds)
    position_to_lowest_score, _ = calculate_best_path_with_dijkstra(initial_position, exit_position, map)
    return position_to_lowest_score[exit_position]

def find_first_problematic_byte_position(initial_nanoseconds):
    initial_position = (0, 0)
    exit_position = (MAP_WIDTH - 1, MAP_HEIGHT - 1)
    nanoseconds = initial_nanoseconds + 1
    byte_positions = read_byte_positions()
    while True:
        map = generate_map(byte_positions, nanoseconds)
        position_to_lowest_score, _ = calculate_best_path_with_dijkstra(initial_position, exit_position, map)
        if position_to_lowest_score[exit_position] == sys.maxsize:
            problematic_position = byte_positions[nanoseconds - 1]
            return str(problematic_position[0]) + "," + str(problematic_position[1])
        nanoseconds += 1

def generate_map(byte_positions, nanoseconds):
    # Take as many positions as nanoseconds have passed to fill the map
    occupied_byte_positions = {position for position in byte_positions[0:min(nanoseconds, len(byte_positions) - 1)]}

    # Generate the map with the byte positions and their neighbors for easy path-finding
    map = {}
    for y in range(0, MAP_HEIGHT):
        for x in range(0, MAP_WIDTH):
            if (x, y) not in occupied_byte_positions:
                map[(x, y)] = {"position": (x, y), "neighbors": []}
                for adjacent_offset in [(-1, 0), (0, -1), (1, 0), (0, 1)]:
                    neighbor_position = (x + adjacent_offset[0], y + adjacent_offset[1])
                    if neighbor_position[0] >= 0 and neighbor_position[0] < MAP_WIDTH and neighbor_position[1] >= 0 and neighbor_position[1] < MAP_HEIGHT and neighbor_position not in occupied_byte_positions:
                        map[(x, y)]["neighbors"].append(neighbor_position)
    return map

def read_byte_positions():
    return [(int(line.split(",")[0]), int(line.split(",")[1])) for line in input.read_lines(problem_number = PROBLEM_NUMBER)]

def calculate_best_path_with_dijkstra(initial_position, end_position, map):
    position_to_lowest_score = defaultdict(lambda: sys.maxsize)
    position_to_previous_scored_positions = defaultdict(set)
    scored_positions_to_visit = [(initial_position, 0)]
    visited_positions = set()

    while len(scored_positions_to_visit) > 0:
        # Get the pending position with the lowest score to visit it
        scored_positions_to_visit.sort(key = lambda sn: sn[1])
        position, position_score = scored_positions_to_visit.pop(0)

        # Only process the position by checking its neighbors if this is the best way we've found so far to get to said position
        if position_score <= position_to_lowest_score[position]:
            # Add the position to the visited set
            visited_positions.add(position)

            # If we haven't reached the end position yet, keep exploring the map by checking the neighbors of this position
            if position != end_position:
                for neighbor_position in map[position]["neighbors"]:
                    # Calculate the new score that we would get by moving to the neighbor position
                    new_score = position_score + 1

                    # If the neighbor position isn't already visited and the new score needed to reach it is better than the previously
                    # found one, update its score and make sure that it is added to the list of positions that will be visited later
                    if neighbor_position not in visited_positions and new_score < position_to_lowest_score[neighbor_position]:
                        position_to_lowest_score[neighbor_position] = new_score
                        position_to_previous_scored_positions[neighbor_position].add((position, new_score))

                        # Add the neighbor position to the list of positions to visit, or update its score if it was already there
                        is_in_scored_positions_to_visit = False
                        for i, (position_to_visit, _) in enumerate(scored_positions_to_visit):
                            if position == position_to_visit:
                                scored_positions_to_visit[i] = (neighbor_position, new_score)
                                is_in_scored_positions_to_visit = True
                                break
                        if not is_in_scored_positions_to_visit:
                            scored_positions_to_visit.append((neighbor_position, new_score))
            else:
                # End position reached, no need to continue exploring positions
                break

    return position_to_lowest_score, position_to_previous_scored_positions

print("Part 1: " + str(count_steps_to_exit(1024)))
print("Part 2: " + str(find_first_problematic_byte_position(1024)))