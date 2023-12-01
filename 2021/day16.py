import input
import math

PROBLEM_NUMBER = 16

def execute(is_part_two):
    packet_hex = input.read_lines(problem_number = PROBLEM_NUMBER)[0]
    packet_bin = bin(int(packet_hex, 16))[2:]
    packet_bin = (get_padding(len(packet_bin)) * '0') + packet_bin

    index, value, version_sum = parse_packet(packet_bin)

    return version_sum if not is_part_two else value

def get_padding(index):
    return (4 - (index % 4)) % 4

def parse_packet(packet_bin):
    next_index = 6
    value = 0
    version_sum = int(packet_bin[:3], 2)
    type_id = int(packet_bin[3:6], 2)

    # Literal value
    if type_id == 4:
        number_section = packet_bin[next_index:next_index + 5]
        number = number_section[1:]
        while number_section[0] != '0':
            next_index += 5
            number_section = packet_bin[next_index:next_index + 5]
            number += number_section[1:]
        next_index += 5
        value = int(number, 2)

    # Operator
    else:
        length_type_id = packet_bin[next_index]
        next_index += 1
        if length_type_id == '0':
            total_length = int(packet_bin[next_index:22], 2)
            next_index += 15
            max_index = next_index + total_length
            values = []
            while next_index < max_index:
                new_next_index, subpacket_value, subpacket_version = parse_packet(packet_bin[next_index:])
                values.append(subpacket_value)
                version_sum += subpacket_version
                next_index += new_next_index
            value = execute_operation(type_id, values)
        elif length_type_id == '1':
            number_of_subpackets = int(packet_bin[next_index:18], 2)
            next_index += 11
            values = []
            for _ in range(number_of_subpackets):
                new_next_index, subpacket_value, subpacket_version = parse_packet(packet_bin[next_index:])
                values.append(subpacket_value)
                version_sum += subpacket_version
                next_index += new_next_index
            value = execute_operation(type_id, values)

    return (next_index, value, version_sum)

def execute_operation(type_id, values):
    if type_id == 0:
        return sum(values)
    elif type_id == 1:
        return math.prod(values)
    elif type_id == 2:
        return min(values)
    elif type_id == 3:
        return max(values)
    elif type_id == 5:
        return 1 if values[0] > values[1] else 0
    elif type_id == 6:
        return 1 if values[0] < values[1] else 0
    elif type_id == 7:
        return 1 if values[0] == values[1] else 0

print("Part 1: " + str(execute(is_part_two = False)))
print("Part 2: " + str(execute(is_part_two = True)))