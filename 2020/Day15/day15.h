#include <iostream>
#include <cctype>
#include <unordered_map>
#include <vector>
#include <chrono>

unsigned int part1(std::vector<unsigned int> numbers);
unsigned int part2(std::vector<unsigned int> numbers);
std::vector<unsigned int> read_numbers();
unsigned int calculate_number(std::vector<unsigned int> numbers, std::size_t last_iteration);