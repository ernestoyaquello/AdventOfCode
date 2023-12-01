#include "day8.h"

int main()
{
	vector<instruction_type> instructions = read_instructions();
	//int result = part1(instructions);
	int result = part2(instructions);
	cout << result;

	return 0;
}

vector<instruction_type> read_instructions()
{
	int line_number = 0;
	string command, value;
	vector<instruction_type> instructions;
	while (cin >> command && cin >> value)
	{
		instruction_type instruction;
		instruction.command = command.at(0);
		instruction.value = stoi(value);
		instruction.line_number = line_number++;
		instructions.push_back(instruction);
	}

	return instructions;
}

int part1(vector<instruction_type> instructions)
{
	int accumulator = 0;
	execute_instructions(instructions, &accumulator);
	return accumulator;
}

int part2(vector<instruction_type> instructions)
{
	int line_number = 0, accumulator = 0;
	while (line_number < instructions.size())
	{
		instruction_type* instruction_ptr = &instructions[line_number];
		if (instruction_ptr->command == nop || instruction_ptr->command == jmp)
		{
			instruction_ptr->command = instruction_ptr->command == jmp ? nop : jmp; // Apply potential fix
			if (execute_instructions(instructions, &accumulator, line_number, true))
				return accumulator;
			instruction_ptr->command = instruction_ptr->command == jmp ? nop : jmp; // Undo useless fix
		}

		line_number = execute_instruction(instruction_ptr, &accumulator);
	}

	return accumulator;
}

bool execute_instructions(vector<instruction_type> instructions, int* acc_ptr, int line_number, bool restore_on_error)
{
	int acc_backup = *acc_ptr;
	vector<instruction_type> visited_backup;
	while (line_number < instructions.size())
	{
		instruction_type* instruction_ptr = &instructions[line_number];
		if (instruction_ptr->visited)
		{
			if (restore_on_error)
			{
				*acc_ptr = acc_backup;
				for (instruction_type visited_instruction : visited_backup)
					(&instructions[visited_instruction.line_number])->visited = visited_instruction.visited;
			}

			return false;
		}

		visited_backup.push_back(*instruction_ptr);
		line_number = execute_instruction(instruction_ptr, acc_ptr);
	}

	return true;
}

int execute_instruction(instruction_type* instruction_ptr, int* acc_ptr)
{
	instruction_ptr->visited = true;
	*acc_ptr += instruction_ptr->command == acc ? instruction_ptr->value : 0;

	return instruction_ptr->command == jmp
		? instruction_ptr->line_number + instruction_ptr->value
		: instruction_ptr->line_number + 1;
}