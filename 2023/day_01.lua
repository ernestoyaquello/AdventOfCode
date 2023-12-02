require "input_helper"

local problemNumber = 1

function part_1(lines)
  local sum = 0

  for _, line in ipairs(lines) do
    local digits = {}
    for digit in line:gmatch("(%d)") do
      digits[#digits + 1] = digit
    end
    local number = tonumber(digits[1] .. digits[#digits])
    sum = sum + number
  end

  return sum
end

function part_2(lines)
  local sum = 0
  local digitsMap = {
    ["1"] = "1", ["2"] = "2", ["3"] = "3", ["4"] = "4", ["5"] = "5", ["6"] = "6", ["7"] = "7", ["8"] = "8", ["9"] = "9", ["0"] = "0",
      one = "1",   two = "2", three = "3",  four = "4",  five = "5",   six = "6", seven = "7", eight = "8",  nine = "9",
  }

  for _, line in ipairs(lines) do
    local firstDigit, lastDigit

    for digitWord, digitValue in pairs(digitsMap) do
      local findStart = 1
      while findStart <= #line do
        local digitStart, digitEnd = line:find(digitWord, findStart)
        if digitStart == nil then
          break
        else
          if firstDigit == nil or digitStart < firstDigit.digitStart then firstDigit = { digitStart = digitStart, digit = digitValue } end
          if lastDigit == nil or digitEnd > lastDigit.digitEnd then lastDigit = { digitEnd = digitEnd, digit = digitValue } end
          findStart = findStart + 1
        end
      end
    end

    local number = tonumber(firstDigit.digit .. lastDigit.digit)
    sum = sum + number
  end

  return sum
end

local lines = read_lines(problemNumber)
print("part 1: " .. part_1(lines))
print("part 2: " .. part_2(lines))
