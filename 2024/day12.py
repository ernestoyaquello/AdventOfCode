import input

PROBLEM_NUMBER = 12

def calculate_fences_price():
    position_to_tile = read_position_to_tile()
    tile_groups = find_tile_groups(position_to_tile)
    return sum(len(tile_group["tiles"]) * len(tile_group["fences"]) for tile_group in tile_groups)

def calculate_fences_price_correctly():
    total = 0

    # For each group, pick a tile, then pick a fence, then look for all the reachable tiles that share
    # that same fence (making sure to remove the fence from those tiles to avoid counting it again).
    # Then, count that as a side for the group and keep going.
    position_to_tile = read_position_to_tile()
    tile_groups = find_tile_groups(position_to_tile)
    for tile_group in tile_groups:
        number_of_sides = 0
        for tile in tile_group["tiles"]:
            while len(tile["fences"]) > 0:
                fence = tile["fences"].pop()
                fence_jump = (fence[1][0] - fence[0][0], fence[1][1] - fence[0][1])
                neighbor_positions_to_process = tile["neighbor_positions"].copy()
                while len(neighbor_positions_to_process) > 0:
                    next_tile_position = neighbor_positions_to_process.pop(0)
                    neighbor_tile = position_to_tile[next_tile_position]
                    neighbor_fence_to_remove = None
                    for neighbor_fence in neighbor_tile["fences"]:
                        neighbor_fence_jump = (neighbor_fence[1][0] - neighbor_fence[0][0], neighbor_fence[1][1] - neighbor_fence[0][1])
                        if neighbor_fence_jump == fence_jump:
                            neighbor_fence_to_remove = neighbor_fence
                            neighbor_positions_to_process.extend(neighbor_tile["neighbor_positions"])
                            break
                    if neighbor_fence_to_remove is not None:
                        neighbor_tile["fences"].remove(neighbor_fence_to_remove)
                number_of_sides += 1
        total += len(tile_group["tiles"]) * number_of_sides

    return total

def read_position_to_tile():
    position_to_tile = {}

    lines = input.read_lines(PROBLEM_NUMBER)
    max_x = len(lines[0]) - 1
    max_y = len(lines) - 1
    for x in range(max_x + 1):
        for y in range(max_y + 1):
            position = (x, y)
            tile = { "position": position, "type": lines[y][x], "fences": [], "neighbor_positions": [] }
            for adjacent_offset in [(-1, 0), (0, -1), (1, 0), (0, 1)]:
                adjacent_position = (x + adjacent_offset[0], y + adjacent_offset[1])
                is_neighbor_of_the_same_type = False
                if adjacent_position[0] >= 0 and adjacent_position[0] <= max_x and adjacent_position[1] >= 0 and adjacent_position[1] <= max_y:
                    adjacent_tile_type = lines[adjacent_position[1]][adjacent_position[0]]
                    is_neighbor_of_the_same_type = adjacent_tile_type == tile["type"]
                if is_neighbor_of_the_same_type:
                    tile["neighbor_positions"].append(adjacent_position)
                else:
                    tile["fences"].append((position, adjacent_position))
            position_to_tile[position] = tile

    return position_to_tile

def find_tile_groups(position_to_tile):
    tile_groups = []

    all_tiles = list(position_to_tile.values())
    while len(all_tiles) > 0:
        # Get the next tile whose group we'll find
        tile = all_tiles.pop(0)

        # Create the group with the tile found above, then iterate over the neighbors to add them too
        # (this works because the neighbor tiles will always be of the same type)
        group = { "type": tile["type"], "tiles": [tile], "fences": tile["fences"].copy() }
        next_tile_positions = tile["neighbor_positions"].copy()
        while len(next_tile_positions) > 0:
            tile_position = next_tile_positions.pop(0)
            if tile_position in position_to_tile:
                # Get the tile
                tile = position_to_tile[tile_position]
                if tile in all_tiles:
                    all_tiles.remove(tile)

                # Add it to the group, updating the next tile positions to keep looking for adjacent tiles of the same type
                if tile not in group["tiles"]:
                    group["tiles"].append(tile)
                    for fence_side, fence_other_side in tile["fences"]:
                        if (fence_side, fence_other_side) not in group["fences"] and (fence_other_side, fence_side) not in group["fences"]:
                            group["fences"].append((fence_side, fence_other_side))
                    next_tile_positions.extend(tile["neighbor_positions"])

        # Store the group we've just found
        tile_groups.append(group)

    return tile_groups

print("Part 1: " + str(calculate_fences_price()))
print("Part 2: " + str(calculate_fences_price_correctly()))