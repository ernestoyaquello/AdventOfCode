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
  return 0
end

local lines = read_lines(problemNumber)
print("part 1: " .. part_1(lines))
print("part 2: " .. part_2(lines))
