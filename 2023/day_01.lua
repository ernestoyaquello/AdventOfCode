require "input_helper"

local problemNumber = 1

local digitsMap = {
  one   = "1", two   = "2", three = "3", four  = "4", five  = "5", six  = "6",  seven = "7", eight = "8", nine  = "9";
  ["1"] = "1", ["2"] = "2", ["3"] = "3", ["4"] = "4", ["5"] = "5", ["6"] = "6", ["7"] = "7", ["8"] = "8", ["9"] = "9", ["0"] = "0",
}

local function part_1(lines)
  local sum = 0

  for _, line in ipairs(lines) do
    -- Find numerical digits within the line
    local digits = {}
    for digit in line:gmatch("%d") do digits[#digits + 1] = digit end

    -- Construct the number using the first and the last found digits, then add it to the result
    local lineNumber = tonumber(digits[1] .. digits[#digits])
    sum = sum + lineNumber
  end

  return sum
end

local function part_2(lines, digitsMap)
  local sum = 0

  for _, line in ipairs(lines) do
    local digits = {}

    -- Search for all the possible symbols within this line
    for digitSymbol, digit in pairs(digitsMap) do
      local digitSearchPosition = 1
      while digitSearchPosition <= #line do
        local digitStartPosition = line:find(digitSymbol, digitSearchPosition)
        if digitStartPosition ~= nil then
          -- Save the digit we found in the table of digits for this line, then advance the search position
          digits[#digits + 1] = { digit = digit, startPosistion = digitStartPosition }
          digitSearchPosition = digitStartPosition + #digitSymbol
        else
          -- No more matches for this digit symbol on this line, so we break out of the search loop
          break
        end
      end
    end

    -- Construct the number using the first and the last found digits, then add it to the result
    table.sort(digits, function (first, second) return first.startPosistion < second.startPosistion end)
    local lineNumber = tonumber(digits[1].digit .. digits[#digits].digit)
    sum = sum + lineNumber
  end

  return sum
end

local lines = read_lines(problemNumber)
print("part 1: " .. part_1(lines))
print("part 2: " .. part_2(lines, digitsMap))
