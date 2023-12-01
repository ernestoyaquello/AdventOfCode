#include <iostream>
#include <sstream>
#include <string>
#include <regex>

using namespace std;

void part1();
void part2();
int get_number_of_valid_passports(bool validate_data);
bool is_data_valid(char* field, string field_value);
bool is_year_valid(string year_string, int min_year, int max_year);
bool is_height_valid(string height_string);