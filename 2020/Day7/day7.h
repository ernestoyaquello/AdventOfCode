#include <iostream>
#include <vector>

using namespace std;

struct bag_type
{
	int number = 0;
	string color;
	vector<bag_type>* contains = new vector<bag_type>();
	bool complete = false;
};

int part1(vector<bag_type> bags);
int part2(vector<bag_type> bags);

// To parse and prepare the data
vector<bag_type> read_bags();
bag_type read_bag(bool is_first);
void complete_bag(vector<bag_type> bags, bag_type* bag_to_complete);

// To solve the puzzles
bool can_carry_bag(bag_type bag, string bag_color);
bag_type find_bag(vector<bag_type> bags, string color);
int number_of_bags_within(bag_type bag);