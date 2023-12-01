#include "day6.h"

int main()
{
	//part1();
	part2();

	return 0;
}

void part1()
{
	int totals = read_grouped_answers_anyone_totals();
	cout << totals;
}

void part2()
{
	int totals = read_grouped_answers_everyone_totals();
	cout << totals;
}

int read_grouped_answers_anyone_totals()
{
	int total_yesses = 0;

	while (!cin.eof())
	{
		set<char> group_letters;
		while (!cin.eof())
		{
			group_letters.insert(cin.get());
			if (cin.peek() == '\n' && cin.get())
			{
				if (cin.peek() == '\n' && cin.get()) break;
			}
		}

		total_yesses += group_letters.size();
	}

	return total_yesses;
}

int read_grouped_answers_everyone_totals()
{
	int total_yesses = 0;

	while (!cin.eof())
	{
		set<char> group_letters { 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z' };
		set<char> person_letters;

		while (!cin.eof())
		{
			person_letters.insert(cin.get());
			if (cin.peek() == '\n' && cin.get())
			{
				set<char> new_group_letters;
				set_intersection(group_letters.begin(), group_letters.end(), person_letters.begin(), person_letters.end(), inserter(new_group_letters, new_group_letters.begin()));
				group_letters = new_group_letters;

				if (cin.peek() == '\n' && cin.get())
					break; // New group
				else
					person_letters = set<char>(); // Next person in the same group
			}
		}

		total_yesses += group_letters.size();
	}

	return total_yesses;
}