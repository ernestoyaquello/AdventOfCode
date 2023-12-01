#include "day12.h"

int main()
{
	//auto result = part1();
	auto result = part2();
	std::cout << result << std::endl;
	return 0;
}

int part1()
{
	auto facing = EAST, horizontal = 0, vertical = 0;

	char instruction;
	int instruction_value;
	for (; std::cin >> instruction && std::cin >> instruction_value; !std::cin.eof() && std::cin.get())
	{
		if (instruction == 'L' || instruction == 'R')
		{
			facing += (instruction_value / 90) * (instruction == 'R' ? 1 : -1);
			facing %= 4;
			facing = facing < 0 ? (4 + facing) : facing;
		}
		else if (instruction == 'F')
		{
			if (facing == WEST) horizontal -= instruction_value;
			else if (facing == EAST) horizontal += instruction_value;
			else if (facing == NORTH) vertical -= instruction_value;
			else if (facing == SOUTH) vertical += instruction_value;
		}
		else
		{
			vertical += instruction == 'N' ? -1 * instruction_value : 0;
			vertical += instruction == 'S' ? 1 * instruction_value : 0;
			horizontal += instruction == 'E' ? 1 * instruction_value : 0;
			horizontal += instruction == 'W' ? -1 * instruction_value : 0;
		}
	}

	horizontal = horizontal < 0 ? -horizontal : horizontal;
	vertical = vertical < 0 ? -vertical : vertical;
	return horizontal + vertical;
}

int part2()
{
	auto waypoint_horizontal = 10, waypoint_vertical = -1, horizontal = 0, vertical = 0;

	char instruction;
	int instruction_value;
	for (; std::cin >> instruction && std::cin >> instruction_value; !std::cin.eof() && std::cin.get())
	{
		if (instruction == 'L' || instruction == 'R')
		{
			const auto rotation = instruction == 'L' ? (360 - instruction_value) : instruction_value;
			for (int angle = 90; angle <= rotation; angle += 90)
			{
				const auto original_waypoint_horizontal = waypoint_horizontal;
				const auto original_waypoint_vertical = waypoint_vertical;
				waypoint_horizontal = -original_waypoint_vertical;
				waypoint_vertical = original_waypoint_horizontal;
			}
		}
		else if (instruction == 'F')
		{
			horizontal += instruction_value * waypoint_horizontal;
			vertical += instruction_value * waypoint_vertical;
		}
		else
		{
			waypoint_vertical += instruction == 'N' ? -1 * instruction_value : 0;
			waypoint_vertical += instruction == 'S' ? 1 * instruction_value : 0;
			waypoint_horizontal += instruction == 'E' ? 1 * instruction_value : 0;
			waypoint_horizontal += instruction == 'W' ? -1 * instruction_value : 0;
		}
	}

	horizontal = horizontal < 0 ? -horizontal : horizontal;
	vertical = vertical < 0 ? -vertical : vertical;
	return horizontal + vertical;
}