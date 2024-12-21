import input
import sys
import heapq

PROBLEM_NUMBER = 20

def count_good_cheats(data, max_cheat_size, cheat_save_threshold):
    # For each visitable position, count all the possible cheats that would save at least as much time as the threshold
    return sum(count_valid_cheat_paths(position, data, max_cheat_size, cheat_save_threshold) for position in data["map"])

def count_valid_cheat_paths(position, data, max_cheat_size, cheat_save_threshold):
    count = 0

    # Iterate over the possible target positions for cheat paths that could start from this position
    explored_offsets = set()
    for max_steps in range(2, max_cheat_size + 1):
        min_x_offset = max(-position[0], -max_steps)
        max_x_offset = min(data["map_width"] - position[0], max_steps)
        for x_offset in range(min_x_offset, max_x_offset + 1):
            min_y_offset = max(-position[1], -(max_steps - abs(x_offset)))
            max_y_offset = min(data["map_height"] - position[1], (max_steps - abs(x_offset)))
            for y_offset in range(min_y_offset, max_y_offset + 1):
                if (x_offset, y_offset) not in explored_offsets:
                    target_position = (position[0] + x_offset, position[1] + y_offset)
                    cheat_path_distance = abs(x_offset) + abs(y_offset)
                    if target_position in data["map"] and cheat_path_distance >= 2:
                        old_steps_to_the_end = data["position_to_distance"][data["end_position"]]
                        new_steps_to_the_end = data["position_to_distance"][position] + cheat_path_distance + (data["position_to_distance"][data["end_position"]] - data["position_to_distance"][target_position])
                        if (old_steps_to_the_end - new_steps_to_the_end) >= cheat_save_threshold:
                            # We have found a path that is valid and will save enough time, let's count it
                            count += 1
                    explored_offsets.add((x_offset, y_offset))

    return count

def read_data():
    data = {}

    # Convert the input layout into a map of visitable tiles where each one has a list of visitable neighbor positions
    lines = input.read_lines(problem_number = PROBLEM_NUMBER)
    data["map_width"] = len(lines[0])
    data["map_height"] = len(lines)
    data["map"] = {}
    for y in range(0, data["map_height"]):
        for x in range(0, data["map_width"]):
            if lines[y][x] != "#":
                position = (x, y)
                neighbor_positions = []
                for adjacent_offset in [(-1, 0), (0, -1), (1, 0), (0, 1)]:
                    neighbor_position = (position[0] + adjacent_offset[0], position[1] + adjacent_offset[1])
                    if neighbor_position[0] >= 0 and neighbor_position[0] < len(lines[y]) and neighbor_position[1] >= 0 and neighbor_position[1] < len(lines) and lines[neighbor_position[1]][neighbor_position[0]] != "#":
                        neighbor_positions.append(neighbor_position)
                data["map"][position] = {"position": position, "neighbors": neighbor_positions}
                if lines[y][x] == "S":
                    data["start_position"] = position
                elif lines[y][x] == "E":
                    data["end_position"] = position

    # Figure out the distance from the start to each position to allow for future path-finding calculations
    data["position_to_distance"] = calculate_distances_with_dijkstra(data["start_position"], data["map"])

    return data

def calculate_distances_with_dijkstra(initial_position, map):
    position_to_distance = {position: sys.maxsize if position != initial_position else 0 for position in map.keys()}
    distance_and_node_pq = [(0, initial_position)]  # priority queue of (distance, node)

    while distance_and_node_pq:
        current_dist, position = heapq.heappop(distance_and_node_pq)

        # Only continue if this path can be best than the best one we've found so far
        if current_dist <= position_to_distance[position]:
            for neighbor_position in map[position]["neighbors"]:
                new_dist = current_dist + 1
                if new_dist < position_to_distance[neighbor_position]:
                    position_to_distance[neighbor_position] = new_dist
                    heapq.heappush(distance_and_node_pq, (new_dist, neighbor_position))

    return position_to_distance

data = read_data()
print("Part 1: " + str(count_good_cheats(data, max_cheat_size = 2, cheat_save_threshold = 100)))
print("Part 2: " + str(count_good_cheats(data, max_cheat_size = 20, cheat_save_threshold = 100)))