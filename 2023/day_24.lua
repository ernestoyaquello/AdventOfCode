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

      -- Verify that the intersection happens in the right area and not in the past
      if (xIntersection >= min and xIntersection <= max) and (yIntersection >= min and yIntersection <= max)
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

local function part_2(hailstones)
  -- This is the equation of the line for the rock that will hit every hailstone, of which we don't know the value of any variable:
  -- x = ((rx2 - rx1) * t) + rx1
  -- y = ((ry2 - ry1) * t) + ry1
  -- z = ((rz2 - rz1) * t) + rz1
  for index, hailstone in ipairs(hailstones) do
    -- This is the equation of the line traced by this specific hailstone when falling, of which we know all variable values but "t":
    -- x = ((hx2 - hx1) * t) + hx1
    -- y = ((hy2 - hy1) * t) + hy1
    -- z = ((hz2 - hz1) * t) + hz1

    -- All we need to do is to make x, y, z, and t equal for both the hailstone and the rock, that way we will find the impact point.
    -- Ideally, I would use some library to solve this system of equations, but trying to make any Lua libraries work on Windows has
    -- been a nightmare, so I am simply printing the equations and solving things manually.
    -- P.S. Most of the printed lines can be ignored, we only need to solve the system of equations formed by the first few lines.
    print("((rx2 - rx1) * r" .. index .. "t) + rx1 = (" .. (hailstone.x + hailstone.vx) - hailstone.x .. " * r" .. index .. "t) + " .. hailstone.x)
    print("((ry2 - ry1) * r" .. index .. "t) + ry1 = (" .. (hailstone.y + hailstone.vy) - hailstone.y .. " * r" .. index .. "t) + " .. hailstone.y)
    print("((rz2 - rz1) * r" .. index .. "t) + rz1 = (" .. (hailstone.z + hailstone.vz) - hailstone.z .. " * r" .. index .. "t) + " .. hailstone.z)
  end

  -- The result was calculated manually by solving the system of equations printed above:
  -- rx1 = 172543224455736
  -- ry1 = 348373777394510
  -- rz1 = 148125938782131
  -- rx1 + ry1 + rz1 = 669042940632377
  return 669042940632377
end

local coordGen = coordinate_generator()
print("part 1: " .. part_1(read_hailstones(read_lines(problemNumber), coordGen), 200000000000000, 400000000000000))
print("part 2: " .. part_2(read_hailstones(read_lines(problemNumber), coordGen)))
