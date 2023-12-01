import input
import sys
from collections import defaultdict

PROBLEM_NUMBER = 17

def execute(is_part_two):
    coordinates =[[int(coordinate) for coordinate in points.split('..')] for points in input.read_lines(problem_number = PROBLEM_NUMBER)[0].replace('target area: x=', '').split(', y=')]
    coordinates[1] = [-coordinates[1][1], -coordinates[1][0]] # Sort Y coordinates and make them positive for convenience
    target_start_x = coordinates[0][0]
    target_end_x = coordinates[0][1]
    target_start_y = coordinates[1][0]
    target_end_y = coordinates[1][1]
    max_steps_x = target_end_x
    max_steps_y = target_end_y * 2

    velocities_x = calculate_initial_velocities_x(target_start_x, target_end_x, max_steps_x, max_steps_y)
    velocities_y = calculate_initial_velocities_y(target_start_y, target_end_y, max_steps_y)

    velocities = []
    max_height = sys.maxsize
    for step, velocities_y in velocities_y.items():
        for velocity_y in velocities_y:
            for velocity_x in velocities_x[step]:
                if (velocity_x, velocity_y) not in velocities:
                    velocities.append((velocity_x, velocity_y))

                    # Max height for any initial velocity will be: init_vel + (init_vel - 1) + (init_vel - 2) + ...
                    max_height = min(max_height, int(-0.5 * (pow(velocity_y, 2) - velocity_y)))

    return -max_height if not is_part_two else len(velocities)

def calculate_initial_velocities_x(target_start_x, target_end_x, max_steps_x, max_steps_y):
    valid_velocities = defaultdict(set)

    # Iterate over the valid steps and target X positions to find valid initial velocities
    for step in range(1, max_steps_x + 1):
        for target_x in range(target_start_x, target_end_x + 1):

            # Get the inicial velocity immediately with this formula to avoid having to simulate the physics step by step
            initial_velocity_x = (target_x + (0.5 * (pow(step, 2) - step))) / step
            if initial_velocity_x.is_integer() and step <= initial_velocity_x:
                valid_velocities[step].add(int(initial_velocity_x))

                # On every step after the current one, this initial velocity will always result on this very same X position
                if step == initial_velocity_x:
                    for future_step in range(step + 1, max_steps_y + 1):
                        valid_velocities[future_step].add(int(initial_velocity_x))

    return valid_velocities

def calculate_initial_velocities_y(target_start_y, target_end_y, max_steps):
    valid_velocities = defaultdict(set)

    # Iterate over the valid steps and target Y positions to find valid initial velocities
    for step in range(1, max_steps + 1):
        for target_y in range(target_start_y, target_end_y + 1):

            # Get the inicial velocity immediately with this formula to avoid having to simulate the physics step by step
            initial_velocity_y = (target_y - (0.5 * (pow(step, 2) - step))) / step
            if initial_velocity_y.is_integer():
                valid_velocities[step].add(int(initial_velocity_y))

    return valid_velocities

print("Part 1: " + str(execute(is_part_two = False)))
print("Part 2: " + str(execute(is_part_two = True)))