#include "day17.h"

int main()
{
	//std::cout << "Part 1: " << part1() << std::endl;
	std::cout << "Part 2: " << part2() << std::endl;
	return 0;
}

int part1()
{
	auto state = read_initial_state();
	auto iterations = 6;
	while (--iterations >= 0) state = calculate_next_iteration(&state);

	auto total_active = 0;
	for (int y = 0; y < state.size(); y++)
		for (int x = 0; x < state[y].size(); x++)
			for (int z = 0; z < state[y][x].size(); z++)
				total_active += state[y][x][z] == '#' ? 1 : 0;

	return total_active;
}

int part2()
{
	auto state_4d = read_initial_state_4d();
	auto iterations = 6;
	while (--iterations >= 0) state_4d = calculate_next_iteration_4d(&state_4d);

	auto total_active = 0;
	for (int y = 0; y < state_4d.size(); y++)
		for (int x = 0; x < state_4d[y].size(); x++)
			for (int z = 0; z < state_4d[y][x].size(); z++)
				for (int w = 0; w < state_4d[y][x][z].size(); w++)
					total_active += state_4d[y][x][z][w] == '#' ? 1 : 0;

	return total_active;
}

std::vector<std::vector<std::vector<char>>> read_initial_state()
{
	std::vector<std::vector<std::vector<char>>> state;
	for (std::string line; std::getline(std::cin, line) && line.compare("") != 0;)
	{
		std::vector<std::vector<char>> sub_matrix;
		for (std::size_t j = 0; j < line.size(); j++)
		{
			std::vector<char> sub_vector;
			sub_vector.push_back(line[j]);
			sub_matrix.push_back(sub_vector);
		}
		state.push_back(sub_matrix);
	}

	return state;
}

std::vector<std::vector<std::vector<char>>> calculate_next_iteration(std::vector<std::vector<std::vector<char>>>* old_state_ptr)
{
	std::size_t y_limit = old_state_ptr->size() + 2;
	std::size_t x_limit = (*old_state_ptr)[0].size() + 2;
	std::size_t z_limit = (*old_state_ptr)[0][0].size() + 2;

	std::vector<std::vector<std::vector<char>>> new_state;
	for (std::size_t y = 0; y < y_limit; y++)
	{
		std::vector<std::vector<char>> submatrix;
		for (std::size_t x = 0; x < x_limit; x++)
		{
			auto subvector = std::vector<char>(z_limit);
			submatrix.push_back(subvector);
		}
		new_state.push_back(submatrix);
	}

	for (int y = 0; y < y_limit; y++)
	{
		for (int x = 0; x < x_limit; x++)
		{
			for (int z = 0; z < z_limit; z++)
			{
				auto active_adyacent_count = 0;
				for (const auto &direction : adjacent_directions)
				{
					auto temp_y = y - 1 + std::get<0>(direction);
					auto temp_x = x - 1 + std::get<1>(direction);
					auto temp_z = z - 1 + std::get<2>(direction);
					active_adyacent_count += get_value(old_state_ptr, temp_y, temp_x, temp_z) == '#' ? 1 : 0;
				}

				auto cube_value = get_value(old_state_ptr, y - 1, x - 1, z - 1);
				if (cube_value == '#')
					new_state[y][x][z] = (active_adyacent_count == 2 || active_adyacent_count == 3) ? '#' : '.';
				else
					new_state[y][x][z] = active_adyacent_count == 3 ? '#' : '.';
			}
		}
	}

	return new_state;
}

char get_value(std::vector<std::vector<std::vector<char>>>* state_ptr, int y, int x, int z)
{
	if (y < 0 || y >= state_ptr->size()) return '.';
	if (x < 0 || x >= (*state_ptr)[y].size()) return '.';
	if (z < 0 || z >= (*state_ptr)[y][x].size()) return '.';

	return (*state_ptr)[y][x][z];
}

std::vector<std::vector<std::vector<std::vector<char>>>> read_initial_state_4d()
{
	std::vector<std::vector<std::vector<std::vector<char>>>> state;
	for (std::string line; std::getline(std::cin, line) && line.compare("") != 0;)
	{
		std::vector<std::vector<std::vector<char>>> sub_matrix;
		for (std::size_t j = 0; j < line.size(); j++)
		{
			std::vector<char> sub_sub_vector;
			sub_sub_vector.push_back(line[j]);
			std::vector<std::vector<char>> sub_vector;
			sub_vector.push_back(sub_sub_vector);
			sub_matrix.push_back(sub_vector);
		}
		state.push_back(sub_matrix);
	}

	return state;
}

std::vector<std::vector<std::vector<std::vector<char>>>> calculate_next_iteration_4d(std::vector<std::vector<std::vector<std::vector<char>>>>* old_state_ptr)
{
	std::size_t y_limit = old_state_ptr->size() + 2;
	std::size_t x_limit = (*old_state_ptr)[0].size() + 2;
	std::size_t z_limit = (*old_state_ptr)[0][0].size() + 2;
	std::size_t w_limit = (*old_state_ptr)[0][0][0].size() + 2;

	std::vector<std::vector<std::vector<std::vector<char>>>> new_state;
	for (std::size_t y = 0; y < y_limit; y++)
	{
		std::vector<std::vector<std::vector<char>>> submatrix;
		for (std::size_t x = 0; x < x_limit; x++)
		{
			std::vector<std::vector<char>> subvector;
			for (std::size_t z = 0; z < z_limit; z++)
			{
				auto subsubvector = std::vector<char>(w_limit);
				subvector.push_back(subsubvector);
			}
			submatrix.push_back(subvector);
		}
		new_state.push_back(submatrix);
	}

	for (int y = 0; y < y_limit; y++)
	{
		for (int x = 0; x < x_limit; x++)
		{
			for (int z = 0; z < z_limit; z++)
			{
				for (int w = 0; w < w_limit; w++)
				{
					auto active_adyacent_count = 0;
					for (const auto& direction_4d : adjacent_directions_4d)
					{
						auto temp_y = y - 1 + std::get<0>(direction_4d);
						auto temp_x = x - 1 + std::get<1>(direction_4d);
						auto temp_z = z - 1 + std::get<2>(direction_4d);
						auto temp_w = w - 1 + std::get<3>(direction_4d);
						active_adyacent_count += get_value_4d(old_state_ptr, temp_y, temp_x, temp_z, temp_w) == '#' ? 1 : 0;
					}

					auto cube_value = get_value_4d(old_state_ptr, y - 1, x - 1, z - 1, w - 1);
					if (cube_value == '#')
						new_state[y][x][z][w] = (active_adyacent_count == 2 || active_adyacent_count == 3) ? '#' : '.';
					else
						new_state[y][x][z][w] = active_adyacent_count == 3 ? '#' : '.';
				}
			}
		}
	}

	return new_state;
}

char get_value_4d(std::vector<std::vector<std::vector<std::vector<char>>>>* state_ptr, int y, int x, int z, int w)
{
	if (y < 0 || y >= state_ptr->size()) return '.';
	if (x < 0 || x >= (*state_ptr)[y].size()) return '.';
	if (z < 0 || z >= (*state_ptr)[y][x].size()) return '.';
	if (w < 0 || w >= (*state_ptr)[y][x][z].size()) return '.';

	return (*state_ptr)[y][x][z][w];
}