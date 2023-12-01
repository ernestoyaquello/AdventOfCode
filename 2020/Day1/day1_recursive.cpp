#include "day1_recursive.h"

int main()
{
	//part1();
	part2();

	return 0;
}

void part1()
{
	int solution = find_solution(2, 2020);
	cout << solution;
}

void part2()
{
	int solution = find_solution(3, 2020);
	cout << solution;
}

int find_solution(int number_of_numbers, int goal)
{
	vector<int> numbers = read_numbers();
	vector<int> indices_sequence(number_of_numbers);
	return find_solution_recursively(numbers, &indices_sequence, 0, goal);
}

vector<int> read_numbers()
{
	vector<int> numbers;
	int number;

	while (!cin.eof())
	{
		cin >> number;
		numbers.push_back(number);
	}

	return numbers;
}

int find_solution_recursively(const vector<int> numbers, vector<int>* indices_sequence, int level, int goal)
{
	int solution = -1;

	for (int i = 0; i < numbers.size(); i++)
	{
		bool is_in_sequence = find(begin(*indices_sequence), end(*indices_sequence), i) != end(*indices_sequence);
		if (is_in_sequence) continue;
		if (solution != -1) break;

		(*indices_sequence)[level] = i;
		if (level == (indices_sequence->size() - 1)) // Base case
		{
			int sum = 0;
			int mul = 1;
			for (int const& index : *indices_sequence)
			{
				int sequence_number = numbers[index];
				sum += sequence_number;
				mul *= sequence_number;
			}

			solution = sum == goal ? mul : solution;
		}
		else
		{
			solution = find_solution_recursively(numbers, indices_sequence, level + 1, goal);
		}
	}

	return solution;
}