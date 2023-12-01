#include <iostream>
#include <string>
#include <vector>
#include <utility>

const std::pair<int, int> adjacent_directions[8] = { {-1, -1}, {-1, 0}, {-1, 1}, {0, -1}, {0, 1}, {1, -1}, {1, 0}, {1, 1} };

int part1(std::vector<std::string> layout);
int part2(std::vector<std::string> layout);
std::vector<std::string> read_layout();
int count_occupied_seats_when_movement_stops(std::vector<std::string> layout, int tolerance = 4, bool look_further = false);
std::vector<std::string> calculate_next_layout(std::vector<std::string>* layout_ptr, int tolerance, bool look_further);
int count_occupied_adjacent(std::vector<std::string>* layout_ptr, std::size_t i, std::size_t j, bool look_further);
bool is_visible_seat_occupied(std::vector<std::string>* layout_ptr, std::size_t i, std::size_t j, int i_dir, int j_dir, bool look_further);
bool are_layouts_equal(std::vector<std::string>* layout_ptr, std::vector<std::string>* other_layout_ptr);