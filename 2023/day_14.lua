require "input_helper"

local problemNumber = 14

local function functional_map(tbl, f)
  local t = {}
  for k, v in pairs(tbl) do
      t[k] = f(v)
  end
  return t
end

local function read_map(lines)
  local map = {
    width = #lines[1],
    height = #lines,
    movingRocks = {},
    staticRocks = {},
    rocksByPosition = {},
  }

  for row = 1, #lines do
    local line = lines[row]
    for column = 1, #line do
      local character = line:sub(column, column)
      local position = ((row - 1) * map.width) + (column - 1)
      if character == "O" then
        map.movingRocks[#map.movingRocks + 1] = { row = row, column = column, position = position, type = "moving" }
        map.rocksByPosition[position] = map.movingRocks[#map.movingRocks]
      elseif character == "#" then
        map.staticRocks[#map.staticRocks + 1] = { row = row, column = column, position = position, type = "static" }
        map.rocksByPosition[position] = map.staticRocks[#map.staticRocks]
      end
    end
  end

  return map
end

local function tilt_rock(map, movingRock, rowShift, columnShift)
  movingRock.fullyMoved = true
  while (movingRock.row + rowShift) >= 1 and (movingRock.row + rowShift) <= map.height
    and (movingRock.column + columnShift) >= 1 and (movingRock.column + columnShift) <= map.width
  do
    local newPosition = movingRock.position + ((rowShift * map.width) + columnShift)
    local blockingRock = map.rocksByPosition[newPosition]
    if blockingRock ~= nil then
      if blockingRock.type == "moving" and not blockingRock.fullyMoved then
        movingRock.fullyMoved = false
      end
      break
    else
      map.rocksByPosition[movingRock.position] = nil
      movingRock.row = movingRock.row + rowShift
      movingRock.column = movingRock.column + columnShift
      movingRock.position = newPosition
      map.rocksByPosition[newPosition] = movingRock
    end
  end
end

local function tilt_map(map, rowShift, columnShift)
  local rocksToMove = {}
  for _, movingRock in ipairs(map.movingRocks) do
    rocksToMove[#rocksToMove + 1] = movingRock
    movingRock.fullyMoved = false
  end

  while #rocksToMove > 0 do
    local newRocksToMove = {}
    for _, rockToMove in ipairs(rocksToMove) do
      tilt_rock(map, rockToMove, rowShift, columnShift)
      if not rockToMove.fullyMoved then
        newRocksToMove[#newRocksToMove + 1] = rockToMove
      end
    end
    rocksToMove = newRocksToMove
  end
end

local function count_load(map)
  local total = 0
  for _, movingRock in ipairs(map.movingRocks) do
    local rockLoad = map.height - movingRock.row + 1
    total = total + rockLoad
  end
  return total
end

local function part_1(map)
  tilt_map(map, -1, 0)
  return count_load(map)
end

local function part_2(map)
  local mapHashes = {}
  local repeatedMapHash = nil
  local loadValuesInLoop = {}

  for i = 1, 1000000000 do
    tilt_map(map, -1, 0) -- north
    tilt_map(map, 0, -1) -- west
    tilt_map(map, 1, 0) -- south
    tilt_map(map, 0, 1) -- east

    table.sort(map.movingRocks, function (a, b) return a.position < b.position end)
    local mapHash = table.concat(functional_map(map.movingRocks, function(r) return r.position end), ",")

    if mapHashes[mapHash] ~= nil then
      if repeatedMapHash == nil then
        repeatedMapHash = mapHash
        loadValuesInLoop = {}
      elseif mapHash == repeatedMapHash then
        local loopLoadValueIndex = (1000000000 - i + 1) % #loadValuesInLoop
        return loadValuesInLoop[loopLoadValueIndex]
      end
    end

    if repeatedMapHash ~= nil then
      loadValuesInLoop[#loadValuesInLoop + 1] = count_load(map)
    end
    mapHashes[mapHash] = mapHash
  end

  return -1
end

print("part 1: " .. part_1(read_map(read_lines(problemNumber))))
print("part 2: " .. part_2(read_map(read_lines(problemNumber))))
