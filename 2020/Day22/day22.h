#include <iostream>
#include <string>
#include <vector>
#include <algorithm>
#include <chrono>

std::vector<std::vector<int>> read_data();
unsigned long long part1(std::vector<std::vector<int>> players_cards);
unsigned long long part2(std::vector<std::vector<int>> players_cards);
std::pair<int, unsigned long long> play_game(std::vector<std::vector<int>>* players_cards, bool recursive_rules);