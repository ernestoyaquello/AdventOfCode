#include <iostream>
#include <string>
#include <vector>
#include <map>
#include <set>
#include <algorithm>
#include <chrono>

struct ingredient_type
{
	std::string name;
	std::set<std::string> candidate_alergens;
};

struct food_type
{
	std::vector<ingredient_type*> ingredients;
	std::set<std::string> allergens;
};

unsigned long long part1();
std::string part2();
std::vector<food_type*> read_data();
std::set<ingredient_type*> remove_impossible_alergens(std::vector<food_type*>* foods);
bool calculate_correct_permutation(std::vector<food_type*>* foods, std::vector<food_type*>::iterator food, int index);
bool compare_ingredients(const ingredient_type* a, const ingredient_type* b);
void free_memory(std::vector<food_type*> data);