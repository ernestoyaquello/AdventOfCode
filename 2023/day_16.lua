require "input_helper"

local problemNumber = 16

local function read_grid_info(lines)
  local grid = {
    width = #lines[1],
    height = #lines,
    up = -#lines[1],
    right = 1,
    down = #lines[1],
    left = -1,
    tiles = {},
  }

  for row = 1, grid.height do
    for column = 1, grid.width do
      local tile = lines[row]:sub(column, column)
      local position = ((row - 1) * grid.width) + (column - 1)

      -- Define the direction values for this tile, making sure to eliminate those that would make the rays get out of bounds
      local up = grid.up if row == 1 then up = nil end
      local right = grid.right if column == grid.width then right = nil end
      local down = grid.down if row == grid.height then down = nil end
      local left = grid.left if column == 1 then left = nil end

      -- Define the diversion(s) that each tile will apply to each type of entering ray
      grid.tiles[position] = { enteringRaysDirections = {}, diversion = {} }
      if tile == "-" then
        grid.tiles[position].diversion = { [grid.up] = { left, right }, [grid.right] = { right },    [grid.down] = { left, right }, [grid.left] = { left } }
      elseif tile == "|" then
        grid.tiles[position].diversion = { [grid.up] = { up },          [grid.right] = { up, down }, [grid.down] = { down },        [grid.left] = { up, down } }
      elseif tile == "\\" then
        grid.tiles[position].diversion = { [grid.up] = { left },        [grid.right] = { down },     [grid.down] = { right },       [grid.left] = { up } }
      elseif tile == "/" then
        grid.tiles[position].diversion = { [grid.up] = { right },       [grid.right] = { up },       [grid.down] = { left },        [grid.left] = { down } }
      elseif tile == "." then
        grid.tiles[position].diversion = { [grid.up] = { up },          [grid.right] = { right },    [grid.down] = { down },        [grid.left] = { left } }
      end

      -- Because of the nils defined above, the exit directions of the diversion table might have the wrong indices, so we correct that here
      for enterDirection, exitDirections in pairs(grid.tiles[position].diversion) do
        local correctedExitDirections = {}
        for _, exitDirection in pairs(exitDirections) do
          correctedExitDirections[#correctedExitDirections + 1] = exitDirection
        end
        grid.tiles[position].diversion[enterDirection] = correctedExitDirections
      end
    end
  end

  return grid
end

local function cast_ray(grid, rayToCast)
  local additionalRaysToCast = {}
  while rayToCast.direction ~= nil do
    -- Update the ray position
    rayToCast.position = rayToCast.position + rayToCast.direction

    -- Check if a previous ray has already entered the new position from the same direction, and stop the casting if so
    local enteringRaysDirections = grid.tiles[rayToCast.position].enteringRaysDirections
    for _, previousEnteringRayDirection in ipairs(enteringRaysDirections) do
      if previousEnteringRayDirection == rayToCast.direction then
        return additionalRaysToCast
      end
    end

    -- Register that the ray has entered this tile
    enteringRaysDirections[#enteringRaysDirections + 1] = rayToCast.direction

    -- Update the ray with its new direction, making sure to create new rays if necessary
    local nextDirections = grid.tiles[rayToCast.position].diversion[rayToCast.direction]
    if #nextDirections > 0 then
      for directionIndex = 1, #nextDirections do
        local nextDirection = nextDirections[directionIndex]
        if directionIndex == 1 then
          -- The ray now has a new direction to move towards
          rayToCast.direction = nextDirection
        else
          -- The additional directions will result in new rays that will also need to be cast later
          additionalRaysToCast[#additionalRaysToCast + 1] = { position = rayToCast.position, direction = nextDirection }
        end
      end
    else
      -- The ray cannot continue anymore, so the casting stops here
      rayToCast.direction = nil
    end
  end
  return additionalRaysToCast
end

local function count_energized_tiles(grid, initialRayToCast)
  -- Cast the ray and add the new generated rays to the table of rays to cast, repeating until the ray cannot continue
  local raysToCast = { initialRayToCast }
  while #raysToCast > 0 do
    local newRaysToCast = {}
    for _, rayToCast in ipairs(raysToCast) do
      local additionalRaysToCast = cast_ray(grid, rayToCast)
      for _, additionalRayToCast in ipairs(additionalRaysToCast) do
        newRaysToCast[#newRaysToCast + 1] = additionalRayToCast
      end
    end
    raysToCast = newRaysToCast
  end

  -- Count the number of energized tiles
  local energizedTiles = 0
  for _, tile in pairs(grid.tiles) do
    if #tile.enteringRaysDirections > 0 then
      energizedTiles = energizedTiles + 1
    end
  end
  return energizedTiles
end

local function part_1(grid)
  local initialRayToCast = { position = -1, direction = grid.right }
  return count_energized_tiles(grid, initialRayToCast)
end

local function part_2(grid)
  -- Create all the potential initial rays that can be cast to enter the grid from any direction and coordinate
  local initialRaysToCast = {}
  for column = 1, grid.width do
    initialRaysToCast[#initialRaysToCast + 1] = { position = (column - 1) - grid.width, direction = grid.down }
    initialRaysToCast[#initialRaysToCast + 1] = { position = ((grid.height - 1) * grid.width) + (column - 1) + grid.width, direction = grid.up }
  end
  for row = 1, grid.height do
    initialRaysToCast[#initialRaysToCast + 1] = { position = ((row - 1) * grid.width) - 1, direction = grid.right }
    initialRaysToCast[#initialRaysToCast + 1] = { position = ((row - 1) * grid.width) + (grid.width - 1) + 1, direction = grid.left }
  end

  -- Get the maximum number of energized tiles produced by any of the initial rays defined above
  local maxNumberOfEnergizedTiles = 0
  for _, initialRayToCast in ipairs(initialRaysToCast) do
    -- Reset the map for this new iteration
    for _, tileInfo in pairs(grid.tiles) do tileInfo.enteringRaysDirections = {} end
    maxNumberOfEnergizedTiles = math.max(maxNumberOfEnergizedTiles, count_energized_tiles(grid, initialRayToCast))
  end
  return maxNumberOfEnergizedTiles
end

print("part 1: " .. part_1(read_grid_info(read_lines(problemNumber))))
print("part 2: " .. part_2(read_grid_info(read_lines(problemNumber))))
