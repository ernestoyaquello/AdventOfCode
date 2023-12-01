#include <iostream>
#include <string>
#include <vector>
#include <algorithm>
#include <chrono>

std::vector<int> read_cups();
std::string part1(std::vector<int> cups);
unsigned long long part2(std::vector<int> cups);
std::vector<int> play_game(std::vector<int> cups, unsigned long number_of_rounds);