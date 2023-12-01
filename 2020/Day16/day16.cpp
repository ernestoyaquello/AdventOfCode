#include "day16.h"

int main()
{
	const auto start_time = std::chrono::steady_clock::now();

	const auto rules = read_field_rules();
	const auto tickets = read_tickets(rules);
	const auto result1 = part1(tickets);
	std::cout << "Part 1: " << result1 << std::endl;
	const auto result2 = part2(tickets);
	std::cout << "Part 2: " << result2 << std::endl;

	const auto end_time = std::chrono::steady_clock::now();
	const std::chrono::duration<double> elapsed_seconds = end_time - start_time;
	std::cout << "Elapsed time: " << elapsed_seconds.count() << "s" << std::endl;

	return 0;
}

unsigned int part1(std::vector<ticket_type> tickets)
{
	unsigned int sum_invalid = 0;
	for (const auto &ticket : tickets)
		for (const auto &field : ticket.fields)
			if (field.candidate_rules.size() == 0)
				sum_invalid += field.value;

	return sum_invalid;
}

unsigned long long part2(std::vector<ticket_type> tickets)
{
	// Discard invalid tickets straight away.
	for (std::size_t i = 0; i < tickets.size(); i++)
		for (const auto &field : tickets[i].fields)
			if (field.candidate_rules.size() == 0)
			{
				tickets.erase(tickets.begin() + i--);
				break;
			}

	// Remove invalid candidate rules by intersecting the rules of each equivalent field on every ticket.
	std::vector<std::set<std::string>> actual_field_names;
	for (std::size_t i = 0; i < tickets[0].fields.size(); i++)
	{
		std::set<std::string> field_names;
		for (const auto &candidate_rule : tickets[0].fields[i].candidate_rules)
			field_names.insert(candidate_rule.name);

		for (std::size_t j = 1; j < tickets.size() && field_names.size() > 1; j++)
		{
			std::set<std::string> other_field_names;
			for (const auto &candidate_rule : tickets[j].fields[i].candidate_rules)
				other_field_names.insert(candidate_rule.name);

			std::set<std::string> updated_field_names;
			std::set_intersection(field_names.begin(), field_names.end(), other_field_names.begin(), other_field_names.end(), std::inserter(updated_field_names, updated_field_names.begin()));
			field_names = updated_field_names;
		}

		actual_field_names.push_back(field_names);
	}

	// Remove remaining invalid rules by comparing different fields from different tickets.
	// If one field has candidate rules A and B, and another one only has A, we can infer
	// that the former field should only have rule B because A is already taken inconditionally.
	for (int count = 0; count < actual_field_names.size() - 1; count++)
		for (std::size_t i = 0; i < actual_field_names.size(); i++)
			if (actual_field_names[i].size() == 1)
			{
				for (std::size_t j = 0; j < actual_field_names.size(); j++)
				{
					if (actual_field_names[j].size() == 1)
						continue;

					std::set<std::string>::iterator it;
					if ((it = actual_field_names[j].find(*actual_field_names[i].begin())) != actual_field_names[j].end())
						actual_field_names[j].erase(it);
				}
			}

	// Set the rules back in the tickets.
	for (std::size_t i = 0; i < tickets.size(); i++)
		for (std::size_t j = 0; j < tickets[i].fields.size(); j++)
			for (std::size_t k = 0; k < tickets[i].fields[j].candidate_rules.size(); k++)
				if (tickets[i].fields[j].candidate_rules[k].name.compare(*actual_field_names[j].begin()) != 0)
					tickets[i].fields[j].candidate_rules.erase(tickets[i].fields[j].candidate_rules.begin() + k--);

	unsigned long long total = 1;
	for (std::size_t i = 0; i < tickets[0].fields.size(); i++)
		if (tickets[0].fields[i].candidate_rules[0].name.rfind("departure", 0) == 0)
			total *= tickets[0].fields[i].value;

	return total;
}

std::vector<field_rule_type> read_field_rules()
{
	std::vector<field_rule_type> rules;
	std::string line;
	std::getline(std::cin, line);
	while (line.compare("\n") != 0 && line.compare("") != 0)
	{
		field_rule_type rule;
		std::regex rgx("([\\w ]+): (\\d+)-(\\d+) or (\\d+)-(\\d+)");
		std::smatch matches;
		if (std::regex_search(line, matches, rgx) && matches.size() == 6)
		{
			rule.name = matches[1];
			rule.min_value1 = std::stoi(matches[2]);
			rule.max_value1 = std::stoi(matches[3]);
			rule.min_value2 = std::stoi(matches[4]);
			rule.max_value2 = std::stoi(matches[5]);
		}
		else break;

		rules.push_back(rule);
		std::getline(std::cin, line);
	}

	return rules;
}

std::vector<ticket_type> read_tickets(std::vector<field_rule_type> rules)
{
	std::vector<ticket_type> tickets;

	while (true) // Read ticket
	{
		while (!std::isdigit(std::cin.peek()) && std::cin.peek() != EOF) std::cin.get();
		if (std::cin.eof()) break;

		ticket_type ticket;
		unsigned int field_value;
		while (std::cin >> field_value) // Read field within ticket
		{
			ticket_field field;
			field.value = field_value;
			for (const auto rule : rules)
				if ((field_value >= rule.min_value1 && field_value <= rule.max_value1) ||
					field_value >= rule.min_value2 && field_value <= rule.max_value2)
					field.candidate_rules.push_back(rule);
			ticket.fields.push_back(field);

			if (std::cin.peek() == ',') std::cin.get();
			else break;
		}
		tickets.push_back(ticket);
	}

	return tickets;
}