import input
from collections import defaultdict

PROBLEM_NUMBER = 23

def count_computer_sets(desired_set_size):
    graph = get_graph()
    computer_sets = []
    for computer in graph.keys():
        if computer[0] == "t":
            for computer_set in find_computer_sets_recursively(computer, graph, [computer], desired_set_size):
                if computer_set not in computer_sets:
                    computer_sets.append(computer_set)
    return len(computer_sets)

def find_biggest_computer_sets():
    graph = get_graph()
    biggest_sets = {}
    for desired_set_size in range(3, len(graph) + 1):
        set_found = False
        for computer in graph.keys():
            if len(graph[computer]) >= desired_set_size:
                aux_set = [computer]
                if computer in biggest_sets:
                    aux_set = biggest_sets[computer]
                for computer_set in find_computer_sets_recursively(computer, graph, aux_set, desired_set_size):
                    biggest_sets[computer] = computer_set
                    set_found = True
                    break
        if not set_found:
            break
    return ",".join(sorted(biggest_sets.values(), key = lambda s: len(s), reverse = True)[0])

def find_computer_sets_recursively(computer, graph, current_computer_set, desired_set_size):
    computer_sets = []

    if len(current_computer_set) < desired_set_size:
        for connected_computer in graph[computer]:
            if connected_computer not in current_computer_set and len(graph[connected_computer]) >= len(current_computer_set) and all(c in graph[connected_computer] for c in current_computer_set):
                next_computer_set = sorted(current_computer_set + [connected_computer])
                for computer_set in find_computer_sets_recursively(connected_computer, graph, next_computer_set, desired_set_size):
                    if computer_set not in computer_sets:
                        computer_sets.append(computer_set)
    elif current_computer_set not in computer_sets:
        computer_sets.append(current_computer_set)

    return computer_sets

def get_graph():
    connections = [(line.split("-")[0], line.split("-")[1]) for line in input.read_lines(problem_number = PROBLEM_NUMBER)]
    graph = defaultdict(list)
    for left, right in connections:
        if right not in graph[left]:
            graph[left].append(right)
        if left not in graph[right]:
            graph[right].append(left)
    return graph

print("Part 1: " + str(count_computer_sets(desired_set_size = 3)))
print("Part 2: " + str(find_biggest_computer_sets()))