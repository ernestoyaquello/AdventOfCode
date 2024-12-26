import input
import re

PROBLEM_NUMBER = 24
CONNECTION_PATTERN = re.compile(r"(.{3}) (AND|OR|XOR) (.{3}) -> (.{3})")

def execute_operations(data = None):
    data = read_data() if data is None else data
    final_bits = [None for _ in data["z_indices"]]
    processed_operations = set()
    next_operation = next(((lc, op, rc, out) for lc, op, rc, out in data["operations"] if data["cables"][lc]["value"] is not None and data["cables"][rc]["value"] is not None), None)
    while next_operation is not None:
        left_cable, logic_op, right_cable, output_cable = next_operation[0], next_operation[1], next_operation[2], next_operation[3]

        # Perform the operation
        previous_value = data["cables"][output_cable]["value"]
        if logic_op == "AND":
            data["cables"][output_cable]["value"] = data["cables"][left_cable]["value"] & data["cables"][right_cable]["value"]
        elif logic_op == "OR":
            data["cables"][output_cable]["value"] = data["cables"][left_cable]["value"] | data["cables"][right_cable]["value"]
        elif logic_op == "XOR":
            data["cables"][output_cable]["value"] = data["cables"][left_cable]["value"] ^ data["cables"][right_cable]["value"]
        processed_operations.add(next_operation)
        next_operation = None

        if data["cables"][output_cable]["value"] != previous_value:
            # Update the array of bits appropriately
            if output_cable in data["z_indices"]:
                final_bits[data["z_indices"][output_cable]] = data["cables"][output_cable]["value"]

            # Get the next operatiosns to perform, discarding the ones already performed
            candidate_next_operations = [data["operations"][index] for index in data["cables"][output_cable]["input_op_indices"]]
            for candidate_next_operation in candidate_next_operations:
                processed_operations.discard(candidate_next_operation)

            # Try to get the next operation from the candidates, in case there is any
            next_operation = next(((lc, op, rc, out) for lc, op, rc, out in candidate_next_operations if (lc, op, rc, out) not in processed_operations and data["cables"][lc]["value"] is not None and data["cables"][rc]["value"] is not None), None)

        # Get the next operation in case we don't know which one it will be yet
        if next_operation is None:
            next_operation = next(((lc, op, rc, out) for lc, op, rc, out in data["operations"] if (lc, op, rc, out) not in processed_operations and data["cables"][lc]["value"] is not None and data["cables"][rc]["value"] is not None), None)

    if all(b is not None for b in final_bits):
        return int("".join(str(b) for b in final_bits), 2)
    else:
        return None

def read_data():
    data = { "cables": {}, "operations": [], "z_indices": [] }
    input_parts = input.read(problem_number = PROBLEM_NUMBER).split("\n\n")

    for initial_value in input_parts[0].split("\n"):
        cable = initial_value.split(": ")[0]
        value = int(initial_value.split(": ")[1])
        data["cables"][cable] = { "id": cable, "value": value, "input_op_indices": set() }

    # Create name mapping for the important nodes to make them humanly readable (so I can look at them printed and know what's going on)
    name_mapping = {}
    for match in CONNECTION_PATTERN.finditer(input_parts[1]):
        left_cable = min(match.group(1), match.group(3))
        logic_op = match.group(2)
        right_cable = max(match.group(1), match.group(3))
        output_cable = match.group(4)

        if not output_cable.startswith("z") and ((left_cable.startswith("x") and right_cable.startswith("y")) or (left_cable.startswith("y") and right_cable.startswith("x"))):
            if logic_op == "XOR":
                # Addition logic gate
                name_mapping[output_cable] = left_cable + " + " + right_cable + " (" + output_cable + ")"
                if output_cable in data["cables"]:
                    data["cables"][name_mapping[output_cable]] = data["cables"][output_cable]
                    del data["cables"][output_cable]
            elif logic_op == "AND":
                # Carry logic gate
                name_mapping[output_cable] = left_cable + " + " + right_cable + " (CARRY)" + " (" + output_cable + ")"
                if output_cable in data["cables"]:
                    data["cables"][name_mapping[output_cable]] = data["cables"][output_cable]
                    del data["cables"][output_cable]

    # Now, actually parse the data, but applying the name mapping created above
    for match in CONNECTION_PATTERN.finditer(input_parts[1]):
        left_cable = min(match.group(1), match.group(3))
        logic_op = match.group(2)
        right_cable = max(match.group(1), match.group(3))
        output_cable = match.group(4)

        # Apply the name mapping here
        if left_cable in name_mapping:
            left_cable = name_mapping[left_cable]
        if right_cable in name_mapping:
            right_cable = name_mapping[right_cable]
        if output_cable in name_mapping:
            output_cable = name_mapping[output_cable]

        # Get the rest of the data
        for cable in [left_cable, right_cable]:
            if cable not in data["cables"]:
                data["cables"][cable] = { "id": cable, "value": None, "input_op_indices": set() }
            data["cables"][cable]["input_op_indices"].add(len(data["operations"]))
        if output_cable not in data["cables"]:
            data["cables"][output_cable] = { "id": output_cable, "value": None, "input_op_indices": set() }
        data["operations"].append((left_cable, logic_op, right_cable, output_cable))

    # Look for the z indices and their right positions in the final binary array/number
    for cable in data["cables"].keys():
        if cable.startswith("z"):
            data["z_indices"].append(int(cable[1:]))
    data["z_indices"] = {"z" + ("0" if z_index <= 9 else "") + str(z_index): len(data["z_indices"]) - z_index - 1 for z_index in data["z_indices"]}

    return data

def print_trees():
    data = read_data()
    z_trees = {}
    output = ""
    for z_cable_id in sorted(data["z_indices"].keys()):
        z_trees[z_cable_id] = generate_tree(data, z_cable_id)
        output += tree_to_string(z_trees[z_cable_id]) + "\n"
    with open('2024/outputs/day24.txt', 'w', encoding = "utf-8") as f:
        print(output, file = f)

def tree_to_string(tree, spacing = 0):
    output = ""
    if tree is not None:
        output += str(tree["id"]) + "\n"
        if tree["op"] is not None and "+" not in tree["id"]:
            output += (" | " * spacing) + " ├-" + tree_to_string(tree["left_parent"], spacing + 1)
            output += (" | " * spacing) + tree["op"] + "\n"
            output += (" | " * spacing) + " ╰-" + tree_to_string(tree["right_parent"], spacing + 1)
    return output

def generate_tree(data, cable_id, level = 0):
    operations = [(lc, op, rc, out) for lc, op, rc, out in data["operations"] if out == cable_id]
    operation = operations[0] if len(operations) > 0 else None
    tree = {
        "id": cable_id,
        "left_parent": generate_tree(data, min(operation[0], operation[2]), level + 1) if operation is not None else None,
        "right_parent": generate_tree(data, max(operation[0], operation[2]), level + 1) if operation is not None else None,
        "op": operation[1] if operation is not None else None,
        "level": level,
    }
    if operation is not None:
        for parent_key in ["left_parent", "right_parent"]:
            if "children" not in tree[parent_key]:
                tree[parent_key]["children"] = []
            tree[parent_key]["children"].append(tree)
    return tree

print("Part 1: " + str(execute_operations()))

# Solved it "manually" by printing the data to a file and then analysing said file to find the errors,
# which I later fixed in code to ensure that my fixes were correct. It was painful, not gonna lie...
print_trees()
print("Part 2: " + ",".join(sorted(["qff", "qnw", "pbv", "z16", "qqp", "z23", "fbq", "z36"])))