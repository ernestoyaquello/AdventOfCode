#include "day24.h"

int main()
{
	const auto start_time = std::chrono::steady_clock::now();

	const auto tiles = read_tile_paths();
	std::cout << "Part 1: " << part1(tiles) << std::endl;
	std::cout << "Part 2: " << part2(tiles) << std::endl;

	const auto end_time = std::chrono::steady_clock::now();
	const std::chrono::duration<double> elapsed_seconds = end_time - start_time;
	std::cout << "Elapsed time: " << elapsed_seconds.count() << "s" << std::endl;

	return 0;
}

std::map<std::pair<int, int>, bool> read_tile_paths()
{
	const auto tile_path_strings = read_tile_path_strings();
	auto tiles = std::map<std::pair<int, int>, bool>();
	tiles.insert(std::make_pair(std::make_pair(0, 0), WHITE));

	for (const auto& tile_path_string : tile_path_strings)
	{
		auto position = std::make_pair(0, 0);
		for (const auto& direction : tile_path_string)
		{
			if (direction.compare("e") == 0)
			{
				position.first += 2;
			}
			else if (direction.compare("se") == 0)
			{
				position.second += 2;
				position.first += 1;
			}
			else if (direction.compare("sw") == 0)
			{
				position.second += 2;
				position.first -= 1;
			}
			else if (direction.compare("w") == 0)
			{
				position.first -= 2;
			}
			else if (direction.compare("nw") == 0)
			{
				position.second -= 2;
				position.first -= 1;
			}
			else if (direction.compare("ne") == 0)
			{
				position.second -= 2;
				position.first += 1;
			}

			if (tiles.find(position) == tiles.end())
				tiles.insert(std::make_pair(position, WHITE));
		}
		if (tiles.find(position) == tiles.end())
			tiles.insert(std::make_pair(position, BLACK));
		else
			tiles[position] = !tiles[position];
	}

	return tiles;
}

std::vector<std::vector<std::string>> read_tile_path_strings()
{
	auto tile_path_strings = std::vector<std::vector<std::string>>();

	while (!std::cin.eof())
	{
		auto tile_path = std::vector<std::string>();
		while (std::isalpha(std::cin.peek()))
		{
			const auto new_letter = std::cin.get();			
			if (new_letter == 'e' || new_letter == 'w')
			{
				tile_path.push_back(std::string(1, new_letter));
			}
			else
			{
				auto direction = std::string(1, new_letter);
				direction += std::string(1, std::cin.get());
				tile_path.push_back(direction);
			}
		}
		tile_path_strings.push_back(tile_path);

		while (std::cin.peek() == '\n')
			std::cin.get();
	}

	return tile_path_strings;
}

unsigned long long part1(std::map<std::pair<int, int>, bool> tiles)
{
	unsigned long long black_number = 0;
	for (const auto& tile : tiles)
		black_number += tile.second == BLACK ? 1 : 0;

	return black_number;
}

unsigned long long part2(std::map<std::pair<int, int>, bool> tiles)
{
	for (int day = 1; day <= 100; day++)
	{
		auto new_tiles = std::map<std::pair<int, int>, bool>();
		for (const auto& tile_data : tiles)
		{
			auto tile_position = tile_data.first;
			auto tile_color = tile_data.second;
			if (should_be_flipped(&tiles, &tile_position, tile_color))
				new_tiles.insert(std::make_pair(tile_position, !tile_color));
			else
				new_tiles.insert(tile_data);
			
			for (const auto& adjacent_direction : adjacent_directions)
			{
				auto new_tile_position = std::make_pair(tile_position.first + adjacent_direction.first, tile_position.second + +adjacent_direction.second);
				if (tiles.find(new_tile_position) == tiles.end())
					if (should_be_flipped(&tiles, &new_tile_position, WHITE))
						new_tiles.insert(std::make_pair(new_tile_position, BLACK));
			}
		}
		tiles = new_tiles;
	}

	unsigned long long black_number = 0;
	for (const auto& tile : tiles)
		black_number += tile.second == BLACK ? 1 : 0;

	return black_number;
}

bool should_be_flipped(std::map<std::pair<int, int>, bool>* tiles, std::pair<int, int>* tile_position, bool tile_color)
{
	auto is_flippable = false;
	auto black_adjacent = 0;

	for (const auto& adjacent_direction : adjacent_directions)
	{
		const auto adjacent_position = std::make_pair(tile_position->first + adjacent_direction.first, tile_position->second + +adjacent_direction.second);
		const auto adjacent_tile_it = tiles->find(adjacent_position);
		black_adjacent += adjacent_tile_it != tiles->end() && adjacent_tile_it->second == BLACK ? 1 : 0;
		if (black_adjacent > 2 && tile_color == WHITE)
			return false;
	}

	return (tile_color == WHITE && black_adjacent == 2) || (tile_color == BLACK && (black_adjacent == 0 || black_adjacent > 2));
}