import input

PROBLEM_NUMBER = 11

# Another year, another "masterclass" on how to solve a problem without solving the problem.
# 
# There is obviously a simple solution hidden here that involves figuring out how to calculate
# the result without actually performing the iterations and creating an absolutely gigantic
# array, but I couldn't figure it out easily, and I didn't want to spend too long trying.
# Thus, I actually implemented the iterations, but with a few tweaks to make the code just
# efficient enough and light enough (it still consumes many gigabytes of RAM though) for the
# result to be eventually spat out after a little white.
# 
# This is horrendous, and only works if the iterations to perform are exact multiples of 25.
# Plus, it's definitely not what was intended as a solution... But as usual, a star is a star.
def count_stones_after_iterations(number_of_iterations):
    stones = [int(number) for number in input.read(problem_number = PROBLEM_NUMBER).split()]
    stone_to_stones_after_25_iterations = {}

    # Perform the first few 25-sized iterations (all but the last one)
    for _ in range(0, (number_of_iterations // 25) - 1):
        new_stones = []
        for stone in stones:
            if stone not in stone_to_stones_after_25_iterations:
                stone_to_stones_after_25_iterations[stone] = get_stones_after_25_iterations(stone)

                # Calculate and cache the results of the sub-stones created above too, as there
                # is always a lot of repetition later down the line
                for sub_stone in stone_to_stones_after_25_iterations[stone]:
                    if sub_stone not in stone_to_stones_after_25_iterations:
                        stone_to_stones_after_25_iterations[sub_stone] = get_stones_after_25_iterations(sub_stone)

            new_stones.extend(stone_to_stones_after_25_iterations[stone])
        stones = new_stones

    # Perform the last 25-sized iteration, but this time just counting, no need to create a
    # massive final array because it would be too slow and we would quickly run out of memory.
    stone_to_stone_count_after_25_iterations = {stone: len(sub_stones) for stone, sub_stones in stone_to_stones_after_25_iterations.items()}
    count = 0
    for stone in stones:
        if stone not in stone_to_stone_count_after_25_iterations:
            stone_to_stone_count_after_25_iterations[stone] = len(get_stones_after_25_iterations(stone))
        count += stone_to_stone_count_after_25_iterations[stone]
    return count

def get_stones_after_25_iterations(stone):
    stones = [stone]
    for _ in range(0, 25):
        new_stones = []
        for stone in stones:
            if stone == 0:
                # 0 becomes 1
                new_stones.extend([1])
            elif len(str(stone)) % 2 == 0:
                # Numbers with an even number of digits are split into two numbers
                new_stones.extend([int(str(stone)[0:len(str(stone)) // 2]), int(str(stone)[len(str(stone)) // 2:len(str(stone))])])
            else:
                # Every other number is just multiplied by 2024
                new_stones.extend([stone * 2024])
        stones = new_stones
    return stones

print("Part 1: " + str(count_stones_after_iterations(number_of_iterations = 25)))
print("Part 2: " + str(count_stones_after_iterations(number_of_iterations = 75)))
