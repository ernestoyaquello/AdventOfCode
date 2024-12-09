import input

PROBLEM_NUMBER = 9

def read_disk_layout():
    disk_layout = []

    is_reading_file_section_length = True
    file_id = 0
    section_position = 0
    for section_length in [int(n) for n in input.read(problem_number = PROBLEM_NUMBER)]:
        # If the section length is 0, we don't need to add it to the disk, as 0 means no length
        section_id = file_id if is_reading_file_section_length else None
        if section_length > 0:
            disk_layout.append({"position": section_position, "id": section_id, "length": section_length})

        # Alternate between file sections and empty sections and keep going
        if is_reading_file_section_length:
            is_reading_file_section_length = False
            file_id += 1
        else:
            is_reading_file_section_length = True
        section_position += section_length

    return disk_layout

def get_compacted_disk_layout_checksum(disk_layout, use_fragmentation):
    compact_disk_layout_with_fragmentation(disk_layout) if use_fragmentation else compact_disk_layout_without_fragmentation(disk_layout)
    return calculate_disk_layout_checksum(disk_layout)

def compact_disk_layout_with_fragmentation(disk_layout):
    # Separate the file and empty sections into two different layouts to make the fragmentation process easier
    file_layout, empty_layout = [], []
    for section in disk_layout:
        (file_layout if section["id"] is not None else empty_layout).append(section)

    # Iteratively move files (or parts of them) to the empty space so that the disk layout ends up having all the files in the beginning
    file_insertion_offset = 1
    while empty_layout[0]["position"] < file_layout[len(file_layout) - 1]["position"]:
        file_section = file_layout[len(file_layout) - 1]
        empty_section = empty_layout[0]

        # Update the file layout with the move
        length_to_move = min(file_section["length"], empty_section["length"])
        file_layout.insert(file_insertion_offset, {"position": empty_section["position"], "id": file_section["id"], "length": length_to_move})
        if length_to_move < file_section["length"]:
            file_section["length"] -= length_to_move
        else:
            file_layout.pop()
        file_insertion_offset += 1

        # Update the empty layout with the move
        empty_layout.append({"position": file_section["position"] + file_section["length"] - length_to_move, "id": None, "length": length_to_move})
        if length_to_move < empty_section["length"]:
            empty_section["length"] -= length_to_move
            empty_section["position"] += length_to_move
        else:
            empty_layout.pop(0)
            file_insertion_offset += 1

    # Update the unified disk layout data
    disk_layout.clear()
    for i in range(0, max(len(empty_layout), len(file_layout))):
        if i < len(file_layout):
            disk_layout.append(file_layout[i])
        if i < len(empty_layout):
            disk_layout.append(empty_layout[i])

def compact_disk_layout_without_fragmentation(disk_layout):
    # Iterate over each file section, starting with the last and moving left, to try to move each file to the earliest empty section with enough room
    first_potential_empty_index = 1
    potential_file_index = len(disk_layout) - 1
    while potential_file_index >= 2 and potential_file_index > first_potential_empty_index:
        if disk_layout[potential_file_index]["id"] is None:
            # This is not a file section, let's keep looking
            potential_file_index -= 1
            continue

        file_section = disk_layout[potential_file_index]
        is_first_empty_section_found = True
        for potential_empty_index in range(first_potential_empty_index, potential_file_index):
            if disk_layout[potential_empty_index]["id"] is not None:
                # This is not an empty section, let's keep looking
                continue

            empty_section = disk_layout[potential_empty_index]
            if empty_section["length"] >= file_section["length"]:
                # Update the empty section, removing it in case it's fully occupied
                empty_position = empty_section["position"]
                empty_section["length"] -= file_section["length"]
                if empty_section["length"] == 0:
                    disk_layout.pop(potential_empty_index)
                    potential_file_index -= 1
                else:
                    empty_section["position"] += file_section["length"]

                # Update the file section by moving it to the empty section in the list and updating its position
                disk_layout.insert(potential_empty_index, disk_layout.pop(potential_file_index))
                disk_layout.insert(potential_file_index + 1, {"position": file_section["position"], "id": None, "length": file_section["length"]})
                file_section["position"] = empty_position

                # Shift the file index to compensate for the file having been moved to the left
                potential_file_index += 1
                break

            # Shift the empty index to the first empty section found to avoid unnecessary iterations in the future
            if is_first_empty_section_found:
                is_first_empty_section_found = False
                first_potential_empty_index = potential_empty_index

        # Ensure we iterate backwards when looking for the next file section
        potential_file_index -= 1

def calculate_disk_layout_checksum(disk_layout):
    checksum = 0
    for section in disk_layout:
        if section["id"] is not None and section["id"] != 0:
            for position_offset in range(0, section["length"]):
                checksum += section["id"] * (section["position"] + position_offset)
    return checksum

print("Part 1: " + str(get_compacted_disk_layout_checksum(read_disk_layout(), use_fragmentation = True)))
print("Part 2: " + str(get_compacted_disk_layout_checksum(read_disk_layout(), use_fragmentation = False)))