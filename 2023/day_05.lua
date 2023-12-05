require "input_helper"

local problemNumber = 5

local function read_maps(lines)
  local seeds, maps = {}, {}

  -- Get the set of seeds first
  for seed in lines[1]:gmatch("%d+") do
    seeds[#seeds + 1] = tonumber(seed)
  end

  -- Get the maps now
  local currentSourceName
  for lineIndex = 2, #lines do
    local line = lines[lineIndex]
    local newCurrentSourceName = line:gmatch("(%w+)%-to%-%w+")()
    if newCurrentSourceName ~= nil then
      -- This line is the start of a new map
      maps[newCurrentSourceName] = { nextSourceName = line:gmatch("%w+%-to%-(%w+)")(), shiftRanges = {} }
      currentSourceName = newCurrentSourceName
    else
      -- This line is just another shift range to be added to the map we are currently reading
      local sourceRangeStart = tonumber(line:gmatch("%d+ (%d+) %d+")())
      local destinationRangeStart = tonumber(line:gmatch("(%d+) %d+ %d+")())
      local rangeLength = tonumber(line:gmatch("%d+ %d+ (%d+)")())
      local shiftRanges = maps[currentSourceName].shiftRanges
      shiftRanges[#shiftRanges + 1] = {
        rangeStart = sourceRangeStart,
        rangeEnd = sourceRangeStart + rangeLength - 1,
        shift = destinationRangeStart - sourceRangeStart,
      }
      table.sort(shiftRanges, function(first, second) return first.rangeStart < second.rangeStart end)
    end
  end

  return seeds, maps
end

local function get_next_map_value(maps, sourceName, value)
  if maps[sourceName] ~= nil then
    for _, shiftRanges in ipairs(maps[sourceName].shiftRanges) do
      if value >= shiftRanges.rangeStart and value <= shiftRanges.rangeEnd then
        return value + shiftRanges.shift
      end
    end
  end
  return value
end

local function get_final_value(maps, sourceName, mapValue)
  local result  = nil

  local nextMapValue = get_next_map_value(maps, sourceName, mapValue)
  if maps[sourceName] ~= nil then
    local nextSourceName = maps[sourceName].nextSourceName
    result = get_final_value(maps, nextSourceName, nextMapValue)
  else
    result = nextMapValue
  end

  return result
end

local function part_1(seeds, maps)
  local minimum = nil

  for _, seed in ipairs(seeds) do
    local mapValue = get_final_value(maps, "seed", seed)
    if minimum == nil or mapValue < minimum then minimum = mapValue end
  end

  return minimum
end

local function part_2(seeds, maps)
  local minimum = nil

  for i = 1, #seeds - 1, 2 do
    local seedRangeStart, seedRangeLength = seeds[i], seeds[i + 1]
    for seed = seedRangeStart, (seedRangeStart + seedRangeLength - 1) do
      local mapValue = get_final_value(maps, "seed", seed)
      if minimum == nil or mapValue < minimum then minimum = mapValue end
    end
  end

  return minimum
end

local seeds, maps = read_maps(read_lines(problemNumber))
print("part 1: " .. part_1(seeds, maps))
print("part 2: " .. part_2(seeds, maps))
