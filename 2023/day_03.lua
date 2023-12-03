require "input_helper"

local problemNumber = 3

-- Get the offsets that can be added to a grid position to get to its eight adjacent positions
local function get_adjacent_offsets(gridWidth)
  local index = 0
  local adjacentOffsets = { -gridWidth - 1, -gridWidth, -gridWidth + 1; -1, 1; gridWidth - 1, gridWidth, gridWidth + 1; }
  return function()
    index = index + 1
    return adjacentOffsets[index]
  end
end

-- Find pattern matches in the provided input string and save them in the provided save table, using each character position as an index
local function save_matches(input, pattern, saveTable, positionOffset)
  local searchPosition = 1
  while searchPosition <= #input do
    local matchStart, matchEnd = input:find(pattern, searchPosition)
    if matchStart ~= nil then
      local match = input:sub(matchStart, matchEnd)
      local matchInfo = { value = match, position = positionOffset + matchStart }
      -- Just in case the match has more than one character, we ensure that it can be looked up using any of its character positions
      for matchCharacterOffset = 0, matchEnd - matchStart do
        saveTable[matchInfo.position + matchCharacterOffset] = matchInfo
      end
      searchPosition = matchEnd + 1
    else
      break
    end
  end
end

-- Get the engine scheme modelled in a way that facilitates the fast and easy look-up of both characters and numbers
local function read_engine_schema(lines)
  local engineSchema = {
    numbers = {}, -- for each digit of a number, there will be an entry here with the digit position as the key
    symbols = {}, -- for each symbol, there will be an entry here with the symbol position as the key
    gridWidth = #lines[1],
  }

  for row, line in ipairs(lines) do
    local positionOffset = (row - 1) * engineSchema.gridWidth
    save_matches(line, "%d+", engineSchema.numbers, positionOffset)
    save_matches(line, "[^%.%d]", engineSchema.symbols, positionOffset)
  end

  return engineSchema
end

local function part_1(engineSchema)
  local result = 0
  local validNumbers = {}

  for symbolPosition in pairs(engineSchema.symbols) do
    for adjacentOffset in get_adjacent_offsets(engineSchema.gridWidth) do
      local adjacentNumberInfo = engineSchema.numbers[symbolPosition + adjacentOffset]
      if adjacentNumberInfo ~= nil then
        -- Use the position as the key to avoid duplicates (Lua has doesn't have sets...)
        validNumbers[adjacentNumberInfo.position] = tonumber(adjacentNumberInfo.value)
      end
    end
  end

  for _, number in pairs(validNumbers) do
    result = result + number
  end

  return result
end

local function part_2(engineSchema)
  local result = 0

  for symbolPosition, symbolInfo in pairs(engineSchema.symbols) do
    if symbolInfo.value == "*" then
      -- Find the adjacent numbers this star symbol has
      local adjacentNumbers = {}
      for adjacentOffset in get_adjacent_offsets(engineSchema.gridWidth) do
        local adjacentNumberInfo = engineSchema.numbers[symbolPosition + adjacentOffset]
        if adjacentNumberInfo ~= nil then
          -- Use the position as the key to avoid duplicates (Lua has doesn't have sets...)
          adjacentNumbers[adjacentNumberInfo.position] = tonumber(adjacentNumberInfo.value)
        end
      end

      -- Calculate the gear ratio
      local gearRatio = 1
      local numberOfAdjacentNumbers = 0
      for _, adjacentNumber in pairs(adjacentNumbers) do
        gearRatio = gearRatio * adjacentNumber
        numberOfAdjacentNumbers = numberOfAdjacentNumbers + 1
        if numberOfAdjacentNumbers > 2 then break end -- no need to keep looping, two is already too many
      end

      -- If the gear ratio is valid because the symbol has exactly two adjacent numbers, then let's update the result
      if numberOfAdjacentNumbers == 2 then
        result = result + gearRatio
      end
    end
  end

  return result
end

local engineSchema = read_engine_schema(read_lines(problemNumber))
print("part 1: " .. part_1(engineSchema))
print("part 2: " .. part_2(engineSchema))
