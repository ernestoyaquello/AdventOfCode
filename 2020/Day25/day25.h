#include <iostream>
#include <vector>
#include <chrono>

std::vector<int> read_data();
unsigned long long part1(std::vector<int> data);
unsigned long long part2(std::vector<int> data);
unsigned long long find_loop_size(unsigned long long subject_number, unsigned long long goal_value);
unsigned long long apply_encryption(unsigned long long subject_number, unsigned long long loop_size);