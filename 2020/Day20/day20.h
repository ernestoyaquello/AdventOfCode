#include <iostream>
#include <string>
#include <vector>
#include <map>
#include <set>
#include <algorithm>
#include <chrono>

struct tile_type
{
	unsigned long long number;
	std::vector<std::string*>* original_layout;
	std::vector<std::string*>* layout;
	std::vector<std::size_t>* edge_hashes;
	std::vector<std::vector<tile_type*>*>* candidate_tiles;
	int rotation = 0;
	int flipping = 0;
};

const std::pair<int, int> adjacent_directions[2] = { {0, -1}, {-1, 0}, };

unsigned long long part1(std::vector<tile_type*>* tiles, std::vector<std::string>* final_layout, int width);
unsigned long long part2(std::vector<std::string>* final_layout);
std::vector<tile_type*> read_tiles(int* width);
bool find_valid_permutation(std::set<tile_type*>* candidate_tiles, std::vector<tile_type*>* positions, int width, int y, int x);