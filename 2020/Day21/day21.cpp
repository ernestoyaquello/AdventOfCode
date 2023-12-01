#include "day21.h"

int main()
{
	const auto start_time = std::chrono::steady_clock::now();

	//std::cout << "Part 1: " << part1() << std::endl;
	std::cout << "Part 2: " << part2() << std::endl;

	const auto end_time = std::chrono::steady_clock::now();
	const std::chrono::duration<double> elapsed_seconds = end_time - start_time;
	std::cout << "Elapsed time: " << elapsed_seconds.count() << "s" << std::endl;

	return 0;
}

unsigned long long part1()
{
	auto data = read_data();
	auto ingredients_with_no_allergens = remove_impossible_alergens(&data);

	unsigned long long total = 0;
	for (const auto& ingredient : ingredients_with_no_allergens)
		for (const auto& food : data)
			for (const auto& inner_ingredient : food->ingredients)
				total += ingredient == inner_ingredient ? 1 : 0;

	free_memory(data);
	return total;
}

std::string part2()
{
	std::string result = "";

	auto data = read_data(); //TODO DELETE
	auto ingredients_with_no_allergens = remove_impossible_alergens(&data);
	for (const auto& food : data)
	{
		auto ingredients_to_remove = std::vector<ingredient_type*>();
		for (const auto& ingredient : food->ingredients)
			if (ingredient->candidate_alergens.size() == 0)
				ingredients_to_remove.push_back(ingredient);
		for (const auto& ingredient_to_remove : ingredients_to_remove)
		{
			for (const auto& inner_food : data)
			{
				const auto it = std::find(inner_food->ingredients.begin(), inner_food->ingredients.end(), ingredient_to_remove);
				if (it != inner_food->ingredients.end())
					inner_food->ingredients.erase(it);
			}
			delete ingredient_to_remove;
		}
	}

	if (calculate_correct_permutation(&data, data.begin(), 0))
	{
		auto dangerous_ingredients = std::vector<ingredient_type*>();
		for (const auto& food : data)
			for (const auto& ingredient : food->ingredients)
				if (std::find(dangerous_ingredients.begin(), dangerous_ingredients.end(), ingredient) == dangerous_ingredients.end())
					dangerous_ingredients.push_back(ingredient);
		std::sort(dangerous_ingredients.begin(), dangerous_ingredients.end(), compare_ingredients);		
		for (size_t i = 0; i < dangerous_ingredients.size(); i++)
			result += dangerous_ingredients[i]->name + ((i < (dangerous_ingredients.size() - 1)) ? "," : "");
	}

	free_memory(data);
	return result;
}

bool calculate_correct_permutation(std::vector<food_type*>* foods, std::vector<food_type*>::iterator food, int index)
{
	auto is_correct = false;

	auto candidate_allergens = std::set<std::string>((*food)->ingredients[index]->candidate_alergens);
	for (const auto& candidate_allergen : candidate_allergens)
	{
		(*food)->ingredients[index]->candidate_alergens.clear();
		(*food)->ingredients[index]->candidate_alergens.insert(candidate_allergen);
		
		is_correct = true;
		for (const auto& inner_food : *foods)
		{
			for (const auto& inner_food_allergen : inner_food->allergens)
			{
				auto allergen_is_found = false;
				for (const auto& inner_food_ingredient : inner_food->ingredients)
				{
					allergen_is_found = inner_food_ingredient->candidate_alergens.find(inner_food_allergen) != inner_food_ingredient->candidate_alergens.end();
					if (allergen_is_found)
						break;
				}
				if (!allergen_is_found)
				{
					is_correct = false;
					break;
				}
			}
			if (!is_correct)
				break;
		}
		
		if (is_correct)
		{
			if ((index + 1) < (*food)->ingredients.size())
				is_correct = calculate_correct_permutation(foods, food, index + 1);
			else if (++food != foods->end())
				is_correct = calculate_correct_permutation(foods, food, 0);
		}

		if (!is_correct)
		{
			(*food)->ingredients[index]->candidate_alergens.clear();
			copy(candidate_allergens.begin(), candidate_allergens.end(), std::inserter((*food)->ingredients[index]->candidate_alergens, (*food)->ingredients[index]->candidate_alergens.begin()));
		}
		else
		{
			break;
		}
	}

	return is_correct;
}

std::vector<food_type*> read_data()
{
	std::vector<food_type*> foods;

	while (std::cin.peek() != '\n' && std::cin.peek() != EOF)
	{
		auto food = new food_type();
		do
		{
			auto ingredient_name = std::string();
			std::cin >> ingredient_name;
			ingredient_type* ingredient = NULL;
			for (const auto& saved_food : foods)
			{
				for (const auto& saved_ingredient : saved_food->ingredients)
				{
					if (saved_ingredient->name.compare(ingredient_name) == 0)
					{
						// We reause this previously created ingredient because it is the same one
						ingredient = saved_ingredient;
						break;
					}
				}

				if (ingredient != NULL)
					break;
			}
			ingredient = ingredient == NULL ? new ingredient_type() : ingredient;
			ingredient->name = ingredient_name;
			std::cin.get();
			food->ingredients.push_back(ingredient);
		} while (std::cin.peek() != '(' && std::cin.peek() != '\n');

		if (std::cin.peek() == '(')
		{
			std::string _, allergen;
			std::cin >> _; // "(contains"
			while (std::cin.peek() != '\n')
			{
				std::cin >> allergen;
				if (allergen[allergen.size() - 1] == ',' || allergen[allergen.size() - 1] == ')')
					allergen.erase(allergen.end() - 1);
				food->allergens.insert(allergen);
				for (auto ingredient : food->ingredients)
					ingredient->candidate_alergens.insert(allergen);
				if (std::cin.peek() == ' ') std::cin.get();
			}
		}
		foods.push_back(food);

		if (std::cin.peek() == '\n')
			std::cin.get();
	}

	return foods;
}

std::set<ingredient_type*> remove_impossible_alergens(std::vector<food_type*>* foods)
{
	std::set<ingredient_type*> ingredients_with_no_allergens;

	for (size_t index = 0; index < foods->size(); index++)
	{
		for (const auto& food : *foods)
		{
			for (const auto& ingredient : food->ingredients)
			{
				if (ingredient->candidate_alergens.size() == 0)
					ingredients_with_no_allergens.insert(ingredient);

				for (auto it = ingredient->candidate_alergens.begin(); it != ingredient->candidate_alergens.end(); ++it)
				{
					for (const auto& inner_food : *foods)
					{
						if (inner_food == food) continue;
						if (inner_food->allergens.find(*it) == inner_food->allergens.end()) continue;

						auto ingredient_exists_in_food = false;
						for (const auto& inner_ingredient : inner_food->ingredients)
						{
							ingredient_exists_in_food |= inner_ingredient->name.compare(ingredient->name) == 0;
							if (ingredient_exists_in_food) break;
						}

						if (!ingredient_exists_in_food)
						{
							it = ingredient->candidate_alergens.erase(it);
							if (it != ingredient->candidate_alergens.end())
								--it;
							else if (ingredient->candidate_alergens.size() == 0)
								ingredients_with_no_allergens.insert(ingredient);
							break;
						}
					}

					if (it == ingredient->candidate_alergens.end())
						break;
				}
			}
		}
	}

	return ingredients_with_no_allergens;
}

bool compare_ingredients(const ingredient_type* a, const ingredient_type* b)
{
	return *a->candidate_alergens.begin() < *b->candidate_alergens.begin();
};

void free_memory(std::vector<food_type*> data)
{
	auto all_ingredients = std::set<ingredient_type*>();
	for (const auto& food : data)
		for (const auto& ingredient : food->ingredients)
				all_ingredients.insert(ingredient);
	for (const auto& ingredient : all_ingredients)
		delete ingredient;
	for (const auto& food : data)
		delete food;
}