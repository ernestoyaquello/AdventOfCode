#include <iostream>
#include <string>
#include <vector>
#include <map>
#include <algorithm>
#include <chrono>

const bool WHITE = false;
const bool BLACK = true;

const std::pair<int, int> adjacent_directions[6] = { { 2, 0 }, { 1, 2 }, { -1, 2 }, { -2, 0 }, { -1, -2 }, { 1, -2 } };

std::map<std::pair<int, int>, bool> read_tile_paths();
std::vector<std::vector<std::string>> read_tile_path_strings();
unsigned long long part1(std::map<std::pair<int, int>, bool> tiles);
unsigned long long part2(std::map<std::pair<int, int>, bool> tiles);
bool should_be_flipped(std::map<std::pair<int, int>, bool>* tiles, std::pair<int, int>* tile_position, bool tile_color);