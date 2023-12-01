#include <iostream>
#include <cctype>
#include <string>
#include <vector>
#include <set>
#include <regex>
#include <chrono>

struct field_rule_type
{
	std::string name;
	unsigned int min_value1;
	unsigned int max_value1;
	unsigned int min_value2;
	unsigned int max_value2;
};

struct ticket_field
{
	unsigned int value;
	std::vector<field_rule_type> candidate_rules;
};

struct ticket_type
{
	std::vector<ticket_field> fields;
};

unsigned int part1(std::vector<ticket_type> tickets);
unsigned long long part2(std::vector<ticket_type> tickets);
std::vector<field_rule_type> read_field_rules();
std::vector<ticket_type> read_tickets(std::vector<field_rule_type> rules);