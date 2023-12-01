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
