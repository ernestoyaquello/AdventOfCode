#include "day11.h"

int main()
{
	const auto layout = read_layout();
	std::cout << "Part 1: " << part1(layout) << std::endl;
	std::cout << "Part 2: " << part2(layout) << std::endl;
	return 0;
}

int part1(std::vector<std::string> layout)
{
	return count_occupied_seats_when_movement_stops(layout, 4, false);
}

int part2(std::vector<std::string> layout)
{
	return count_occupied_seats_when_movement_stops(layout, 5, true);
}

std::vector<std::string> read_layout()
{
	std::vector<std::string> layout;
	for (std::string line; std::getline(std::cin, line); layout.push_back(line));
	return layout;
}

int count_occupied_seats_when_movement_stops(std::vector<std::string> layout, int tolerance, bool look_further)
{
	std::vector<std::string> next_layout;
	while (!are_layouts_equal(&layout, &(next_layout = calculate_next_layout(&layout, tolerance, look_further))))
		layout = next_layout;

	auto total_occupied = 0;
	for (std::size_t i = 0; i < layout.size(); i++)
		for (std::size_t j = 0; j < layout[i].size(); j++)
			if (layout[i][j] == '#') total_occupied++;

	return total_occupied;
}

std::vector<std::string> calculate_next_layout(std::vector<std::string>* layout_ptr, int tolerance, bool look_further)
{
	std::vector<std::string> next_layout;
	for (std::size_t i = 0; i < layout_ptr->size(); i++)
	{
		std::string next_row = (*layout_ptr)[i];
		for (std::size_t j = 0; j < next_row.size(); j++)
		{
			auto character = next_row[j];
			if (character != '.')
			{
				const auto occupied_adjacent = count_occupied_adjacent(layout_ptr, i, j, look_further);
				if (character == 'L' && occupied_adjacent == 0) character = '#'; // Empty seat with no adjacent occupied seats becomes occupied
				if (character == '#' && occupied_adjacent >= tolerance) character = 'L'; // Occupied seat with <tolerance> or more adjacent occupied seats becomes empty
				next_row[j] = character;
			}
		}
		next_layout.push_back(next_row);
	}

	return next_layout;
}

int count_occupied_adjacent(std::vector<std::string>* layout_ptr, std::size_t i, std::size_t j, bool look_further)
{
	auto occupied_adyacent_count = 0;
	for (const auto direction : adjacent_directions)
		if (is_visible_seat_occupied(layout_ptr, i, j, direction.first, direction.second, look_further))
			occupied_adyacent_count++;

	return occupied_adyacent_count;
}

bool is_visible_seat_occupied(std::vector<std::string>* layout_ptr, std::size_t i, std::size_t j, int i_dir, int j_dir, bool look_further)
{
	const std::size_t limit_i = i_dir > 0 ? layout_ptr->size() : -1;
	const std::size_t limit_j = j_dir > 0 ? (*layout_ptr)[0].size() : -1;
	for (std::size_t next_i = i + i_dir, next_j = j + j_dir; next_i != limit_i && next_j != limit_j; next_i += i_dir, next_j += j_dir)
	{
		if ((*layout_ptr)[next_i][next_j] == '.')
		{
			if (!look_further) return false;
		}
		else return (*layout_ptr)[next_i][next_j] == '#';
	}

	return false;
}

bool are_layouts_equal(std::vector<std::string>* layout_ptr, std::vector<std::string>* other_layout_ptr)
{
	for (std::size_t i = 0; i < layout_ptr->size(); i++)
		for (std::size_t j = 0; j < (*layout_ptr)[i].size(); j++)
			if ((*layout_ptr)[i][j] != (*other_layout_ptr)[i][j])
				return false;

	return true;
}