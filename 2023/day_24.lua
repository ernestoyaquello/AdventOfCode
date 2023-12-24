require "input_helper"

local problemNumber = 24

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

local function read_hailstones(lines, coordGen)
  local hailstones = {}

  for _, line in ipairs(lines) do
    local px, py, pz, vx, vy, vz = line:gmatch("(-?%d+), *(-?%d+), *(-?%d+) *@ *(-?%d+), *(-?%d+), *(-?%d+) *")()
    local hailstone = {
      x = tonumber(px),
      y = tonumber(py),
      z = tonumber(pz),
      vx = tonumber(vx),
      vy = tonumber(vy),
      vz = tonumber(vz),
    }
    hailstone.get_slope_y = function () return hailstone.vy / hailstone.vx end
    hailstone.get_x = function (y) return ((y - hailstone.y) / hailstone.get_slope_y()) + hailstone.x end
    hailstone.get_y = function (x) return (hailstone.get_slope_y() * (x - hailstone.x)) + hailstone.y end
    hailstones[#hailstones + 1] = hailstone
  end

  return hailstones
end

local function part_1(hailstones, min, max)
  local numberOfCrossingPaths = 0

  for i = 1, #hailstones - 1 do
    for j = i + 1, #hailstones do
      local first = hailstones[i]
      local second = hailstones[j]

      -- y = ax + c
      local a = first.get_slope_y()
      local c = first.get_y(0)

      -- y = bx + d
      local b = second.get_slope_y()
      local d = second.get_y(0)

      local xIntersection = (d - c) / (a - b)
      local yIntersection = (a * xIntersection) + c
      local theyAreParallel = xIntersection == math.huge or yIntersection == math.huge

      -- Verify that the intersection happens in the right area and not in the past
      if not theyAreParallel
        and (xIntersection >= min and xIntersection <= max) and (yIntersection >= min and yIntersection <= max)
        and ((xIntersection >= first.x and first.vx >= 0) or (xIntersection < first.x and first.vx < 0))
        and ((xIntersection >= second.x and second.vx >= 0) or (xIntersection < second.x and second.vx < 0))
        and ((yIntersection >= first.y and first.vy >= 0) or (yIntersection < first.y and first.vy < 0))
        and ((yIntersection >= second.y and second.vy >= 0) or (yIntersection < second.y and second.vy < 0))
      then
        numberOfCrossingPaths = numberOfCrossingPaths + 1
      end
    end
  end

  return numberOfCrossingPaths
end

local function part_2(hailstones, coordGen)
  return 0
end

local coordGen = coordinate_generator()
print("part 1: " .. part_1(read_hailstones(read_lines(problemNumber), coordGen), 200000000000000, 400000000000000))
print("part 2: " .. part_2(read_hailstones(read_lines(problemNumber), coordGen), coordGen))
