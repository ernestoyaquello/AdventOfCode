import input
import re
import math

PROBLEM_NUMBER = 17
INPUT_PATTERN = re.compile(r"Register A: (\d+)\nRegister B: (\d+)\nRegister C: (\d+)\n\nProgram: ((?:\d+,?)+)")

def execute_instructions(computer_state, expected_output = None):
    output = ""

    while (computer_state["instruction_pointer"] + 1) < len(computer_state["instructions"]):
        # Read the instruction and the operand
        instruction = computer_state["instructions"][computer_state["instruction_pointer"]]
        literal_operand = computer_state["instructions"][computer_state["instruction_pointer"] + 1]
        combo_operand = None
        if literal_operand < 7:
            combo_operand = literal_operand if literal_operand < 4 else (computer_state["registers"][chr(literal_operand + 93)])

        # Execute the instruction
        if instruction == 0:   # adv
            computer_state["registers"]["a"] = computer_state["registers"]["a"] // int(math.pow(2, combo_operand))
        elif instruction == 1: # bxl
            computer_state["registers"]["b"] = computer_state["registers"]["b"] ^ literal_operand
        elif instruction == 2: # bst
            computer_state["registers"]["b"] = combo_operand % 8
        elif instruction == 3: # jnz
            if computer_state["registers"]["a"] != 0:
                computer_state["instruction_pointer"] = literal_operand
                continue
        elif instruction == 4: # bxc
            computer_state["registers"]["b"] = computer_state["registers"]["b"] ^ computer_state["registers"]["c"]
        elif instruction == 5: # out
            result = combo_operand % 8
            output += str(result) if output == "" else ("," + str(result))
            if expected_output is not None and not expected_output.startswith(output):
                return output
        elif instruction == 6: # bdv
            computer_state["registers"]["b"] = computer_state["registers"]["a"] // int(math.pow(2, combo_operand))
        elif instruction == 7: # cdv
            computer_state["registers"]["c"] = computer_state["registers"]["a"] // int(math.pow(2, combo_operand))

        # Move to the next instruction
        computer_state["instruction_pointer"] += 2

    return output

def find_correct_register_a():
    original_computer_state = get_computer_state()

    # Find the masked values of A that will produced the desired output for each time the instructions are executed.
    # This madness works on my specific input only, for which I've simplified the instructions to this:
    #   1. B = 7 - (A & 7)
    #   2. C = (A >> B) & 7
    #   3. B = 7 - (B xor C)
    #   4. A = A >> 3
    #   5. Start over if A is not 0, halt otherwise
    candidate_aes = {}
    for index in range(len(original_computer_state["instructions"]) - 1, -1, -1):
        expected_output = original_computer_state["instructions"][index]

        # Create a set of all the possible makes values of A that could potentially produce the expected output
        shifted_candidate_aes = set()
        for candidate_bits in range(0, 8):
            if index < len(original_computer_state["instructions"]) - 1:
                for extra_bits in range(0, 8):
                    shifted_candidate_aes.add(candidate_bits | (extra_bits << (7 - candidate_bits)))
            else:
                # For the last iteration, there cannot be any numbers to the left of the candidate bits
                # (if there were, then the computer would iterate again)
                shifted_candidate_aes.add(candidate_bits)

        # Actually apply the operations to see if the candidates produce the expected output, and filter out the ones that don't
        candidate_aes[index] = set()
        for shifted_candidate_a in shifted_candidate_aes:
            b = 7 - (shifted_candidate_a & 7)
            c = (shifted_candidate_a >> b) & 7
            b = 7 - (b ^ c)
            if b == expected_output:
                shifted_left_mask = 7 << (7 - (shifted_candidate_a & 7))
                shifted_right_mask = 7
                shifted_mask = shifted_left_mask | shifted_right_mask
                shift = index * 3
                candidate_aes[index].add((shifted_candidate_a << shift, shifted_mask << shift))

    # Get rid of those values that cannot be combined with at least one value of every other iteration,
    # as that means they are unusable (the final A will be a combination of one value from each iteration)
    for index, index_candidate_aes in candidate_aes.items():
        filtered_index_candidate_aes = index_candidate_aes.copy()
        for candidate_a, candidate_a_mask in index_candidate_aes:
            for other_index in range(0, len(original_computer_state["instructions"])):
                if index != other_index:
                    has_match = False
                    for other_candidate_a, other_candidate_a_mask in candidate_aes[other_index]:
                        combined_candidate_a = candidate_a | other_candidate_a
                        if (combined_candidate_a & candidate_a_mask) == candidate_a and (combined_candidate_a & other_candidate_a_mask) == other_candidate_a:
                            has_match = True
                            break
                    if not has_match:
                        filtered_index_candidate_aes.remove((candidate_a, candidate_a_mask))
                        break
        candidate_aes[index] = filtered_index_candidate_aes

    # Figure out what output we are looking for (the output must match the instructions given as an input),
    # create all the possible combinations of A values, and try them out until one gives us the desired output
    desired_output = ",".join(str(instruction) for instruction in original_computer_state["instructions"])
    combined_candidate_aes = combine_candidate_aes(candidate_aes, len(original_computer_state["instructions"]) - 1)
    for candidate_a, _ in sorted(combined_candidate_aes):
        next_computer_state = {
            "registers": {
                "a": candidate_a,
                "b": original_computer_state["registers"]["b"],
                "c": original_computer_state["registers"]["c"],
            },
            "instructions": original_computer_state["instructions"].copy(),
            "instruction_pointer": 0,
        }
        if execute_instructions(next_computer_state, desired_output) == desired_output:
            return candidate_a

    # This should never happen, but if it does, we'll know that the solution is incorrect
    return None

def combine_candidate_aes(candidate_aes, index):
    if index == 0:
        return candidate_aes[index]
    else:
        combined_candidates = set()
        for candidate_a, candidate_a_mask in candidate_aes[index]:
            for inner_candidate_a, inner_candidate_a_mask in combine_candidate_aes(candidate_aes, index - 1):
                combined_candidate_a = candidate_a | inner_candidate_a
                if (combined_candidate_a & candidate_a_mask) == candidate_a and (combined_candidate_a & inner_candidate_a_mask) == inner_candidate_a:
                    combined_candidates.add((combined_candidate_a, (candidate_a_mask | inner_candidate_a_mask)))
        return combined_candidates

def get_computer_state():
    match = INPUT_PATTERN.match(input.read(problem_number = PROBLEM_NUMBER))
    return {
        "registers": {
            "a":  int(match.group(1)),
            "b":  int(match.group(2)),
            "c":  int(match.group(3)),
        },
        "instructions": [int(instruction) for instruction in match.group(4).split(",")],
        "instruction_pointer": 0,
    }

print("Part 1: " + str(execute_instructions(get_computer_state())))
print("Part 2: " + str(find_correct_register_a()))