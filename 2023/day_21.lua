require "input_helper"

local problemNumber = 21

-- Generates a small table representing a coordinate, making sure that coordinates with the same
-- content (x, y) are actually the same instance. That way, we can compare them properly.
local function coordinate_generator()
  local coordinates = {}
  return function(x, y)
    if coordinates[x] == nil then coordinates[x] = {} end
    if coordinates[x][y] == nil then coordinates[x][y] = { x = x, y = y } end
    return coordinates[x][y]
  end
end

local function read_map(lines, coordGen, acceptOutOfBounds)
  local map = {
    width = #lines[1],
    height = #lines,
    positions = {},
  }

  for y = 1, #lines do
    local row = lines[y]
    for x = 1, #row do
      local positionCharacter = row:sub(x, x)
      if positionCharacter == "." or positionCharacter == "S" then
        local position = coordGen(x, y)
        map.positions[position] = { position = position, neighbours = {}, hasElf = positionCharacter == "S" }
      end
    end
  end

  for position, positionInfo in pairs(map.positions) do
    local adjacentPositions = {
      coordGen(position.x, position.y - 1), -- top
      coordGen(position.x + 1, position.y), -- right
      coordGen(position.x, position.y + 1), -- bottom
      coordGen(position.x - 1, position.y), -- left
    }
    for _, adjacentPosition in ipairs(adjacentPositions) do
      if map.positions[adjacentPosition] ~= nil
        or (acceptOutOfBounds and (adjacentPosition.x > map.width or adjacentPosition.x < 1 or adjacentPosition.y > map.height or adjacentPosition.y < 1))
      then
        local adjacentPositionInOriginalMap = coordGen(1 + ((adjacentPosition.x - 1) % map.width), 1 + ((adjacentPosition.y - 1) % map.height))
        positionInfo.neighbours[#positionInfo.neighbours + 1] = {
          neighbour = map.positions[adjacentPositionInOriginalMap],
          shift = { x = adjacentPosition.x - adjacentPositionInOriginalMap.x, y = adjacentPosition.y - adjacentPositionInOriginalMap.y },
        }
      end
    end
  end

  return map
end

local function count_steps(lines, coordGen, acceptOutOfBounds, steps)
  local map = read_map(lines, coordGen, acceptOutOfBounds)
  map.minX, map.minY = 1, 1
  map.maxX, map.maxY = map.width, map.height

  local currentMap = map

  for step = 1, steps do
    local nextMap = {
      positions = {},
      minX = currentMap.minX,
      minY = currentMap.minY,
      maxX = currentMap.maxX,
      maxY = currentMap.maxY,
    }
    for position, positionInfo in pairs(currentMap.positions) do
      if nextMap.positions[position] == nil then
        nextMap.positions[position] = { position = position, neighbours = positionInfo.neighbours, hasElf = false }
      end
      if positionInfo.hasElf then
        for _, neighbourInfo in ipairs(positionInfo.neighbours) do
          local neighbour = neighbourInfo.neighbour
          local realNeighbourPosition = coordGen(neighbour.position.x + neighbourInfo.shift.x, neighbour.position.y + neighbourInfo.shift.y)
          nextMap.minX = math.min(nextMap.minX, realNeighbourPosition.x)
          nextMap.minY = math.min(nextMap.minY, realNeighbourPosition.y)
          nextMap.maxX = math.max(nextMap.maxX, realNeighbourPosition.x)
          nextMap.maxY = math.max(nextMap.maxY, realNeighbourPosition.y)

          if nextMap.positions[realNeighbourPosition] == nil then
            local realNeighbourNeighbours = neighbour.neighbours
            if realNeighbourPosition ~= neighbour.position then
              realNeighbourNeighbours = {}
              for _, neighbourNeighbourInfo in ipairs(neighbour.neighbours) do
                realNeighbourNeighbours[#realNeighbourNeighbours + 1] = {
                  neighbour = neighbourNeighbourInfo.neighbour,
                  shift = { x = neighbourInfo.shift.x + neighbourNeighbourInfo.shift.x, y = neighbourInfo.shift.y + neighbourNeighbourInfo.shift.y },
                }
              end
            end
            nextMap.positions[realNeighbourPosition] = { position = realNeighbourPosition, neighbours = realNeighbourNeighbours, hasElf = true }
          else
            nextMap.positions[realNeighbourPosition].hasElf = true
          end
        end
      end
    end

    -- This is the code I used to figure out stuff about the data
    --[[
    local shifts = {
      coordGen(-1, -1), coordGen(0, -1), coordGen(1, -1);
      coordGen(-1,  0), coordGen(0,  0), coordGen(1,  0);
      coordGen(-1,  1), coordGen(0,  1), coordGen(1,  1);
    }
    print("step=" .. step)
    for _, shift in ipairs(shifts) do
      --local hash = "|shift={x=".. shift.x.. ",y=" .. shift.y .. "}, "
      local elvesCount = 0
      for y = 1, map.height do
        for x = 1, map.width do
          local position = coordGen(x + (shift.x * map.width), y + (shift.y * map.height))
          if nextMap.positions[position] ~= nil and nextMap.positions[position].hasElf then
            --hash = hash .. "x=" .. position.x .. ",y=" .. position.y .. "|"
            elvesCount = elvesCount + 1
          end
        end
      end
      print("shift={x=".. shift.x.. ",y=" .. shift.y .. "}, elves=" .. elvesCount)
    end
    print("")
    ]]

    -- This is the code I used to visualise the grid after each step
    --[[
    local output = "Step " .. step
    for y = nextMap.minY, nextMap.maxY do
      output = output .. "\n"
      for x = nextMap.minX, nextMap.maxX do
        local space = " "
        if y >= 1 and y <= map.height and (x == 0 or x == map.width) then
          space = "|"
        end

        local position = coordGen(x, y)
        local positionInOriginalMap = coordGen(1 + ((x - 1) % map.width), 1 + ((y - 1) % map.height))
        if map.positions[positionInOriginalMap] ~= nil then
          if nextMap.positions[position] == nil or not nextMap.positions[position].hasElf then
            output = output .. "." .. space
          else
            output = output .. "O" .. space
          end
        else
          output = output .. "#" .. space
        end
      end
    end
    output = output .. "\n"
    --print(output)
    ]]

    currentMap = nextMap
  end

  local totalElves = 0
  for _, positionInfo in pairs(currentMap.positions) do
    if positionInfo.hasElf then
      totalElves = totalElves + 1
    end
  end

  return totalElves
end

-- This code is based on the things I calculated and figured out on paper.
-- It only works for my input, and the only reason why it even works is that
-- the input data was actually prepared to make things "easy", otherwise I
-- would have never managed. I don't understand how some people can figure
-- this out in 15 minutes, I am not sure we belong to the same species!
local function part_2()
  local numberOfSteps = 26501365
  local height = 1 + (numberOfSteps * 2) -- 53002731
  local heightInBlocks = math.floor(height / 131) -- we know this has no decimals (404601)

  -- This code to calculate the elves that exist in full squares is very bad and slow,
  -- but I cannot be bothered to find more patterns and try to write something proper.
  -- This works, so...
  local elvesInFullBlocks = 0
  for i = 1, heightInBlocks - 4, 2 do
    for j = 1, i do
      if j % 2 == 0 then
        elvesInFullBlocks = elvesInFullBlocks + (2 * 7697)
      else
        elvesInFullBlocks = elvesInFullBlocks + (2 * 7730)
      end
    end
  end
  for j = 1, heightInBlocks - 2 do
    if j % 2 == 0 then
      elvesInFullBlocks = elvesInFullBlocks + 7697
    else
      elvesInFullBlocks = elvesInFullBlocks + 7730
    end
  end

  local numberOfAlmostEmptyBlocksPerSide = math.floor((heightInBlocks - 1) / 2)
  local numberOfAlmostFullBlocksPerSide = numberOfAlmostEmptyBlocksPerSide - 1

  return elvesInFullBlocks
    + 5793 -- top pointy block
    + 5809 -- right pointy block
    + 5825 -- bottom pointy block
    + 5809 -- left pointy block
    -- step 196 to see the amounts of elves on the almost empty squares
    + (numberOfAlmostEmptyBlocksPerSide * 989) -- top left side
    + (numberOfAlmostEmptyBlocksPerSide * 993) -- top right side
    + (numberOfAlmostEmptyBlocksPerSide * 984) -- bottom right side
    + (numberOfAlmostEmptyBlocksPerSide * 976) -- bottom left side
    -- step 327 to see the amounts of elves on the almost full squares
    + (numberOfAlmostFullBlocksPerSide * 6743) -- top left side
    + (numberOfAlmostFullBlocksPerSide * 6759) -- top right side
    + (numberOfAlmostFullBlocksPerSide * 6747) -- bottom right side
    + (numberOfAlmostFullBlocksPerSide * 6763) -- bottom left side
end

print("part 1: " .. count_steps(read_lines(problemNumber), coordinate_generator(), false, 64))
print("part 2: " .. part_2())
--print("part 2: " .. count_steps(read_lines(problemNumber), coordinate_generator(), true, 26501365))
