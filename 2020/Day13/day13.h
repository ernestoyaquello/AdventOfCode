#include <iostream>
#include <algorithm>
#include <vector>
#include <map>
#include <utility>
#include <chrono>

int part1();
unsigned long long part2();
std::vector<std::pair<unsigned short, unsigned int>> read_bus_ids_with_times(int min_time);
std::vector<std::pair<unsigned short, unsigned short>> read_bus_ids_with_offsets();