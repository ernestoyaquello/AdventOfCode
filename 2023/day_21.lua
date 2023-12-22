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
        local correctedAdjacentPosition = coordGen(1 + ((adjacentPosition.x - 1) % map.width), 1 + ((adjacentPosition.y - 1) % map.height))
        positionInfo.neighbours[#positionInfo.neighbours + 1] = {
          neighbour = map.positions[correctedAdjacentPosition],
          shift = { x = adjacentPosition.x - correctedAdjacentPosition.x, y = adjacentPosition.y - correctedAdjacentPosition.y },
        }
      end
    end
  end

  return map
end

local function count_steps(lines, coordGen, acceptOutOfBounds, steps)
  local map = read_map(lines, coordGen, acceptOutOfBounds)
  local currentMap = map

  for _ = 1, steps do
    local newMap = { positions = {} }
    for position, positionInfo in pairs(currentMap.positions) do
      if newMap.positions[position] == nil then
        newMap.positions[position] = { position = position, neighbours = positionInfo.neighbours, hasElf = false }
      end
      if positionInfo.hasElf then
        for _, neighbourInfo in ipairs(positionInfo.neighbours) do
          local neighbour = neighbourInfo.neighbour
          local realNeighbourPosition = coordGen(neighbour.position.x + neighbourInfo.shift.x, neighbour.position.y + neighbourInfo.shift.y)

          if newMap.positions[realNeighbourPosition] == nil then
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
            newMap.positions[realNeighbourPosition] = { position = realNeighbourPosition, neighbours = realNeighbourNeighbours, hasElf = true }
          else
            newMap.positions[realNeighbourPosition].hasElf = true
          end
        end
      end
    end
    currentMap = newMap
  end

  local totalElves = 0
  for _, positionInfo in pairs(currentMap.positions) do
    if positionInfo.hasElf then
      totalElves = totalElves + 1
    end
  end

  return totalElves
end

print("part 1: " .. count_steps(read_lines(problemNumber), coordinate_generator(), false, 64))
print("part 2: " .. count_steps(read_lines(problemNumber), coordinate_generator(), true, 26501365))
