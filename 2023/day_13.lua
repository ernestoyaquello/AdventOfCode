require "input_helper"

local problemNumber = 13

local function read_patterns(lines)
  local patterns = {
    { rows = {}, columns = {} }
  }

  for i = 1, #lines do
    local line = lines[i]
    local currentPattern = patterns[#patterns]
    if currentPattern.width == nil then currentPattern.width = #line end

    if line == nil or #line == 0 or line == "\n" or i == #lines then
      if line:find("[%.#]") then
        currentPattern.rows[#currentPattern.rows + 1] = line
      end

      -- Read the columns into their own arrays too
      local numberOfColumns = #currentPattern.rows[1]
      for column = 1, numberOfColumns do
        local columnValue = ""
        for _, row in ipairs(currentPattern.rows) do
          columnValue = columnValue .. row:sub(column, column)
        end
        currentPattern.columns[#currentPattern.columns + 1] = columnValue
      end

      -- Start a new pattern for the next lines
      if i < #lines then
        patterns[#patterns + 1] = { rows = {}, columns = {} }
      end
    else
      currentPattern.rows[#currentPattern.rows + 1] = line
    end
  end

  return patterns
end

local function part_1(patterns)
  local result = 0

  for _, pattern in ipairs(patterns) do
    local isFindingRows = true
    for _, searchSpace in ipairs({pattern.rows, pattern.columns}) do
      for startIndex = 1, #searchSpace - 1 do
        local originalStartIndex = startIndex
        local endIndex = startIndex + 1
        local isMatch = true
        while isMatch and startIndex >= 1 and endIndex <= #searchSpace do
          if searchSpace[startIndex] ~= searchSpace[endIndex] then
            isMatch = false
            break
          end
          startIndex = startIndex - 1
          endIndex = endIndex + 1
        end
        if isMatch then
          if isFindingRows then
            result = result + 100 * originalStartIndex
          else
            result = result + originalStartIndex
          end
        end
      end
      isFindingRows = false
    end
  end

  return result
end

local function part_2(patterns)
  local result = 0

  return result
end

local patterns = read_patterns(read_lines(problemNumber, true))
print("part 1: " .. part_1(patterns))
print("part 2: " .. part_2(patterns))
