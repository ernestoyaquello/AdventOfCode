#include <iostream>
#include <string>
#include <vector>
#include <tuple>
#include <utility>

// Y, X, Z
const std::tuple<int, int, int> adjacent_directions[26] =
{
    {-1, -1, -1}, {-1, 0, -1}, {-1, 1, -1}, {0, -1, -1}, {0, 0, -1}, {0, 1, -1}, {1, -1, -1}, {1, 0, -1}, {1, 1, -1},
    {-1, -1,  0}, {-1, 0,  0}, {-1, 1,  0}, {0, -1,  0},             {0, 1,  0}, {1, -1,  0}, {1, 0,  0}, {1, 1,  0},
    {-1, -1,  1}, {-1, 0,  1}, {-1, 1,  1}, {0, -1,  1}, {0, 0,  1}, {0, 1,  1}, {1, -1,  1}, {1, 0,  1}, {1, 1,  1}
};

// Y, X, Z, W
const std::tuple<int, int, int, int> adjacent_directions_4d[80] =
{
    {-1, -1, -1, -1}, {-1, 0, -1, -1}, {-1, 1, -1, -1}, {0, -1, -1, -1}, {0, 0, -1, -1}, {0, 1, -1, -1}, {1, -1, -1, -1}, {1, 0, -1, -1}, {1, 1, -1, -1},
    {-1, -1,  0, -1}, {-1, 0,  0, -1}, {-1, 1,  0, -1}, {0, -1,  0, -1}, {0, 0,  0, -1}, {0, 1,  0, -1}, {1, -1,  0, -1}, {1, 0,  0, -1}, {1, 1,  0, -1},
    {-1, -1,  1, -1}, {-1, 0,  1, -1}, {-1, 1,  1, -1}, {0, -1,  1, -1}, {0, 0,  1, -1}, {0, 1,  1, -1}, {1, -1,  1, -1}, {1, 0,  1, -1}, {1, 1,  1, -1},
    {-1, -1, -1,  0}, {-1, 0, -1,  0}, {-1, 1, -1,  0}, {0, -1, -1,  0}, {0, 0, -1,  0}, {0, 1, -1,  0}, {1, -1, -1,  0}, {1, 0, -1,  0}, {1, 1, -1,  0},
    {-1, -1,  0,  0}, {-1, 0,  0,  0}, {-1, 1,  0,  0}, {0, -1,  0,  0},                 {0, 1,  0,  0}, {1, -1,  0,  0}, {1, 0,  0,  0}, {1, 1,  0,  0},
    {-1, -1,  1,  0}, {-1, 0,  1,  0}, {-1, 1,  1,  0}, {0, -1,  1,  0}, {0, 0,  1,  0}, {0, 1,  1,  0}, {1, -1,  1,  0}, {1, 0,  1,  0}, {1, 1,  1,  0},
    {-1, -1, -1,  1}, {-1, 0, -1,  1}, {-1, 1, -1,  1}, {0, -1, -1,  1}, {0, 0, -1,  1}, {0, 1, -1,  1}, {1, -1, -1,  1}, {1, 0, -1,  1}, {1, 1, -1,  1},
    {-1, -1,  0,  1}, {-1, 0,  0,  1}, {-1, 1,  0,  1}, {0, -1,  0,  1}, {0, 0,  0,  1}, {0, 1,  0,  1}, {1, -1,  0,  1}, {1, 0,  0,  1}, {1, 1,  0,  1},
    {-1, -1,  1,  1}, {-1, 0,  1,  1}, {-1, 1,  1,  1}, {0, -1,  1,  1}, {0, 0,  1,  1}, {0, 1,  1,  1}, {1, -1,  1,  1}, {1, 0,  1,  1}, {1, 1,  1,  1}
};

int part1();
int part2();
std::vector<std::vector<std::vector<char>>> read_initial_state();
std::vector<std::vector<std::vector<char>>> calculate_next_iteration(std::vector<std::vector<std::vector<char>>>* old_state_ptr);
char get_value(std::vector<std::vector<std::vector<char>>>* state_ptr, int y, int x, int z);
std::vector<std::vector<std::vector<std::vector<char>>>> read_initial_state_4d();
std::vector<std::vector<std::vector<std::vector<char>>>> calculate_next_iteration_4d(std::vector<std::vector<std::vector<std::vector<char>>>>* old_state_ptr);
char get_value_4d(std::vector<std::vector<std::vector<std::vector<char>>>>* state_ptr, int y, int x, int z, int w);