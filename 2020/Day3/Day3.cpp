#include "day3.h"

int main()
{
	//part1();
	part2();

	return 0;
}

void part1()
{
	vector<vector<char>> matrix = read_map_matrix();
	int numberOfTrees = get_number_of_trees_in_path(matrix, 3, 1);
	cout << numberOfTrees;
}

void part2()
{
	vector<vector<char>> matrix = read_map_matrix();
	unsigned long long numberOfTrees = get_number_of_trees_in_path(matrix, 1, 1);
	unsigned long long numberOfTrees2 = get_number_of_trees_in_path(matrix, 3, 1);
	unsigned long long numberOfTrees3 = get_number_of_trees_in_path(matrix, 5, 1);
	unsigned long long numberOfTrees4 = get_number_of_trees_in_path(matrix, 7, 1);
	unsigned long long numberOfTrees5 = get_number_of_trees_in_path(matrix, 1, 2);
	unsigned long long answer = numberOfTrees * numberOfTrees2 * numberOfTrees3 * numberOfTrees4 * numberOfTrees5;
	cout << answer;
}

vector<vector<char>> read_map_matrix()
{
	vector<vector<char>> matrix;

	while (true)
	{
		vector<char> row;
		char character;
		while ((character = fgetc(stdin)) != '\n' && character != EOF)
			row.push_back(character);

		if (row.size() > 0)
			matrix.push_back(row);

		if (character == EOF) break;
	}

	return matrix;
}

int get_number_of_trees_in_path(vector<vector<char>> matrix, int right, int down)
{
	const int matrix_width = matrix.at(0).size();
	const int matrix_height = matrix.size();
	int pos_x = 0;
	int pos_y = 0;
	int numberOfTrees = 0;

	while (pos_y < matrix_height)
	{
		char character = matrix.at(pos_y).at(pos_x);
		numberOfTrees += character == '#' ? 1 : 0;

		pos_x = (pos_x + right) % matrix_width;
		pos_y = pos_y + down;
	}

	return numberOfTrees;
}