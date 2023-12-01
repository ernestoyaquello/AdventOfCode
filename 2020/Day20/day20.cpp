#include "day20.h"

int main()
{
	const auto start_time = std::chrono::steady_clock::now();

	auto width = 0;
	auto tiles = read_tiles(&width);
	auto final_layout = std::vector<std::string>();
	std::cout << "Part 1: " << part1(&tiles, &final_layout, width) << std::endl;
	std::cout << "Part 2: " << part2(&final_layout) << std::endl;

	for (const auto& tile : tiles)
	{
		for (const auto& line : *tile->original_layout)
			delete line;
		for (const auto& line : *tile->layout)
			delete line;
		for (const auto& candidates : *tile->candidate_tiles)
			delete candidates;
		delete tile->candidate_tiles;
		delete tile->original_layout;
		delete tile->layout;
		delete tile->edge_hashes;
		delete tile;
	}

	const auto end_time = std::chrono::steady_clock::now();
	const std::chrono::duration<double> elapsed_seconds = end_time - start_time;
	std::cout << "Elapsed time: " << elapsed_seconds.count() << "s" << std::endl;

	return 0;
}

unsigned long long part1(std::vector<tile_type*>* tiles, std::vector<std::string>* final_layout, int width)
{
	unsigned long long total = 1;

	auto positions = std::vector<tile_type*>(width * width, NULL);
	auto candidate_tiles = std::set<tile_type*>();
	std::copy(tiles->begin(), tiles->end(), inserter(candidate_tiles, candidate_tiles.begin()));
	auto found_permutation = find_valid_permutation(&candidate_tiles, &positions, width, 0, 0);
	if (found_permutation)
	{
		total *= positions[0]->number;
		total *= positions[width - 1]->number;
		total *= positions[width * (width - 1)]->number;
		total *= positions[(width * width) - 1]->number;

		// Create new layout
		const auto layout_size = positions[0]->layout->size();
		const auto limit = width * layout_size;
		for (size_t i = 0; i < limit; i++)
		{
			std::string line = "";
			for (size_t j = 0; j < limit; j++)
			{
				const auto processed_i = i % layout_size;
				const auto processed_j = j % layout_size;
				if (processed_i == 0 || processed_i == (layout_size - 1) || processed_j == 0 || processed_j == (layout_size - 1))
					continue;

				const auto& tile = positions[(i / layout_size * width) + (j / layout_size)];
				line += std::string(1, (*(*tile->layout)[processed_i])[processed_j]);
			}
			if (line.compare("") != 0)
				final_layout->push_back(line);
		}
	}
	else
	{
		total = 0;
	}

	return total;
}

unsigned long long part2(std::vector<std::string>* final_layout)
{
	auto mosnter_pattern = std::vector<std::string>();
	mosnter_pattern.push_back(std::string("                  # "));
	mosnter_pattern.push_back(std::string("#    ##    ##    ###"));
	mosnter_pattern.push_back(std::string(" #  #  #  #  #  #   "));
	const auto monster_pattern_height = mosnter_pattern.size();
	const auto monster_pattern_width = mosnter_pattern[0].size();

	auto layout = std::vector<std::string>();
	auto found_hashes = std::map<int, bool>();
	for (size_t i = 0; i < final_layout->size(); i++)
	{
		layout.push_back(std::string(""));
		for (size_t j = 0; j < final_layout->size(); j++)
		{
			const auto& picture_character = (*final_layout)[i][j];
			layout[i].push_back(picture_character);
			if (picture_character == '#')
				found_hashes.insert(std::make_pair((i * final_layout->size()) + j, false));
		}
	}

	auto monsters_found = false;
	for (int rotation = 0; !monsters_found && rotation < 4; rotation++)
	{
		auto layout_updated = false;
		if (rotation != 0)
		{
			for (std::size_t i = 0; i < final_layout->size(); i++)
				for (std::size_t j = 0; j < (*final_layout)[0].size(); j++)
					layout[i][j] = (*final_layout)[final_layout->size() - j - 1][i];
			*final_layout = layout;
			layout_updated = true;
		}

		for (int flipping = 0; !monsters_found && flipping < 4; flipping++)
		{
			if (flipping != 0)
			{
				const auto flipped_horizontal = flipping == 1 || flipping == 2 || flipping == 3;
				if (flipped_horizontal)
					for (std::size_t i = 0; i < layout.size(); i++)
						for (std::size_t j = 0; j < (layout[0].size() / 2); j++)
							std::iter_swap(layout[i].begin() + j, layout[i].begin() + (layout[i].size() - j - 1));

				const auto flipped_vertical = flipping == 2;
				if (flipped_vertical)
					for (std::size_t i = 0; i < (layout.size() / 2); i++)
						std::iter_swap(layout.begin() + i, layout.begin() + (layout.size() - i - 1));

				layout_updated = true;
			}

			if (layout_updated)
			{
				found_hashes.clear();
				for (size_t i = 0; i < layout.size(); i++)
					for (size_t j = 0; j < layout.size(); j++)
						if (layout[i][j] == '#')
							found_hashes.insert(std::make_pair((i * layout.size()) + j, false));
			}

			for (size_t i = 0; i <= layout.size() - monster_pattern_height; i++)
			{
				for (size_t j = 0; j <= layout.size() - monster_pattern_width; j++)
				{
					auto is_monster = true;
					auto monster_hashes = std::map<int, bool>();
					for (size_t k = 0; is_monster && k < monster_pattern_height; k++)
					{
						for (size_t w = 0; is_monster && w < monster_pattern_width; w++)
						{
							const auto& picture_character = layout[i + k][j + w];
							const auto& monster_character = mosnter_pattern[k][w];
							is_monster = monster_character != '#' || picture_character == monster_character;
							if (picture_character == '#' && picture_character == monster_character)
								monster_hashes.insert(std::make_pair(((i + k) * layout.size()) + (j + w), true));
						}
					}
					monsters_found |= is_monster;
					if (is_monster)
						for (const auto& monster_hash_pair : monster_hashes)
							found_hashes[monster_hash_pair.first] = monster_hash_pair.second;
				}
			}
		}
	}

	unsigned long long non_monster_hashes = 0;
	for (const auto& found_hashes_pair : found_hashes)
		if (!found_hashes_pair.second)
			non_monster_hashes++;

	return non_monster_hashes;
}

// TODO Break this down into functions
std::vector<tile_type*> read_tiles(int* width)
{
	auto number_of_layouts = 0;
	auto unfiltered_tiles = std::vector<tile_type*>();
	auto tiles = std::vector<tile_type*>();
	std::string _;
	while (!std::cin.eof()) // Outer loop (iterates over all tiles)
	{
		while (!std::cin.eof()) // Inner loop (one tile per iteration)
		{
			number_of_layouts++;
			auto number = 0;
			auto original_layout = std::vector<std::string*>();
			std::cin >> _ >> number >> _;
			std::cin.get();
			while (std::cin.peek() == '#' || std::cin.peek() == '.')
			{
				auto line = new std::string();
				std::getline(std::cin, *line);
				original_layout.push_back(line);
			}
			
			// We store different versions of the layout (rotated, flipped, etc.)
			for (const auto& rotation : { 0, 1, 2, 3 })
			{
				for (const auto flipping : { 0, 1, 2, 3 })
				{
					auto tile = new tile_type();
					tile->number = number;
					tile->rotation = rotation;
					tile->flipping = flipping;
					tile->original_layout = new std::vector<std::string*>();
					tile->layout = new std::vector<std::string*>();
					tile->edge_hashes = new std::vector<std::size_t>();

					for (const auto& line : original_layout)
					{
						tile->original_layout->push_back(new std::string(*line));
						tile->layout->push_back(new std::string(*line));
					}

					for (int rot = 0; rot < rotation; rot++)
						for (std::size_t i = 0; i < tile->original_layout->size(); i++)
							for (std::size_t j = 0; j < (*tile->original_layout)[0]->size(); j++)
								(*(*tile->layout)[i])[j] = (*(*tile->original_layout)[tile->original_layout->size() - j - 1])[i];

					const auto flipped_horizontal = flipping == 1 || flipping == 3;
					if (flipped_horizontal)
						for (std::size_t i = 0; i < tile->layout->size(); i++)
							for (std::size_t j = 0; j < ((*tile->layout)[0]->size() / 2); j++)
								std::iter_swap((*tile->layout)[i]->begin() + j, (*tile->layout)[i]->begin() + ((*tile->layout)[i]->size() - j - 1));

					const auto flipped_vertical = flipping == 2 || flipping == 3;
					if (flipped_vertical)
						for (std::size_t i = 0; i < (tile->layout->size() / 2); i++)
							std::iter_swap(tile->layout->begin() + i, tile->layout->begin() + (tile->layout->size() - i - 1));

					auto top_line = std::string(*(*tile->layout)[0]);
					auto bottom_line = std::string(*(*tile->layout)[tile->layout->size() - 1]);
					auto left_line = std::string();
					auto right_line = std::string();
					for (const auto& line : *tile->layout)
					{
						left_line.push_back((*line)[0]);
						right_line.push_back((*line)[line->size() - 1]);
					}
					for (const auto& line : { top_line, right_line, bottom_line, left_line })
					{
						auto hasher = std::hash<std::string>();
						tile->edge_hashes->push_back(hasher(line));
					}

					unfiltered_tiles.push_back(tile);
				}
			}

			for (const auto& line : original_layout)
				delete line;
		}

		while (std::cin.peek() == '\n')
			std::cin.get();
	}

	// Remove layouts that are equal after the transformations
	for (size_t i = 0; i < unfiltered_tiles.size(); i++)
	{
		const auto& tile = unfiltered_tiles[i];
		for (size_t j = i + 1; j < unfiltered_tiles.size(); j++)
		{
			const auto& other_tile = unfiltered_tiles[j];
			if (tile->number == other_tile->number)
			{
				auto are_equal = true;
				for (size_t k = 0; are_equal && k < tile->layout->size(); k++)
					for (size_t w = 0; are_equal && w < other_tile->layout->size(); w++)
						are_equal = (*(*tile->layout)[k])[w] == (*(*other_tile->layout)[k])[w];
				if (are_equal)
				{
					unfiltered_tiles.erase(unfiltered_tiles.begin() + j);
					j--;
				}
			}
		}
	}

	// For each tile, we find the candidate tiles that can be placed next to them in any of the four available positions
	for (const auto& tile : unfiltered_tiles)
	{
		tile->candidate_tiles = new std::vector<std::vector<tile_type*>*>();
		for (std::size_t position = 0; position < tile->edge_hashes->size(); position++)
		{
			auto candidates = new std::vector<tile_type*>();
			for (const auto& other_tile : unfiltered_tiles)
			{
				if (other_tile->number == tile->number)
					continue;

				bool is_valid = (*other_tile->edge_hashes)[(position + 2) % 4] == (*tile->edge_hashes)[position];
				if (is_valid)
				{
					candidates->push_back(other_tile);
					if (std::find(tiles.begin(), tiles.end(), other_tile) == tiles.end())
						tiles.push_back(other_tile);
				}
			}
			tile->candidate_tiles->push_back(candidates);
		}
	}

	*width = (int)std::sqrt(number_of_layouts);

	return tiles;
}

bool find_valid_permutation(std::set<tile_type*>* candidate_tiles, std::vector<tile_type*>* positions, int width, int y, int x)
{
	const auto index = (y * width) + x;
	for (const auto& candidate_tile : *candidate_tiles)
	{
		(*positions)[index] = candidate_tile;

		const auto next_x = (x + 1) % width;
		const auto next_y = next_x != 0 ? y : y + 1;
		auto next_candidates = std::set<tile_type*>();
		for (int dir_index = 3; dir_index >= 0; dir_index -= 3)
		{
			const auto& next_neighbour_direction = adjacent_directions[1 - (dir_index / 3)];
			const auto neighbour_y = next_y + next_neighbour_direction.first;
			const auto neighbour_x = next_x + next_neighbour_direction.second;
			const auto neighbour_index = (neighbour_y * width) + neighbour_x;
			if (neighbour_y < 0 || neighbour_x < 0)
				continue;

			const auto& neighbour = (*positions)[neighbour_index];
			if (neighbour == NULL)
				continue;

			const auto& candidates = (*neighbour->candidate_tiles)[(dir_index + 2) % 4];
			if (candidates->size() == 0)
				break;

			next_candidates.insert(candidates->begin(), candidates->end());
		}

		const auto is_valid = next_y == width || (next_candidates.size() > 0 && find_valid_permutation(&next_candidates, positions, width, next_y, next_x));
		if (is_valid)
			return true;
		else
			(*positions)[index] = NULL;
	}

	return false;
}