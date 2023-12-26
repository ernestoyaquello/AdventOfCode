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

local function part_2(hailstones, coordGen)
  -- Find parallel lines or intersecting lines in order to have three points that form a plane
  -- TODO No lines are parallel or interesect in the real input, so this solution won't work
  local planePoints = {}
  for i = 1, #hailstones - 1 do
    for j = i + 1, #hailstones do
      local first = hailstones[i]
      local second = hailstones[j]
      local linesAreParallel = (first.vx / second.vx) == (first.vy / second.vy) and (first.vy / second.vy) == (first.vz / second.vz)

      -- x = ((hx2 - hx1) * t) + hx1
      -- y = ((hy2 - hy1) * t) + hy1
      -- z = ((hz2 - hz1) * t) + hz1
      local hx1, hy1, hz1 = first.x, first.y, first.z
      local hx2, hy2, hz2 = first.x + first.vx, first.y + first.vy, first.z + first.vz
      
      -- x = ((h2x2 - h2x1) * t2) + h2x1
      -- y = ((h2y2 - h2y1) * t2) + h2y1
      -- z = ((h2z2 - h2z1) * t2) + h2z1
      local h2x1, h2y1, h2z1 = second.x, second.y, second.z
      local h2x2, h2y2, h2z2 = second.x + second.vx, second.y + second.vy, second.z + second.vz

      local t = (-h2x1*h2y2 + h2x1*hy1 + h2x2*h2y1 - h2x2*hy1 - h2y1*hx1 + h2y2*hx1)/(h2x1*hy1 - h2x1*hy2 - h2x2*hy1 + h2x2*hy2 - h2y1*hx1 + h2y1*hx2 + h2y2*hx1 - h2y2*hx2)
      local t2 = (((hy2 - hy1) * t) + hy1 - h2y1) / (h2y2 - h2y1)
      local linesIntersect = math.abs(t) ~= math.huge and math.abs(t2) ~= math.huge
        and ((hx2 - hx1) * t) + hx1 == ((h2x2 - h2x1) * t2) + h2x1
        and ((hy2 - hy1) * t) + hy1 == ((h2y2 - h2y1) * t2) + h2y1
        and ((hz2 - hz1) * t) + hz1 == ((h2z2 - h2z1) * t2) + h2z1

      local linesAreInTheSamePlane = linesAreParallel or linesIntersect
      if linesAreInTheSamePlane then
        planePoints[#planePoints + 1] = coordGen(first.x, first.y, first.z)
        planePoints[#planePoints + 1] = coordGen(second.x, second.y, second.z)
        planePoints[#planePoints + 1] = coordGen(second.x - second.vx, second.y - second.vy, second.z - second.vz)
        break
      end
    end
    if #planePoints > 0 then
      break
    end
  end

  -- Figure out the plane
  -- Plane equation: (perpendicularVectorToPlane.x * x) + (perpendicularVectorToPlane.y * y) + (perpendicularVectorToPlane.z * z) + k = 0
  local firstPlaneVector = coordGen(planePoints[2].x - planePoints[1].x, planePoints[2].y - planePoints[1].y, planePoints[2].z - planePoints[1].z)
  local secondPlaneVector = coordGen(planePoints[3].x - planePoints[1].x, planePoints[3].y - planePoints[1].y, planePoints[3].z - planePoints[1].z)
  local perpendicularVectorToPlane = coordGen(
    firstPlaneVector.y * secondPlaneVector.z - firstPlaneVector.z * secondPlaneVector.y,
    firstPlaneVector.z * secondPlaneVector.x - firstPlaneVector.x * secondPlaneVector.z,
    firstPlaneVector.x * secondPlaneVector.y - firstPlaneVector.y * secondPlaneVector.x
  )
  local k = -(perpendicularVectorToPlane.x * planePoints[1].x) - (perpendicularVectorToPlane.y * planePoints[1].y) - (perpendicularVectorToPlane.z * planePoints[1].z)

  -- Find the intersection points between the plane and a couple of lines that aren't contained within it
  local stoneTrayectoryPoints = {}
  for _, hailstone in ipairs(hailstones) do
    local hailstonePosition = coordGen(hailstone.x, hailstone.y, hailstone.z)
    if k ~= -(perpendicularVectorToPlane.x * hailstonePosition.x) - (perpendicularVectorToPlane.y * hailstonePosition.y) - (perpendicularVectorToPlane.z * hailstonePosition.z) then
      -- x = ((hx2 - hx1) * t) + hx1
      -- y = ((hy2 - hy1) * t) + hy1
      -- z = ((hz2 - hz1) * t) + hz1
      local hx1, hy1, hz1 = hailstone.x, hailstone.y, hailstone.z
      local hx2, hy2, hz2 = hailstone.x + hailstone.vx, hailstone.y + hailstone.vy, hailstone.z + hailstone.vz
      --(perpendicularVectorToPlane.x * (((hx2 - hx1) * t) + hx1)) + (perpendicularVectorToPlane.y * (((hy2 - hy1) * t) + hy1)) + (perpendicularVectorToPlane.z * (((hz2 - hz1) * t) + hz1)) + k = 0
      local t = (hx1 * perpendicularVectorToPlane.x + hy1 * perpendicularVectorToPlane.y + hz1 * perpendicularVectorToPlane.z + k) / (hx1 * perpendicularVectorToPlane.x - hx2 * perpendicularVectorToPlane.x + hy1 * perpendicularVectorToPlane.y - hy2 * perpendicularVectorToPlane.y + hz1 * perpendicularVectorToPlane.z - hz2 * perpendicularVectorToPlane.z)
      local hailstoneImpactPosition = coordGen(
        ((hx2 - hx1) * t) + hx1,
        ((hy2 - hy1) * t) + hy1,
        ((hz2 - hz1) * t) + hz1
      )
      stoneTrayectoryPoints[#stoneTrayectoryPoints + 1] = hailstoneImpactPosition
      if #stoneTrayectoryPoints == 2 then
        break
      end
    end
  end

  -- Using the points found above, figure out the line within the plane that crosses across all the other lines (this is the line where the stone will travel)
  -- x = ((x2 - x1) * t) + x1
  -- y = ((y2 - y1) * t) + y1
  -- z = ((z2 - z1) * t) + z1
  local x1, y1, z1 = stoneTrayectoryPoints[1].x, stoneTrayectoryPoints[1].y, stoneTrayectoryPoints[1].z
  local x2, y2, z2 = stoneTrayectoryPoints[2].x, stoneTrayectoryPoints[2].y, stoneTrayectoryPoints[2].z

  local impacts = {}
  for _, hailstone in ipairs(hailstones) do
    -- x = ((p2.x - p.x) * t2) + p.x
    -- y = ((p2.y - p.y) * t2) + p.y
    -- z = ((p2.z - p.z) * t2) + p.z
    local p = coordGen(hailstone.x, hailstone.y, hailstone.z)
    local p2 = coordGen(hailstone.x + hailstone.vx, hailstone.y + hailstone.vy, hailstone.z + hailstone.vz)
    -- Solve the equation system generated by making the x, y and z equals in order to find the intersection between this line and the trayectory one
    local t2 = (-p.x * y1 + p.x * y2 + p.y * x1 - p.y * x2 - x1 * y2 + x2 * y1) / (p2.x * y1 - p2.x * y2 - p2.y * x1 + p2.y * x2 - p.x * y1 + p.x * y2 + p.y * x1 - p.y * x2)
    --local t = (((p2.z - p.z) * t2) + p.z - z1) / (z2 - z1)
    local impactPoint = coordGen(
      ((p2.x - p.x) * t2) + p.x,
      ((p2.y - p.y) * t2) + p.y,
      ((p2.z - p.z) * t2) + p.z
    )
    local timeOfImpact = 0
    if hailstone.vx ~= 0 then timeOfImpact = (impactPoint.x - p.x) / hailstone.vx
    elseif hailstone.vy ~= 0 then timeOfImpact = (impactPoint.y - p.y) / hailstone.vy
    elseif hailstone.vz ~= 0 then timeOfImpact = (impactPoint.z - p.z) / hailstone.vz
    end
    impacts[#impacts + 1] = { impactPoint = impactPoint, timeOfImpact = timeOfImpact }
  end
  table.sort(impacts, function (a, b) return a.timeOfImpact < b.timeOfImpact end)

  local throwVelocity = coordGen(
    (impacts[2].impactPoint.x - impacts[1].impactPoint.x) / (impacts[2].timeOfImpact - impacts[1].timeOfImpact),
    (impacts[2].impactPoint.y - impacts[1].impactPoint.y) / (impacts[2].timeOfImpact - impacts[1].timeOfImpact),
    (impacts[2].impactPoint.z - impacts[1].impactPoint.z) / (impacts[2].timeOfImpact - impacts[1].timeOfImpact)
  )
  local throwPosition = coordGen(
    impacts[1].impactPoint.x - (throwVelocity.x * impacts[1].timeOfImpact),
    impacts[1].impactPoint.y - (throwVelocity.y * impacts[1].timeOfImpact),
    impacts[1].impactPoint.z - (throwVelocity.z * impacts[1].timeOfImpact)
  )

  return math.floor(throwPosition.x + throwPosition.y + throwPosition.z)
end

local coordGen = coordinate_generator()
print("part 1: " .. part_1(read_hailstones(read_lines(problemNumber), coordGen), 200000000000000, 400000000000000))
print("part 2: " .. part_2(read_hailstones(read_lines(problemNumber), coordGen), coordGen))
