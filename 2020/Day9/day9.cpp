#include "day9.h"

int main()
{
	//int result = part1();
	int result = part2();
	cout << result;

	return 0;
}

int part1()
{
	vector<int> read_numbers = read_until_invalid_number();
	return read_numbers[read_numbers.size() - 1];
}

int part2()
{
	vector<int> read_numbers = read_until_invalid_number();
	int goal_number = read_numbers[read_numbers.size() - 1];
	for (int i = 0; i < read_numbers.size() - 1; i++)
	{
		int acc = read_numbers[i];
		int i_offset = 1;
		while ((acc += read_numbers[i + i_offset++]) < goal_number);
		if (acc == goal_number)
		{
			int min = INT_MAX, max = INT_MIN;
			for (int j = i; j < (i + i_offset); j++)
			{
				if (read_numbers[j] > max) max = read_numbers[j];
				if (read_numbers[j] < min) min = read_numbers[j];
			}

			return min + max;
		}
	}

	return 0;
}

vector<int> read_until_invalid_number()
{
	int number, position = 0;
	int preamble[preamble_size]{};
	vector<int> all_numbers;

	while (cin >> number)
	{
		all_numbers.push_back(number);
		int preamble_position = position < preamble_size ? position : preamble_size - 1;

		// If the preamble isn't full yet, the number will be valid automatically; otherwise, we verify it is
		bool is_valid = preamble_position == position;
		for (int i = 0; !is_valid && i <= preamble_position; i++)
			for (int j = 0; !is_valid && j <= preamble_position; j++)
					is_valid = preamble[i] + preamble[j] == number && i != j;

		// Found the invalid number, we stop reading now
		if (!is_valid) break;

		// If necessary, shift the preamble numbers to accomodate for the new one
		if (position++ >= preamble_size)
			for (int i = 0; i < (preamble_size - 1); i++)
				preamble[i] = preamble[i + 1];

		preamble[preamble_position] = number;
	}

	return all_numbers;
}