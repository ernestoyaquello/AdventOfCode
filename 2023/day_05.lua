require "input_helper"

local problemNumber = 5

-- Reads the maps as specified in the input
local function read_maps(lines)
  local maps = {}

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
    end
  end

  return maps
end

-- Ensures that the shift ranges of each map cover every possible value, filling the gaps where necessary
local function fill_gaps(maps)
  for _, map in pairs(maps) do
    local newShiftRanges = {}
    local nextRangeStart = 0
    table.sort(map.shiftRanges, function(first, second) return first.rangeStart < second.rangeStart end)
    for i = 1, #map.shiftRanges do
      local shiftRange = map.shiftRanges[i]

      -- If necessary, fill the gap before this range with a new range that has a shift of zero
      if nextRangeStart < shiftRange.rangeStart then
        newShiftRanges[#newShiftRanges + 1] = { rangeStart = nextRangeStart, rangeEnd = shiftRange.rangeStart - 1, shift = 0 }
      end
      -- Add this preexisting range to the new list
      newShiftRanges[#newShiftRanges + 1] = shiftRange
      -- If necessary, fill the gap after the last range with a new range that has a shift of zero
      if i == #map.shiftRanges and shiftRange.rangeEnd < math.maxinteger then
        newShiftRanges[#newShiftRanges + 1] = { rangeStart = shiftRange.rangeEnd + 1, rangeEnd = math.maxinteger, shift = 0 }
      end

      -- Recalculate the next range start or break if we have reached the maximum end
      if newShiftRanges[#newShiftRanges].rangeEnd < math.maxinteger then
        nextRangeStart = newShiftRanges[#newShiftRanges].rangeEnd + 1
      else
        break
      end
    end
    map.shiftRanges = newShiftRanges
  end
  return maps
end

-- Recursively creates a complete list of shift subranges for the given shift range so that the final values can be looked up directly
local function get_flat_shift_ranges(maps, sourceName, sourceShiftRange)
  local shiftRanges = {}

  local destinationSourceName = maps[sourceName].nextSourceName
  if maps[destinationSourceName] == nil then
    -- Base case, we just return the specified source shift range because we cannot go any further
    shiftRanges[1] = sourceShiftRange
  else
    -- Iterate over the destination shift ranges to find the ones that overlap with the specified source shift range
    local sourceRangeStartInDestination = sourceShiftRange.rangeStart + sourceShiftRange.shift
    local sourceRangeEndInDestination = sourceShiftRange.rangeEnd + sourceShiftRange.shift
    local destinationShiftRanges = maps[destinationSourceName].shiftRanges
    for i = 1, #destinationShiftRanges do
      local destinationShiftRange = destinationShiftRanges[i]

      -- Only proceed further with this destination shift range if overlaps with the specified source shift range
      if (destinationShiftRange.rangeStart >= sourceRangeStartInDestination and destinationShiftRange.rangeStart <= sourceRangeEndInDestination)
          or (destinationShiftRange.rangeEnd >= sourceRangeStartInDestination and destinationShiftRange.rangeEnd <= sourceRangeEndInDestination)
          or (destinationShiftRange.rangeStart < sourceRangeStartInDestination and destinationShiftRange.rangeEnd > sourceRangeEndInDestination)
      then
        -- Reduce the shift range to adjust it to the limits imposed by the specified source shift range
        local adjustedDestinationShiftRange = {
          rangeStart = math.max(sourceRangeStartInDestination, destinationShiftRange.rangeStart),
          rangeEnd = math.min(sourceRangeEndInDestination, destinationShiftRange.rangeEnd),
          shift = destinationShiftRange.shift,
        }
        -- Update the start value for future iterations to the first value we have left out
        sourceRangeStartInDestination = adjustedDestinationShiftRange.rangeEnd + 1

        -- Use recursion to get the list of shift ranges that cover this entire destination shift range
        local finalDestinationShiftRanges = get_flat_shift_ranges(maps, destinationSourceName, adjustedDestinationShiftRange)
        for _, finalDestinationShiftRange in ipairs(finalDestinationShiftRanges) do
          -- Adjust the values to make sure the lookup of any number will work correctly
          finalDestinationShiftRange.rangeStart = finalDestinationShiftRange.rangeStart - sourceShiftRange.shift
          finalDestinationShiftRange.rangeEnd = finalDestinationShiftRange.rangeEnd - sourceShiftRange.shift
          finalDestinationShiftRange.shift = finalDestinationShiftRange.shift + sourceShiftRange.shift
          shiftRanges[#shiftRanges + 1] = finalDestinationShiftRange
        end

        -- Make sure to repeat with the same destination shift range in case it goes further than the current source shift range
        if sourceRangeStartInDestination < destinationShiftRange.rangeEnd then
          i = i - 1
        end
      end
    end
  end

  table.sort(shiftRanges, function(first, second) return first.rangeStart < second.rangeStart end)
  return shiftRanges
end

local function get_seed_data(lines)
  -- Read the seeds and the maps
  local seeds = {}
  for seed in lines[1]:gmatch("%d+") do
    seeds[#seeds + 1] = tonumber(seed)
  end
  local rawMaps = read_maps(lines)
  local maps = fill_gaps(rawMaps)

  -- Create a flat list of shift ranges where any value's final shift can be looked up directly starting from the seed map
  local seedShiftRanges = {}
  for _, shiftRange in ipairs(maps["seed"].shiftRanges) do
    local flatSeedShiftRanges = get_flat_shift_ranges(maps, "seed", shiftRange)
    for _, flatSeedShiftRange in ipairs(flatSeedShiftRanges) do
      seedShiftRanges[#seedShiftRanges + 1] = flatSeedShiftRange
    end
  end

  return seeds, seedShiftRanges
end

local function get_shifted_value(seedShiftRanges, value)
  for _, shiftRange in ipairs(seedShiftRanges) do
    if value >= shiftRange.rangeStart and value <= shiftRange.rangeEnd then
      return value + shiftRange.shift
    end
  end
  return value
end

local function part_1(seeds, seedShiftRanges)
  local minimum = nil

  for _, seed in ipairs(seeds) do
    local shiftedValue = get_shifted_value(seedShiftRanges, seed)
    if minimum == nil or shiftedValue < minimum then minimum = shiftedValue end
  end

  return minimum
end

local function part_2(seeds, seedShiftRanges)
  local minimum = nil

  -- Iterate over the seed ranges
  for i = 1, #seeds - 1, 2 do
    local seedRangeStart, seedRangeEnd = seeds[i], seeds[i] + seeds[i + 1] - 1
    -- Iterate over the seed shit ranges
    for j = 1, #seedShiftRanges do
      local seedShiftRange = seedShiftRanges[j]
      local subrangeStart = math.max(seedRangeStart, seedShiftRange.rangeStart)
      local subrangeEnd = math.min(seedRangeEnd, seedShiftRange.rangeEnd)
      if subrangeEnd >= subrangeStart then
        if (subrangeStart >= seedRangeStart and subrangeStart <= seedRangeEnd)
            or (subrangeEnd >= seedRangeStart and subrangeEnd <= seedRangeEnd)
            or (subrangeStart < seedRangeStart and subrangeEnd > seedRangeEnd)
        then
          -- For valid subranges that fit both within the seed range and within a seed shift range, get the first value, which will be the smallest
          local shiftedValue = get_shifted_value(seedShiftRanges, subrangeStart)
          if minimum == nil or shiftedValue < minimum then minimum = shiftedValue end

          -- Update the start value for future iterations to the first value we have left out
          seedRangeStart = subrangeEnd + 1
          -- Make sure to repeat with the same seed shift range in case it goes further than the current seed range
          if seedShiftRange.rangeEnd > seedRangeStart then
            j = j - 1
          end
        end
      end
    end
  end

  return minimum
end

local seeds, seedShiftRanges = get_seed_data(read_lines(problemNumber))
print("part 1: " .. part_1(seeds, seedShiftRanges))
print("part 2: " .. part_2(seeds, seedShiftRanges))
