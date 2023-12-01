#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

int part1();
unsigned long long part2();
vector<int> read_joltage_ratings();
void count_potential_arrangements(vector<int> joltage_ratings, unsigned long long* counted_arrangements, int index = 0);