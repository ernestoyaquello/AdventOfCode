#include "day15.h"

int main()
{
	const auto start_time = std::chrono::steady_clock::now();

	const auto numbers = read_numbers();
	const auto result1 = part1(numbers);
	std::cout << "Part 1: " << result1 << std::endl;
	const auto result2 = part2(numbers);
	std::cout << "Part 2: " << result2 << std::endl;

	const auto end_time = std::chrono::steady_clock::now();
	const std::chrono::duration<double> elapsed_seconds = end_time - start_time;
	std::cout << "Elapsed time: " << elapsed_seconds.count() << "s" << std::endl;

	return 0;
}

unsigned int part1(std::vector<unsigned int> numbers)
{
	return calculate_number(numbers, 2020);
}

unsigned int part2(std::vector<unsigned int> numbers)
{
	return calculate_number(numbers, 30000000);
}

std::vector<unsigned int> read_numbers()
{
	std::vector<unsigned int> numbers;

	while (!std::cin.eof())
	{
		int number;
		std::cin >> number;
		numbers.push_back(number);

		while (!std::cin.eof() && !std::isdigit(std::cin.peek()))
			std::cin.get();
	}

	return numbers;
}

unsigned int calculate_number(std::vector<unsigned int> numbers, std::size_t last_iteration)
{
	std::unordered_map<unsigned int, std::size_t> numbers_with_last_index;
	std::size_t iteration;
	for (iteration = 0; iteration < (numbers.size() - 1); iteration++)
		numbers_with_last_index[numbers[iteration]] = iteration;

	unsigned int number = 0, previous_number = numbers[iteration];
	while (++iteration < last_iteration)
	{
		const auto it = numbers_with_last_index.find(previous_number);
		number = it != numbers_with_last_index.end() ? (iteration - 1 - it->second) : 0;
		numbers_with_last_index[previous_number] = iteration - 1;
		previous_number = number;
	}

	return number;
}