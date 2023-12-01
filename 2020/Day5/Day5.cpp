#include "day5.h"

int main()
{
	//part1();
	part2();

	return 0;
}

void part1()
{
	int max_pass_id = find_max_pass_id();
	cout << max_pass_id;
}

void part2()
{
	int missing_pass_ids = find_missing_pass_id();
	cout << missing_pass_ids;
}

int find_max_pass_id()
{
	string pass;
	int row, seat, pass_id, max_pass_id = 0;

	while (!cin.eof())
	{
		cin >> pass;

		row = get_location(pass.substr(0, 7), 'F');
		seat = get_location(pass.substr(7, 3), 'L');
		pass_id = (row * 8) + seat;
		max_pass_id = pass_id > max_pass_id ? pass_id : max_pass_id;

		while (cin.peek() == '\n') cin.get();
	}

	return max_pass_id;
}

int find_missing_pass_id()
{
	list<int> pass_ids = read_all_pass_ids();
	pass_ids.sort();

	int last_read_pass_id = -1;
	for (int const& pass_id : pass_ids)
	{
		if ((pass_id - 1) > last_read_pass_id && last_read_pass_id >= 0)
			return pass_id - 1;

		last_read_pass_id = pass_id;
	}

	return -1;
}

list<int> read_all_pass_ids()
{
	list<int> pass_ids;
	string pass;

	while (!cin.eof())
	{
		cin >> pass;

		int row = get_location(pass.substr(0, 7), 'F');
		int seat = get_location(pass.substr(7, 3), 'L');
		int pass_id = (row * 8) + seat;
		pass_ids.push_back(pass_id);

		while (cin.peek() == '\n') cin.get();
	}

	return pass_ids;
}

int get_location(string pass, char lower_char)
{
	unsigned char min = 0;
	unsigned char max = pow(2, pass.size()) - 1;

	for (int i = 0; i < pass.size(); i++)
	{
		if (pass.at(i) == lower_char)
			max = min + ((max - min) >> 1);
		else
			min = 1 + min + ((max - min) >> 1);
	}

	return min;
}