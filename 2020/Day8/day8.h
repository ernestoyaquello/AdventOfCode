#include <iostream>
#include <sstream>
#include <vector>

using namespace std;

const char nop = 'n';
const char acc = 'a';
const char jmp = 'j';

struct instruction_type
{
	char command = -1;
	short value = 0;
	int line_number = 0;
	bool visited = false;
};

vector<instruction_type> read_instructions();
int part1(vector<instruction_type> instructions);
int part2(vector<instruction_type> instructions);
bool execute_instructions(vector<instruction_type> instructions, int* acc_ptr, int line_number = 0, bool restore_on_error = false);
int execute_instruction(instruction_type* instruction_ptr, int* acc_ptr);