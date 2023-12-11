require "input_helper"

local problemNumber = 11

local function read_galaxies(lines)
  local galaxies = {}
  local positionsThatExpand = {}

  -- Read the galaxies looking for them row by row, wich each row being an input line.
  -- Also save the positions that are inside empty rows in the table "positionsThatExpand".
  local numberOfRows = #lines
  local numberOfColumns = #lines[1]
  for row = 1, numberOfRows do
    local emptyRowPositions = {}
    for column = 1, numberOfColumns do
      local position = ((row - 1) * numberOfColumns) + (column - 1)
      local positionContent = lines[row]:sub(column, column)
      if positionContent == "#" then
        galaxies[#galaxies + 1] = position
      elseif positionContent == "." then
        emptyRowPositions[#emptyRowPositions + 1] = position
      end
    end
    if #emptyRowPositions == numberOfColumns then
      for _, positionThatExpand in ipairs(emptyRowPositions) do
        positionsThatExpand[positionThatExpand] = positionThatExpand
      end
    end
  end

  -- Save the positions that are inside empty columns in the table "positionsThatExpand".
  for column = 1, numberOfColumns do
    local emptyColumnPositions = {}
    for row = 1, numberOfRows do
      local positionContent = lines[row]:sub(column, column)
      if positionContent == "." then
        local position = ((row - 1) * numberOfColumns) + (column - 1)
        emptyColumnPositions[#emptyColumnPositions + 1] = position
      else
        break
      end
    end
    if #emptyColumnPositions == numberOfRows then
      for _, positionThatExpand in ipairs(emptyColumnPositions) do
        positionsThatExpand[positionThatExpand] = positionThatExpand
      end
    end
  end

  return galaxies, positionsThatExpand, numberOfColumns
end

local function sum_pair_paths(galaxies, positionsThatExpand, numberOfColumns, expansionRate)
  local result = 0

  for i = 1, #galaxies - 1 do
    local firstGalaxyPosition = galaxies[i]
    local firstGalaxyRow = math.floor(firstGalaxyPosition / numberOfColumns)
    local firstGalaxyColumn = math.floor(firstGalaxyPosition % numberOfColumns)
    for j = i + 1, #galaxies do
      local shortestPath = 0
      local secondGalaxyPosition = galaxies[j]
      local secondGalaxyRow = math.floor(secondGalaxyPosition / numberOfColumns)
      local secondGalaxyColumn = math.floor(secondGalaxyPosition % numberOfColumns)

      -- Move vertically, counting the steps of the path
      local rowIncrement = 1
      if secondGalaxyRow < firstGalaxyRow then rowIncrement = -1 end
      for row = firstGalaxyRow + rowIncrement, secondGalaxyRow, rowIncrement do
        local visitedPosition = (row * numberOfColumns) + firstGalaxyColumn
        if positionsThatExpand[visitedPosition] ~= nil then
          -- This is a expanding position, so this step counts as more than one
          shortestPath = math.floor(shortestPath + expansionRate)
        else
          shortestPath = shortestPath + 1
        end
      end

      -- Move horizontally, counting the steps of the path
      local columnIncrement = 1
      if secondGalaxyColumn < firstGalaxyColumn then columnIncrement = -1 end
      for column = firstGalaxyColumn + columnIncrement, secondGalaxyColumn, columnIncrement do
        local visitedPosition = (firstGalaxyRow * numberOfColumns) + column
        if positionsThatExpand[visitedPosition] ~= nil then
          -- This is a expanding position, so this step counts as more than one
          shortestPath = math.floor(shortestPath + expansionRate)
        else
          shortestPath = shortestPath + 1
        end
      end

      -- Add path distance to the total
      result = result + shortestPath
    end
  end

  return result
end

local galaxies, positionsThatExpand, numberOfColumns = read_galaxies(read_lines(problemNumber))
print("part 1: " .. sum_pair_paths(galaxies, positionsThatExpand, numberOfColumns, 2))
print("part 2: " .. sum_pair_paths(galaxies, positionsThatExpand, numberOfColumns, 1000000))
