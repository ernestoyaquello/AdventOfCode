import input
import sys

PROBLEM_NUMBER = 7

def execute(is_part_two):
    positions = list(map(int, input.read_lines(problem_number = PROBLEM_NUMBER)[0].split(",")))
    return find_min_fuel(positions, use_incremental_fuel_cost = is_part_two)

def find_min_fuel(positions, use_incremental_fuel_cost):
    min_fuel = sys.maxsize
    for position in range(0, max(positions) + 1):
        fuel = calculate_fuel(positions, position, use_incremental_fuel_cost)
        min_fuel = fuel if fuel < min_fuel else min_fuel
    return min_fuel

def calculate_fuel(positions, goal_position, use_incremental_fuel_cost):
    distances = [abs(goal_position - position) for position in positions]
    return sum(distance if not use_incremental_fuel_cost else sum_natural_numbers(distance) for distance in distances)

def sum_natural_numbers(n):
    return int((n * (n + 1)) / 2)

print("Part 1: " + str(execute(is_part_two = False)))
print("Part 2: " + str(execute(is_part_two = True)))