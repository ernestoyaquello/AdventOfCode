#include "day7.h"

int main()
{
	vector<bag_type> bags = read_bags();
	int result = part1(bags);
	//int result = part2(bags);
	cout << result;

	for (bag_type bag : bags)
		delete bag.contains;

	return 0;
}

int part1(vector<bag_type> bags)
{
	int number_of_valid_bags = 0;
	for (bag_type bag : bags)
		number_of_valid_bags += can_carry_bag(bag, "shiny gold") ? 1 : 0;

	return number_of_valid_bags;
}

int part2(vector<bag_type> bags)
{
	bag_type shiny_gold_bag = find_bag(bags, "shiny gold");
	return number_of_bags_within(shiny_gold_bag);
}

vector<bag_type> read_bags()
{
	vector<bag_type> bags;

	while (!cin.eof())
	{
		bag_type bag = read_bag(true);
		if (bag.color.compare(" ") != 0)
			bags.push_back(bag);
	}

	for (bag_type bag : bags)
		complete_bag(bags, &bag);

	return bags;
}

// TODO Consider using regex to avoid this messy way of reading the data
bag_type read_bag(bool is_first)
{
	bag_type bag;
	string _;
	string first_color_word;
	string second_color_word;

	if (!is_first)
	{
		int last_number = 0;
		while (isdigit(cin.peek()))
		{
			cin >> bag.number;
			bag.number = (last_number * 10) + bag.number;
			last_number = bag.number;
		}
	}

	cin >> first_color_word >> second_color_word >> _;
	bag.color = first_color_word + " " + second_color_word;

	if (is_first)
	{
		cin >> _;
		if (cin.get() && !isdigit(cin.peek()))
		{
			cin >> _ >> _ >> _;
			cin.get();
		}
		else while (isdigit(cin.peek()))
		{
			bag_type inner_bag = read_bag(false);
			if (inner_bag.number > 0 && inner_bag.color.compare(" ") != 0)
				bag.contains->push_back(inner_bag);

			cin.get();
		}
	}

	return bag;
}

void complete_bag(vector<bag_type> bags, bag_type* bag_to_complete)
{
	if (bag_to_complete->complete)
		return;

	for (int i = 0; i < bags.size(); i++)
	{
		bag_type bag = bags[i];
		if (bag.color.compare(bag_to_complete->color) == 0)
		{
			if (bag_to_complete->contains != bag.contains)
				delete bag_to_complete->contains;

			bag_to_complete->contains = bag.contains;
			bag_to_complete->complete = bag.complete;

			for (int j = 0; !bag_to_complete->complete && j < bag_to_complete->contains->size(); j++)
			{
				bag_type* inner_bag_to_complete = &(*bag_to_complete->contains)[j];
				complete_bag(bags, inner_bag_to_complete);
			}

			bag_to_complete->complete = true;

			break;
		}
	}
}

bool can_carry_bag(bag_type bag, string bag_color)
{
	for (bag_type inner_bag : *bag.contains)
		if (inner_bag.color.compare(bag_color) == 0 || can_carry_bag(inner_bag, bag_color))
			return true;

	return false;
}

bag_type find_bag(vector<bag_type> bags, string color)
{
	for (bag_type bag : bags)
		if (bag.color.compare(color) == 0)
			return bag;

	throw "Bag not found!";
}

int number_of_bags_within(bag_type bag)
{
	int total = 0;
	for (bag_type inner_bag : *bag.contains)
	{
		total += inner_bag.number;
		total += inner_bag.number * number_of_bags_within(inner_bag);
	}

	return total;
}