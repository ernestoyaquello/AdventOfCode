#include <iostream>
#include <sstream>
#include <string>
#include <vector>
#include <map>
#include <cmath>
#include <chrono>

unsigned long long part1();
unsigned long long part2();
std::map<unsigned long long, unsigned long long> read_memory(bool use_address_decoder);
std::vector<unsigned long long> get_decoded_addresses(unsigned long long address, std::string mask, std::size_t index);