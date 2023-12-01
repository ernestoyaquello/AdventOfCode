#include "day19.h"

int main()
{
	const auto start_time = std::chrono::steady_clock::now();

	unsigned long long total = 0;
	auto rules = read_rules(true); // False for part 1; true for part 2
	auto messages = read_messages();
	for (auto& message : messages)
	{
		auto combinations = std::vector<std::string>();
		combinations.push_back("");
		calculate_potential_combinations(&rules, rules[0], &message, &combinations);
		for (const auto& combination : combinations)
		{
			if (combination.compare(message) == 0)
			{
				total++;
				break;
			}
		}
	}
	std::cout << "Result: " << total << std::endl;

	free_memory(rules);
	const auto end_time = std::chrono::steady_clock::now();
	const std::chrono::duration<double> elapsed_seconds = end_time - start_time;
	std::cout << "Elapsed time: " << elapsed_seconds.count() << "s" << std::endl;

	return 0;
}

std::unordered_map<int, rule_type*> read_rules(bool is_part_2)
{
	std::unordered_map<int, rule_type*> rules;

	int loop_rule = 2000;
	while (std::cin.peek() != '\n')
	{
		auto rule = new rule_type();
		std::cin >> rule->number;
		std::cin.get();
		bool left = true;
		std::vector<int>* left_rules = NULL;
		std::vector<int>* right_rules = NULL;
		while (std::cin.peek() == ' ')
		{
			std::cin.get();
			if (isdigit(std::cin.peek()))
			{
				int number;
				std::cin >> number;
				left_rules = left_rules == NULL ? new std::vector<int>() : left_rules;
				if (left) left_rules->push_back(number);
				else right_rules->push_back(number);
			}
			else if (std::cin.peek() == '|')
			{
				std::cin.get();
				left = false;
				right_rules = new std::vector<int>();
			}
			else if (std::cin.peek() == '"')
			{
				std::cin.get();
				rule->character = std::cin.get();
				std::cin.get();
			}
		}
		if (left_rules != NULL)
		{
			rule->rule_sequences = new std::vector<std::vector<int>*>();
			rule->rule_sequences->push_back(left_rules);
			if (right_rules != NULL)
				rule->rule_sequences->push_back(right_rules);
		}
		if (is_part_2)
		{
			if (rule->number == 8)
			{
				right_rules = new std::vector<int>();
				right_rules->push_back(42);
				right_rules->push_back(8);
				rule->rule_sequences->push_back(right_rules);
			}
			else if (rule->number == 11)
			{
				right_rules = new std::vector<int>();
				right_rules->push_back(42);
				right_rules->push_back(11);
				right_rules->push_back(31);
				rule->rule_sequences->push_back(right_rules);
			}
		}

		std::cin.ignore();
		rules.insert(std::make_pair(rule->number, rule));
	}
	std::cin.get();

	return rules;
}

std::vector<std::string> read_messages()
{
	std::vector<std::string> lines;
	for (std::string line; !std::cin.eof() && std::getline(std::cin, line) && line.compare("") != 0; lines.push_back(line));
	return lines;
}

void calculate_potential_combinations(std::unordered_map<int, rule_type*>* rules, rule_type* rule, std::string* message, std::vector<std::string>* combinations)
{
	if (rule->character != '\0')
	{
		auto character_string = std::string(1, rule->character);
		if (combinations->size() > 0)
		{
			for (std::size_t i = 0; i < combinations->size(); i++)
			{
				const auto text = (*combinations)[i] + character_string;
				if (text.size() <= message->size() && message->rfind(text, 0) == 0)
					(*combinations)[i] = text;
				else
					combinations->erase(combinations->begin() + i--);
			}
		}
		else if ((*message)[0] == rule->character)
		{
			combinations->push_back(character_string);
		}
	}
	else
	{
		auto valid_combinations = std::vector<std::string>();

		for (std::size_t i = 0; i < rule->rule_sequences->size(); i ++)
		{
			const auto rule_sequence = (*rule->rule_sequences)[i];

			auto potential_combinations = std::vector<std::string>();
			for (const auto& combination : *combinations)
				if (combination.size() < message->size())
					potential_combinations.push_back(combination);

			if (potential_combinations.size() > 0)
			{
				for (std::size_t j = 0; j < rule_sequence->size(); j++)
				{
					calculate_potential_combinations(rules, (*rules)[(*rule_sequence)[j]], message, &potential_combinations);
					if (potential_combinations.size() == 0)
						break;
				}

				for (const auto& combination : potential_combinations)
					valid_combinations.push_back(combination);
			}
		}

		combinations->clear();
		for (const auto& combination : valid_combinations)
			combinations->push_back(combination);
	}
}

void free_memory(std::unordered_map<int, rule_type*> rules)
{
	for (const auto& rule : rules)
	{
		if (rule.second->rule_sequences != NULL)
		{
			for (const auto& rule_sequence : *rule.second->rule_sequences)
				delete rule_sequence;
			delete rule.second->rule_sequences;
		}
		delete rule.second;
	}
}