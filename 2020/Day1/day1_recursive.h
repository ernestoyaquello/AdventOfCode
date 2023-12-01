#include <iostream>
#include <vector>

using namespace std;

void part1();
void part2();
vector<int> read_numbers();
int find_solution(int number_of_numbers, int goal);
int find_solution_recursively(const vector<int> numbers, vector<int>* indices_sequence, int level, int goal);