require "input_helper"

local problemNumber = 1

local digitsMap = {
  one   = "1", two   = "2", three = "3", four  = "4", five  = "5", six  = "6",  seven = "7", eight = "8", nine  = "9";
  ["1"] = "1", ["2"] = "2", ["3"] = "3", ["4"] = "4", ["5"] = "5", ["6"] = "6", ["7"] = "7", ["8"] = "8", ["9"] = "9", ["0"] = "0",
}

local function part_1(lines)
  local sum = 0

  for _, line in ipairs(lines) do
    local digits = {}
    for digit in line:gmatch("%d") do
      digits[#digits + 1] = digit
    end
    local lineNumber = tonumber(digits[1] .. digits[#digits])
    sum = sum + lineNumber
  end

  return sum
end

local function part_2(lines, digitsMap)
  local sum = 0

  for _, line in ipairs(lines) do
    local firstDigit = { startPos = #line + 1, endPos = #line + 1 }
    local lastDigit = { startPos = 0, endPos = 0 }

    for digitSymbol, digit in pairs(digitsMap) do
      local nextDigitSymbolSearchPosition = 1
      while nextDigitSymbolSearchPosition <= #line do
        local digitStartPos, digitEndPos = line:find(digitSymbol, nextDigitSymbolSearchPosition)
        if digitStartPos == nil then
          -- No more matches for this digit symbol on this line, break out of the search loop
          break
        else
          local digitModel = {
            startPos = digitStartPos,
            endPos = digitStartPos + #digitSymbol - 1,
            digit = digit,
            digitSymbol = digitSymbol,
          }

          -- Check if this digit symbol is positioned before the current first or of it starts in the same position but is shorter
          if digitStartPos < firstDigit.startPos or (digitStartPos == firstDigit.startPos and #digitSymbol < #firstDigit.digitSymbol) then
            firstDigit = digitModel
          end

          -- Check if this digit symbol ends after the current last or if it ends in the same position but is shorter
          if digitEndPos > lastDigit.endPos or (digitEndPos == lastDigit.endPos and #digitSymbol < #lastDigit.digitSymbol) then
            lastDigit = digitModel
          end

          -- Continue the search right after the first digit symbol position just in case the symbol overlaps with itself
          nextDigitSymbolSearchPosition = digitStartPos + 1
        end
      end
    end

    local lineNumber = tonumber(firstDigit.digit .. lastDigit.digit)
    sum = sum + lineNumber
  end

  return sum
end

local lines = read_lines(problemNumber)
print("part 1: " .. part_1(lines))
print("part 2: " .. part_2(lines, digitsMap))
