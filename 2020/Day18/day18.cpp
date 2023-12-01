#include "day18.h"

int main()
{
	//std::cout << "Part 1: " << part1() << std::endl;
	std::cout << "Part 2: " << part2() << std::endl;
	return 0;
}

unsigned long long part1()
{
	unsigned long long total = 0;
	std::string line;
	while (std::getline(std::cin, line) && line.compare("") != 0)
	{
		const auto expression_tree = calculate_expression_tree(line);
		total += calculate_result(expression_tree);
		free_memory(expression_tree);
	}

	return total;
}

unsigned long long part2()
{
	unsigned long long total = 0;
	std::string line;
	while (std::getline(std::cin, line) && line.compare("") != 0)
	{
		line = add_preference_parentheses(line);
		const auto expression_tree = calculate_expression_tree(line);
		total += calculate_result(expression_tree);
		free_memory(expression_tree);
	}

	return total;
}

expression_type* calculate_expression_tree(std::string line)
{
	auto tree = new expression_type();
	for (std::size_t i = 0; i < line.size(); i++)
	{
		if (std::isdigit(line[i]))
		{
			auto subtree = new expression_type();
			subtree->value = line[i] - '0';
			if (tree->operation == '\0')
			{
				tree->left = subtree;
			}
			else
			{
				tree->right = subtree;
				if ((i + 1) < line.size())
				{
					auto tree_backup = tree;
					tree = new expression_type();
					tree->left = tree_backup;
				}
			}
		}
		else if (line[i] == '(')
		{
			const auto closing_parentheses_index = find_closing_parentheses_index(i, line);
			const auto subline = line.substr(i + 1, closing_parentheses_index - (i + 1));

			if (tree->operation == '\0')
			{
				tree->left = calculate_expression_tree(subline);
			}
			else
			{
				tree->right = calculate_expression_tree(subline);
				if ((closing_parentheses_index + 1) < line.size())
				{
					auto tree_backup = tree;
					tree = new expression_type();
					tree->left = tree_backup;
				}
			}

			i = closing_parentheses_index;
		}
		else if ((line[i] == '+' || line[i] == '*'))
		{
			tree->operation = line[i];
		}
	}

	return tree;
}

unsigned long long calculate_result(expression_type* tree)
{
	auto first_value = tree->left->value > 0 ? tree->left->value : calculate_result(tree->left);
	auto second_value = tree->right->value > 0 ? tree->right->value : calculate_result(tree->right);
	return tree->operation == '+' ? (first_value + second_value) : (first_value * second_value);
}

// This isn't ideal; there must be a way to modify the expression tree to ensure preference is followed...
std::string add_preference_parentheses(std::string line)
{
	for (std::size_t i = 0; i < line.size(); i++)
	{
		// We add parentheses for each addition to ensure additions are processed first
		if (line[i] == '+')
		{
			const auto left = line[i - 2];
			if (isdigit(left))
			{
				line = line.insert(i - 2, "(");
				i++;
			}
			else if (left == ')')
			{
				const auto opening_parentheses_index = find_opening_parentheses_index(i - 2, line);
				line.insert(opening_parentheses_index, "(");
				i++;
			}

			const auto right = line[i + 2];
			if (isdigit(right))
			{
				line = line.insert(i + 3, ")");
			}
			else if (right == '(')
			{
				const auto closing_parentheses_index = find_closing_parentheses_index(i + 2, line);
				line.insert(closing_parentheses_index + 1, ")");
			}
		}
	}

	return remove_unnecessary_parentheses(line);
}

std::string remove_unnecessary_parentheses(std::string line)
{
	// Remove parenthesis that are wrapping the entire expression unnecessarily
	while (line[0] == '(')
	{
		const auto closing_parentheses_index = find_closing_parentheses_index(0, line);
		if (closing_parentheses_index == (line.size() - 1))
		{
			line.erase(0, 1);
			line.erase(line.size() - 1, 1);
		}
		else
		{
			break;
		}
	}

	// Remove redundant parentheses
	for (std::size_t i = 0; i < line.size(); i++)
	{
		if (line[i] == '(')
		{
			while (line[i + 1] == '(')
			{
				const auto closing_parentheses_index = find_closing_parentheses_index(i, line);
				const auto inner_closing_parentheses_index = find_closing_parentheses_index(i + 1, line);
				if (inner_closing_parentheses_index == (closing_parentheses_index - 1))
				{
					line.erase(i + 1, 1);
					line.erase(inner_closing_parentheses_index - 1, 1);
				}
				else
				{
					break;
				}
			}
		}
	}

	return line;
}

std::size_t find_closing_parentheses_index(std::size_t opening_parentheses_index, std::string line)
{
	int opening_parentheses = 1;
	std::size_t closing_parentheses_index = opening_parentheses_index + 1;
	for (std::size_t j = closing_parentheses_index; opening_parentheses > 0; j++)
	{
		if (line[j] == '(') opening_parentheses++;
		else if (line[j] == ')') opening_parentheses--;
		closing_parentheses_index = j;
	}

	return closing_parentheses_index;
}

std::size_t find_opening_parentheses_index(std::size_t closing_parentheses_index, std::string line)
{
	int closing_parentheses = 1;
	std::size_t opening_parentheses_index = closing_parentheses_index - 1;
	for (std::size_t j = opening_parentheses_index; closing_parentheses > 0; j--)
	{
		if (line[j] == '(') closing_parentheses--;
		else if (line[j] == ')') closing_parentheses++;
		opening_parentheses_index = j;
	}

	return opening_parentheses_index;
}

void free_memory(expression_type* tree)
{
	if (tree->left->value > 0) delete tree->left;
	else free_memory(tree->left);

	if (tree->right->value > 0) delete tree->right;
	else free_memory(tree->right);

	delete tree;
}