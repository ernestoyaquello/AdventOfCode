import input
import re
from collections import defaultdict

PROBLEM_NUMBER = 14
INPUT_PATTERN = re.compile(r"p=(\d+),(\d+) v=(-?\d+),(-?\d+)")
MAP_SIZE = (101, 103)

def read_robots():
    robots = []

    instructions = input.read(problem_number = PROBLEM_NUMBER)
    for match in INPUT_PATTERN.finditer(instructions):
        robots.append({
            "position": {"x": int(match.group(1)), "y": int(match.group(2))},
            "velocity": {"x": int(match.group(3)), "y": int(match.group(4))},
        })

    return robots

def calculate_safety_factor(seconds):
    safety_factor = 1

    quadrant_to_number_of_robots = defaultdict(int)
    for robot in read_robots():
        move_robot(robot, seconds)
        if robot["position"]["x"] != (MAP_SIZE[0] // 2) and robot["position"]["y"] != (MAP_SIZE[1] // 2):
            quadrant_number = 0
            if robot["position"]["x"] > (MAP_SIZE[0] // 2):
                quadrant_number += 1
                if robot["position"]["y"] > (MAP_SIZE[1] // 2):
                    quadrant_number += 2
            elif robot["position"]["y"] > (MAP_SIZE[1] // 2):
                quadrant_number += 2
            quadrant_to_number_of_robots[quadrant_number] += 1

    for number_of_robots in quadrant_to_number_of_robots.values():
        safety_factor *= number_of_robots

    return safety_factor

def print_tree_candidates():
    robots = read_robots()
    seconds = 0
    while True:
        # Move the robots, making sure to save the positions where they all are
        occupied_positions = set()
        horizontal_symmetries, vertical_symmetries = 0, 0
        for robot in robots:
            move_robot(robot, 1)
            occupied_positions.add((robot["position"]["x"], robot["position"]["y"]))
        seconds += 1

        # Count the number of horizontal and vertical symmetries
        for robot in robots:
            if robot["position"]["x"] < (MAP_SIZE[0] // 2):
                horizontal_symmetries += 1 if (MAP_SIZE[0] - robot["position"]["x"] - 1, robot["position"]["y"]) in occupied_positions else 0
            if robot["position"]["y"] < (MAP_SIZE[1] // 2):
                vertical_symmetries += 1 if (robot["position"]["x"], MAP_SIZE[1] - robot["position"]["y"] - 1) in occupied_positions else 0

        # If there are enough symmetries, print the map, as it will be a candidate for having the picture of a tree on it
        if horizontal_symmetries > 100 or vertical_symmetries > 100:
            output = "\nAfter " + str(seconds) + " seconds:\n"
            for y in range(0, MAP_SIZE[1]):
                for x in range(0, MAP_SIZE[0]):
                    output += "#" if (x, y) in occupied_positions else " "
                output += "\n"
            print(output)

def move_robot(robot, seconds):
    robot["position"]["x"] += robot["velocity"]["x"] * seconds
    robot["position"]["y"] += robot["velocity"]["y"] * seconds
    robot["position"]["x"] %= MAP_SIZE[0]
    robot["position"]["y"] %= MAP_SIZE[1]

print("Part 1: " + str(calculate_safety_factor(100)))
print("Part 2: " + str(print_tree_candidates()))