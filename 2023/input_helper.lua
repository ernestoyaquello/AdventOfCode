function read_lines(problemNumber, includeBlankLines)
  local filename = (problemNumber < 10) and ("0" .. problemNumber) or tostring(problemNumber)
  local filepath = "inputs/" .. filename .. ".txt"
  local file = io.open(filepath, "rb") -- r read mode and b binary mode

  local lines = {}
  for line in io.lines(filepath) do
    if includeBlankLines or (line ~= nil and line ~= "") then -- discard blank lines when needed
      lines[#lines + 1] = line
    end
  end

  file:close()
  return lines
end

function read_sequences(problemNumber, valuesAreNumbers)
  local sequences = {}

  local lines = read_lines(problemNumber)
  for _, line in ipairs(lines) do
    local sequence = {}
    line = line .. " "
    for value in line:gmatch("([^ ]*) +") do
      if valuesAreNumbers then value = tonumber(value) end
      sequence[#sequence + 1] = value
    end
    sequences[#sequences + 1] = sequence
  end

  return sequences
end