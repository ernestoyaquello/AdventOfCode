#include "day1.h"

int main()
{
	//bool result = part1();
	bool result = part2();

	return result ? 0 : -1;
}

bool part1()
{
	vector<int> numbers;

	while (!cin.eof())
	{
		int number;
		cin >> number;

		for (auto const& previous_number : numbers)
		{
			if (previous_number + number == 2020)
			{
				cout << previous_number * number;
				return true;
			}
		}

		numbers.push_back(number);
	}

	return false;
}

bool part2()
{
	vector<int> numbers;

	while (!cin.eof())
	{
		int number;
		cin >> number;

		for (int i = 0; i < numbers.size(); i++)
		{
			for (int j = 0; j < numbers.size(); j++)
			{
				if (i == j) continue;

				int previous_number = numbers.at(i);
				int previous_number_2 = numbers.at(j);
				if (number + previous_number + previous_number_2 == 2020)
				{
					cout << number * previous_number * previous_number_2;
					return true;
				}
			}
		}

		numbers.push_back(number);
	}

	return false;
}