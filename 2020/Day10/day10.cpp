#include "day10.h"

int main()
{
	//int result = part1();
	unsigned long long result = part2();
	cout << result;

	return 0;
}

int part1()
{
	vector<int> joltage_ratings = read_joltage_ratings();
	int one_diffs = 0, three_diffs = 0, last_rating = 0;

	for (int rating : joltage_ratings)
	{
		int difference = rating - last_rating;
		if (difference == 1) one_diffs++;
		else if (difference == 3) three_diffs++;
		last_rating = rating;
	}

	return one_diffs * three_diffs;
}

unsigned long long part2()
{
	vector<int> joltage_ratings = read_joltage_ratings();
	unsigned long long* counted_arrangements = new unsigned long long[joltage_ratings.size()]();
	count_potential_arrangements(joltage_ratings, counted_arrangements);
	unsigned long long total = counted_arrangements[0];
	delete[] counted_arrangements;

	return total;
}

vector<int> read_joltage_ratings()
{
	int rating;
	vector<int> joltage_ratings;

	joltage_ratings.push_back(0);
	while (cin >> rating) joltage_ratings.push_back(rating);
	sort(joltage_ratings.begin(), joltage_ratings.end());
	joltage_ratings.push_back(joltage_ratings[joltage_ratings.size() - 1] + 3);

	return joltage_ratings;
}

void count_potential_arrangements(vector<int> joltage_ratings, unsigned long long* counted_arrangements, int index)
{
	if (counted_arrangements[index] > 0)
		return;

	unsigned long long sum = 0;
	int subindex = index;

	if (index == (joltage_ratings.size() - 1))
	{
		sum = 1;
	}
	else while (++subindex < joltage_ratings.size())
	{
		int diff = joltage_ratings[subindex] - joltage_ratings[index];
		if (diff > 3) break;

		count_potential_arrangements(joltage_ratings, counted_arrangements, subindex);
		sum += counted_arrangements[subindex];
	}

	counted_arrangements[index] = sum;
}