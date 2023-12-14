require "input_helper"

local problemNumber = 13

local function read_patterns(lines)
  local patterns = { { rows = {}, columns = {} } }

  for i = 1, #lines do
    local line = lines[i]
    local currentPattern = patterns[#patterns]
    if currentPattern.width == nil then currentPattern.width = #line end

    if line == nil or #line == 0 or line == "\n" or i == #lines then
      if line:find("[%.#]") then
        -- Ensure the last line is read even if there are no empty lines afterwards
        currentPattern.rows[#currentPattern.rows + 1] = line
      end

      -- Read the columns into their own arrays too to simplify the calculations later
      local numberOfColumns = #currentPattern.rows[1]
      for column = 1, numberOfColumns do
        local columnValue = ""
        for _, row in ipairs(currentPattern.rows) do
          columnValue = columnValue .. row:sub(column, column)
        end
        currentPattern.columns[#currentPattern.columns + 1] = columnValue
      end

      -- Start a new pattern for the next lines that will be read
      if i < #lines then
        patterns[#patterns + 1] = { rows = {}, columns = {} }
      end
    else
      -- Add the current line to the current pattern
      currentPattern.rows[#currentPattern.rows + 1] = line
    end
  end

  return patterns
end

local function find_mirrors(pattern, validNumberOfDifferences)
  local result = 0

  local isFindingRows = true
  for _, searchSpace in ipairs({pattern.rows, pattern.columns}) do
    for startIndex = 1, #searchSpace - 1 do
      local originalStartIndex = startIndex
      local endIndex = startIndex + 1

      local numberOfDifferences = 0
      while numberOfDifferences <= validNumberOfDifferences and startIndex >= 1 and endIndex <= #searchSpace do
        if searchSpace[startIndex] ~= searchSpace[endIndex] then
          for i = 1, #searchSpace[startIndex] do
            if searchSpace[startIndex]:sub(i, i) ~= searchSpace[endIndex]:sub(i, i) then
              numberOfDifferences = numberOfDifferences + 1
              if numberOfDifferences > validNumberOfDifferences then break end
            end
          end
        end
        startIndex = startIndex - 1
        endIndex = endIndex + 1
      end

      if numberOfDifferences == validNumberOfDifferences then
        if isFindingRows then
          result = result + 100 * originalStartIndex
        else
          result = result + originalStartIndex
        end
      end

    end
    isFindingRows = false
  end

  return result
end

local function find_all_mirrors(patterns, validNumberOfDifferences)
  local total = 0
  for _, pattern in ipairs(patterns) do
    total = total + find_mirrors(pattern, validNumberOfDifferences)
  end
  return total
end

local patterns = read_patterns(read_lines(problemNumber, true))
print("part 1: " .. find_all_mirrors(patterns, 0))
print("part 2: " .. find_all_mirrors(patterns, 1))
