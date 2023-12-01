#include <iostream>
#include <string>
#include <vector>
#include <unordered_map>
#include <algorithm>
#include <chrono>

struct rule_type
{
	int number = -1;
	std::vector<std::vector<int>*>* rule_sequences;
	char character = '\0';
};

std::unordered_map<int, rule_type*> read_rules(bool is_part_2);
std::vector<std::string> read_messages();
void calculate_potential_combinations(std::unordered_map<int, rule_type*>* rules, rule_type* rule, std::string* message, std::vector<std::string>* combinations);
void free_memory(std::unordered_map<int, rule_type*> rules);