#include "day25.h"

int main()
{
	const auto start_time = std::chrono::steady_clock::now();

	const auto data = read_data();
	std::cout << "Part 1: " << part1(data) << std::endl;
	//std::cout << "Part 2: " << part2(data) << std::endl;

	const auto end_time = std::chrono::steady_clock::now();
	const std::chrono::duration<double> elapsed_seconds = end_time - start_time;
	std::cout << "Elapsed time: " << elapsed_seconds.count() << "s" << std::endl;

	return 0;
}

std::vector<int> read_data()
{
	auto data = std::vector<int>();

	while (!std::cin.eof())
	{
		int public_key;
		if (std::cin >> public_key)
			data.push_back(public_key);
		std::cin.clear();
		while (std::cin.peek() == '\n') std::cin.get();
	}

	return data;
}

unsigned long long part1(std::vector<int> data)
{
	auto door_loop_size = find_loop_size(7, data[0]);
	auto result = apply_encryption(data[1], door_loop_size);

	return result;
}

unsigned long long part2(std::vector<int> data)
{
	// There was no part two :O
	return 0;
}

unsigned long long find_loop_size(unsigned long long subject_number, unsigned long long goal_value)
{
	unsigned long long loop_size = 0;
	unsigned long long value = 1;
	for (unsigned long long i = 0; true; i++)
	{
		loop_size++;
		value *= subject_number;
		value %= 20201227;
		if (value == goal_value)
			return loop_size;
	}

	return 0;
}

unsigned long long apply_encryption(unsigned long long subject_number, unsigned long long loop_size)
{
	unsigned long long value = 1;
	for (unsigned long long i = 0; i < loop_size; i++)
	{
		value *= subject_number;
		value %= 20201227;
	}

	return value;
}