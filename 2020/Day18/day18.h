#include <iostream>
#include <sstream>
#include <string>
#include <vector>
#include <utility>

struct expression_type
{
	expression_type* left = NULL;
	expression_type* right = NULL;
	char operation = '\0';
	unsigned long long value = 0;
};

unsigned long long part1();
unsigned long long part2();

expression_type* calculate_expression_tree(std::string line);
unsigned long long calculate_result(expression_type* tree);

std::string add_preference_parentheses(std::string line);
std::string remove_unnecessary_parentheses(std::string line);
std::size_t find_closing_parentheses_index(std::size_t opening_parentheses_index, std::string line);
std::size_t find_opening_parentheses_index(std::size_t closing_parentheses_index, std::string line);

void free_memory(expression_type* tree);