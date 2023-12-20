require "input_helper"

local problemNumber = 18

-- Generates a small table representing a coordinate, making sure that coordinates with the same
-- content (x, y, z) are actually the same instance. That way, we can compare them properly.
local function coordinate_generator()
  local coordinates = {}
  return function(x, y, z)
    if coordinates[x] == nil then coordinates[x] = {} end
    if coordinates[x][y] == nil then coordinates[x][y] = {} end
    if z == nil then z = "none" end
    if coordinates[x][y][z] == nil then coordinates[x][y][z] = { x = x, y = y, z = z } end
    return coordinates[x][y][z]
  end
end

local function read_dig_plan(lines)
  local digPlan = {}
  for _, line in ipairs(lines) do
    local direction, steps, color = line:gmatch("([UDLR]) (%d+) %(#([0-9a-f]+)%)")()
    digPlan[#digPlan + 1] = { direction = direction, meters = tonumber(steps), color = tonumber(color, 16), colorReadable = color }
  end
  return digPlan
end

local function count_number_of_digged_cubes(digPlan, coordGen)
  local currentPosition = coordGen(0, 0)
  local diggedPositions = { [currentPosition] = 1 }
  local topLeftCorner = { x = 0, y = 0 }
  local bottomRightCorner = { x = 0, y = 0 }
  for i = 1, #digPlan do
    local step = digPlan[i]

    -- Calculate the offset to navigate in the direction specified by this step of the plan
    local directionOffset = { x = 0, y = 0 }
    if step.direction == "U" then directionOffset.y = -1
    elseif step.direction == "R" then directionOffset.x = 1
    elseif step.direction == "D" then directionOffset.y = 1
    elseif step.direction == "L" then directionOffset.x = -1
    end

    -- Move in the appropriate direction as far as indicated by the plan step, making sure to mark the visited positions
    for _ = 1, step.meters do
      currentPosition = coordGen(
        currentPosition.x + directionOffset.x,
        currentPosition.y + directionOffset.y
      )
      diggedPositions[currentPosition] = 1

      -- Update the corners to make sure we know how big the final grid is
      topLeftCorner.x = math.min(topLeftCorner.x, currentPosition.x)
      topLeftCorner.y = math.min(topLeftCorner.y, currentPosition.y)
      bottomRightCorner.x = math.max(bottomRightCorner.x, currentPosition.x)
      bottomRightCorner.y = math.max(bottomRightCorner.y, currentPosition.y)
    end
  end

  -- Cast lines from the top to the bottom and count the total number of digged cubes,
  -- but iterating over the digged positions only, not over all the actual positions.
  -- Still a lot of iterations, this could be improved in many ways, for example, by
  -- iterating only over the key positions, which is probably what we were supposed to
  -- do here. However, the implementation for that approach can be a little bit more
  -- fiddly than it seems. And this works (slowly, but still), so who can be bothered.
  local sortedDiggedPositions = {}
  for diggedPosition in pairs(diggedPositions) do
    sortedDiggedPositions[#sortedDiggedPositions + 1] = diggedPosition
  end
  table.sort(sortedDiggedPositions, function(a, b) return a.x < b.x or (a.x == b.x and a.y < b.y) end)
  local numberOfDiggedCubes = 0
  local x = sortedDiggedPositions[1].x
  local isCurrentlyInside = false
  local lastDiggedPosition = nil
  for _, diggedPosition in ipairs(sortedDiggedPositions) do
    if diggedPosition.x ~= x then
      x = diggedPosition.x
      isCurrentlyInside = false
    end

    local y = diggedPosition.y
    local isDiggedPosition = diggedPositions[coordGen(x, y)] ~= nil
    if isCurrentlyInside or isDiggedPosition then
      local increment = 1
      if isCurrentlyInside and lastDiggedPosition ~= nil then
        increment = y - lastDiggedPosition.y
      end
      numberOfDiggedCubes = numberOfDiggedCubes + increment
    end
    -- If the current position was digged and the one to the left too, we need to switch the "inside" state
    if isDiggedPosition and diggedPositions[coordGen(x - 1, y)] ~= nil then
      isCurrentlyInside = not isCurrentlyInside
    end

    lastDiggedPosition = diggedPosition
  end

  return numberOfDiggedCubes
end

local function part_1(digPlan, coordGen)
  return count_number_of_digged_cubes(digPlan, coordGen)
end

local function part_2(digPlan, coordGen)
  for i = 1, #digPlan do
    local step = digPlan[i]
    local directionCode = step.colorReadable:sub(6, 6)
    local direction = ""
    if directionCode == "0" then direction = "R"
    elseif directionCode == "1" then direction = "D"
    elseif directionCode == "2" then direction = "L"
    elseif directionCode == "3" then direction = "U"
    end
    step.direction = direction
    step.meters = tonumber(step.colorReadable:sub(1, 5), 16)
  end

  return count_number_of_digged_cubes(digPlan, coordGen)
end

print("part 1: " .. part_1(read_dig_plan(read_lines(problemNumber)), coordinate_generator()))
print("part 2: " .. part_2(read_dig_plan(read_lines(problemNumber)), coordinate_generator()))
