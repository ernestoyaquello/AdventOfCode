#include "day23.h"

int main()
{
	const auto start_time = std::chrono::steady_clock::now();

	const auto cups = read_cups();
	std::cout << "Part 1: " << part1(cups) << std::endl;
	std::cout << "Part 2: " << part2(cups) << std::endl;

	const auto end_time = std::chrono::steady_clock::now();
	const std::chrono::duration<double> elapsed_seconds = end_time - start_time;
	std::cout << "Elapsed time: " << elapsed_seconds.count() << "s" << std::endl;

	return 0;
}

std::vector<int> read_cups()
{
	auto cups = std::vector<int>();
	for (int number = 0; std::isdigit(std::cin.peek()) && (number = std::cin.get() - '0'); )
		cups.push_back(number);
	std::cin.clear();
	std::cin.ignore();

	return cups;
}

std::string part1(std::vector<int> cups)
{
	const auto final_cups = play_game(cups, 100);
	std::string result = "";
	for (std::size_t i = 0; i < final_cups.size(); i++)
	{
		if (final_cups[i] == 1)
		{
			for (std::size_t j = 0; j < (final_cups.size() - 1); j++)
				result += std::to_string(final_cups[(j + i + 1) % final_cups.size()]);
			break;
		}
	}

	return result;
}

unsigned long long part2(std::vector<int> cups)
{
	auto max_cup_label = 0;
	for (const auto& cup : cups)
		max_cup_label = cup > max_cup_label ? cup : max_cup_label;
	for (auto label = max_cup_label + 1L; label <= 1000000; label++)
		cups.push_back(label);

	const auto final_cups = play_game(cups, 10000000);

	unsigned long long result = 0;
	for (std::size_t i = 0; result == 0 && i < final_cups.size(); i++)
		if (final_cups[i] == 1)
			result = (unsigned long long)final_cups[(i + 1) % final_cups.size()] * (unsigned long long)final_cups[(i + 2) % final_cups.size()];
	return result;
}

std::vector<int> play_game(std::vector<int> cups, unsigned long number_of_rounds)
{
	const auto number_of_cups = cups.size();
	auto lowest_cup_label = 10;
	auto highest_cup_label = 0;
	auto destination_cup_index = 0;
	for (const auto& cup_label : cups)
	{
		lowest_cup_label = cup_label < lowest_cup_label ? cup_label : lowest_cup_label;
		highest_cup_label = cup_label > highest_cup_label ? cup_label : highest_cup_label;
	}

	for (auto round = 1; round <= number_of_rounds; round++)
	{
		const auto current_cup_index = (round - 1) % number_of_cups;
		auto destination_cup_label = cups[current_cup_index] - 1;

		// Pick up cups, removing them from the circle
		auto picked_cups = std::vector<int>();
		if ((current_cup_index + 4) <= number_of_cups)
		{
			picked_cups = std::vector<int>(cups.begin() + current_cup_index + 1, cups.begin() + current_cup_index + 4);
			cups.erase(cups.begin() + current_cup_index + 1, cups.begin() + current_cup_index + 4);
		}
		else
		{
			for (auto pick_up_index = 1L; pick_up_index <= 3; pick_up_index++)
			{
				const auto picked_cup_index = (current_cup_index + pick_up_index) % number_of_cups;
				const auto picked_cup_label = cups[picked_cup_index];
				picked_cups.push_back(picked_cup_label);
			}
			for (auto aux = (current_cup_index + 1) % number_of_cups; cups.size() > (number_of_cups - 3); aux = aux >= cups.size() ? 0 : aux)
				cups.erase(cups.begin() + aux);
		}

		// Select the destination cup
		while (destination_cup_label < lowest_cup_label || std::find(picked_cups.begin(), picked_cups.end(), destination_cup_label) != picked_cups.end())
		{
			if (--destination_cup_label < lowest_cup_label)
				destination_cup_label = highest_cup_label;
		}
		if (destination_cup_index >= cups.size() || cups[destination_cup_index] != destination_cup_label)
			destination_cup_index = std::find(cups.begin(), cups.end(), destination_cup_label) - cups.begin();

		// Insert the picked up cups after the destination cup
		const auto after_destination_cup_index = destination_cup_index + 1;
		cups.insert(cups.begin() + after_destination_cup_index, picked_cups.begin(), picked_cups.end());

		// If necessary, shift the cups to ensure the next destination cup will be placed at the expected position
		const auto next_current_cup_index = (current_cup_index + 1) % number_of_cups;
		if (after_destination_cup_index <= next_current_cup_index)
		{
			const auto shifting_needed = number_of_cups - next_current_cup_index > 3 ? 3 : number_of_cups - next_current_cup_index;
			const auto cups_to_move = std::vector<int>(cups.begin(), cups.begin() + shifting_needed);
			cups.erase(cups.begin(), cups.begin() + shifting_needed);
			cups.insert(cups.end(), cups_to_move.begin(), cups_to_move.end());
		}
	}

	return cups;
}