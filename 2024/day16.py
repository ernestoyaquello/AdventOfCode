import input
from collections import defaultdict

PROBLEM_NUMBER = 16

def read_data():
    start_position, start_direction, end_position, map = None, (1, 0), None, {}

    # Convert the input layout into a map of visitable tiles where each one has a list of visitable neighbor positions
    layout = input.read_lines(problem_number = PROBLEM_NUMBER)
    for y in range(0, len(layout)):
        for x in range(0, len(layout[y])):
            if layout[y][x] != "#":
                position = (x, y)
                neighbor_positions = []
                for adjacent_offset in [(-1, 0), (0, -1), (1, 0), (0, 1)]:
                    neighbor_position = (position[0] + adjacent_offset[0], position[1] + adjacent_offset[1])
                    if neighbor_position[0] >= 0 and neighbor_position[0] < len(layout[y]) and neighbor_position[1] >= 0 and neighbor_position[1] < len(layout) and layout[neighbor_position[1]][neighbor_position[0]] != "#":
                        neighbor_positions.append(neighbor_position)
                map[position] = {"position": position, "neighbors": neighbor_positions}
                if layout[y][x] == "S":
                    start_position = position
                elif layout[y][x] == "E":
                    end_position = position

    return start_position, start_direction, end_position, map

def calculate_best_path_score():
    reindeer_position, reindeer_direction, end_position, map = read_data()
    node_to_lowest_score, _ = calculate_best_path_with_dijkstra(reindeer_position, reindeer_direction, end_position, map)
    return min(score for node, score in node_to_lowest_score.items() if node[0] == end_position)

def count_number_of_good_seats():
    reindeer_position, reindeer_direction, end_position, map = read_data()
    node_to_lowest_score, node_to_previous_scored_nodes = calculate_best_path_with_dijkstra(reindeer_position, reindeer_direction, end_position, map)

    # Find all the unique positions that are part of the paths that allow us to reach the end position with the lowest score
    positions_in_best_paths = {end_position}
    min_path_score = min(score for node, score in node_to_lowest_score.items() if node[0] == end_position)
    for end_direction in [(1, 0), (0, -1), (-1, 0), (0, 1)]:
        if (end_position, end_direction) in node_to_previous_scored_nodes:
            nodes_previous_to_the_end_position = [node for node, score in node_to_previous_scored_nodes[(end_position, end_direction)] if score == min_path_score]
            for node_previous_to_the_end_position in nodes_previous_to_the_end_position:
                positions_in_best_paths.update(get_unique_positions_in_best_paths_to_node(node_previous_to_the_end_position, node_to_previous_scored_nodes, start_position = reindeer_position))
    return len(positions_in_best_paths)

def calculate_best_path_with_dijkstra(initial_position, initial_direction, end_position, map):
    first_node = (initial_position, initial_direction)
    node_to_lowest_score = {first_node: 0}
    node_to_previous_scored_nodes = defaultdict(set)
    scored_nodes_to_visit = [(first_node, 0)]
    visited_nodes = set()

    while len(scored_nodes_to_visit) > 0:
        # Get the pending node with the lowest score to visit it
        scored_nodes_to_visit.sort(key = lambda sn: sn[1])
        node, node_score = scored_nodes_to_visit.pop(0)

        # Only process the node by checking its neighbors if this is the best way we've found so far to get to said node
        if node_score <= node_to_lowest_score[node]:
            # Add the node to the visited set
            visited_nodes.add(node)

            if node[0] != end_position:
                # Check the visitable neighbors of the node, in order from more promising to less promising
                for neighbor_position in map[node[0]]["neighbors"]:
                    # Calculate the new score (and direction) that we would get by moving to the neighbor position
                    step_score = 1
                    new_direction = (neighbor_position[0] - node[0][0], neighbor_position[1] - node[0][1])
                    if new_direction != node[1]:
                        step_score += 1000
                    new_score = node_score + step_score

                    # If the neighbor node isn't already visited and the new score needed to reach it is better than the previously found one,
                    # update its score and make sure that it is added to the list of nodes that will be visited later (here, we are using the
                    # comparison "<=" instead of "<" to ensure that all the possible valid paths are explored, which is needed for part 2)
                    neighbor_node = (neighbor_position, new_direction)
                    if neighbor_node not in visited_nodes and (neighbor_node not in node_to_lowest_score or new_score <= node_to_lowest_score[neighbor_node]):
                        node_to_lowest_score[neighbor_node] = new_score
                        node_to_previous_scored_nodes[neighbor_node].add((node, new_score))

                        # Add the neighbor node to the list of nodes to visit, or update its score if it was already there
                        is_in_scored_nodes_to_visit = False
                        for i, (node_to_visit, _) in enumerate(scored_nodes_to_visit):
                            if node == node_to_visit:
                                scored_nodes_to_visit[i] = (neighbor_node, new_score)
                                is_in_scored_nodes_to_visit = True
                                break
                        if not is_in_scored_nodes_to_visit:
                            scored_nodes_to_visit.append((neighbor_node, new_score))
            else:
                # End position reached, no need to continue exploring nodes
                break

    return node_to_lowest_score, node_to_previous_scored_nodes

def get_unique_positions_in_best_paths_to_node(node_to_backtrack_from, node_to_previous_scored_nodes, start_position, visited_positions = set()):
    visited_positions.add(node_to_backtrack_from[0])
    for previous_node, _ in node_to_previous_scored_nodes[node_to_backtrack_from]:
        visited_positions.update(get_unique_positions_in_best_paths_to_node(previous_node, node_to_previous_scored_nodes, start_position, visited_positions))
    return visited_positions

print("Part 1: " + str(calculate_best_path_score()))
print("Part 2: " + str(count_number_of_good_seats()))