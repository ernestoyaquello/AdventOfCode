require "input_helper"

local problemNumber = 10

local function read_map(lines)
  local map = {}
  local origin
  local numberOfColumns = #lines[1]

  -- Read data into a map with each tile position as an index
  for row, line in ipairs(lines) do
    for column = 1, #line do
      local tileType = line:sub(column, column)
      local position = #line * (row - 1) + (column - 1)
      map[position] = { position = position, type = tileType, neighbours = {} }
      if tileType == "S" then origin = map[position] end
    end
  end

  -- Find the neighbour options for this type of tile
  for tilePosition, tile in pairs(map) do
    local neighhbourOptions = {
      { offset = -numberOfColumns, connectors = { "|", "7", "F" } },
      { offset = -1, connectors = {  "-", "L", "F" } },
      { offset = 1, connectors = { "-", "J", "7" } },
      { offset = numberOfColumns, connectors = { "|", "L", "J" } },
    }
    if tile.type == "|" then
      neighhbourOptions = {
        { offset = -numberOfColumns, connectors = { "|", "7", "F" } },
        { offset = numberOfColumns, connectors = { "|", "L", "J" } },
      }
    elseif tile.type == "-" then
      neighhbourOptions = {
        { offset = -1, connectors = {  "-", "L", "F" } },
        { offset = 1, connectors = { "-", "J", "7" } },
      }
    elseif tile.type == "L" then
      neighhbourOptions = {
        { offset = -numberOfColumns, connectors = {  "|", "7", "F" } },
        { offset = 1, connectors = { "-", "J", "7" } },
      }
    elseif tile.type == "J" then
      neighhbourOptions = {
        { offset = -numberOfColumns, connectors = {  "|", "7", "F" } },
        { offset = -1, connectors = { "-", "L", "F" } },
      }
    elseif tile.type == "7" then
      neighhbourOptions = {
        { offset = -1, connectors = {  "-", "L", "F" } },
        { offset = numberOfColumns, connectors = { "|", "L", "J" } },
      }
    elseif tile.type == "F" then
      neighhbourOptions = {
        { offset = 1, connectors = {  "-", "J", "7" } },
        { offset = numberOfColumns, connectors = { "|", "L", "J" } },
      }
    elseif tile.type == "." then
      neighhbourOptions = {}
    end

    -- Find the actual neighbours of each tile
    for _, neighhbourOption in ipairs(neighhbourOptions) do
      local adjacentPosition = tilePosition + neighhbourOption.offset
      local isActualNeighbour = math.abs(neighhbourOption.offset) > 1 or (math.floor(adjacentPosition / numberOfColumns) == math.floor(tilePosition / numberOfColumns))
      if isActualNeighbour then
        local neighbour = map[adjacentPosition]
        if neighbour ~= nil then
          local isValidNeighbour = false
          for _, validConnector in ipairs(neighhbourOption.connectors) do
            if validConnector == neighbour.type then
              isValidNeighbour = true
              break
            end
          end
          if isValidNeighbour then
            tile.neighbours[#tile.neighbours + 1] = neighbour
          end
        end
      end
    end
  end

  -- Determine which type of tile the origin one is
  local originNeighbourOffsets = {}
  for _, originNeighbour in ipairs(origin.neighbours) do
    originNeighbourOffsets[#originNeighbourOffsets + 1] = originNeighbour.position - origin.position
  end
  table:sort(originNeighbourOffsets)
  if originNeighbourOffsets[1] == -numberOfColumns and originNeighbourOffsets[2] == numberOfColumns then
    origin.type = "|"
  elseif originNeighbourOffsets[1] == -1 and originNeighbourOffsets[2] == 1 then
    origin.type = "-"
  elseif originNeighbourOffsets[1] == -numberOfColumns and originNeighbourOffsets[2] == 1 then
    origin.type = "L"
  elseif originNeighbourOffsets[1] == -numberOfColumns and originNeighbourOffsets[2] == -1 then
    origin.type = "J"
  elseif originNeighbourOffsets[1] == -1 and originNeighbourOffsets[2] == numberOfColumns then
    origin.type = "7"
  elseif originNeighbourOffsets[1] == 1 and originNeighbourOffsets[2] == numberOfColumns then
    origin.type = "F"
  end

  return map, origin, numberOfColumns
end

local function part_1(origin)
  local maxSteps = 0

  -- Iterate through the loop in both directions to find the fastest way to get to each tile
  -- (As usual, we use the position as the key because Lua doesn't have sets)
  origin.minStepsToArrive = 0
  local loopTiles = { [origin.position] = origin }
  for _, originNeighbour in ipairs(origin.neighbours) do
    local visitedPositions = { [origin.position] = origin.position }
    local currentTile = originNeighbour
    local steps = 0
    while visitedPositions[currentTile.position] == nil do
      loopTiles[currentTile.position] = currentTile

      -- Save the result directly on the tile object
      steps = steps + 1
      visitedPositions[currentTile.position] = currentTile.position
      if currentTile.minStepsToArrive == nil or steps < currentTile.minStepsToArrive then
        currentTile.minStepsToArrive = steps
      end

      -- Find the next non-visited neighbour to visit, if any
      for _, neighbour in ipairs(currentTile.neighbours) do
        if visitedPositions[neighbour.position] == nil then
          currentTile = neighbour
          break
        end
      end
    end
  end

  -- Find the maximum number of steps needed to get to a tile
  for _, tile in pairs(loopTiles) do
    maxSteps = math.max(maxSteps, tile.minStepsToArrive)
  end

  return maxSteps
end

local function part_2(map, origin, numberOfColumns)
  local numberOfEnclosedTiles = 0

  -- Iterate through the loop and, for each loop tile, find all the tiles placed to its right side in a straight line
  -- (until a new loop tile is found or until the end of the map is reached). These will be the enclosed tiles.
  -- Ideally, we would first find the direction of the loop (left or right) by going through it and counting he amount
  -- of left and right turns. But it can only go either left or right, so who can be bothered, I tried left and it
  -- didn't work, so right it is. ¯\_(ツ)_/¯
  -- (Also, this whole code, and even the algorithm itself, is a massive inefficient mess, but meh, it works.)
  origin.neighbours = { origin.neighbours[1] }
  local visitedPositions = {}
  local enclosedTiles = {}
  local currentTile = origin
  local directionToLook = nil
  while visitedPositions[currentTile.position] == nil do
    visitedPositions[currentTile.position] = currentTile.position

    for _, neighbour in ipairs(currentTile.neighbours) do
      if visitedPositions[neighbour.position] == nil or neighbour == origin then
        local moveOffset = neighbour.position - currentTile.position

        local newDirectionToLook = nil
        if moveOffset == -numberOfColumns then -- going north
          newDirectionToLook = 1
        elseif moveOffset == 1 then -- going east
          newDirectionToLook = numberOfColumns
        elseif moveOffset == numberOfColumns then -- going south
          newDirectionToLook = -1
        elseif moveOffset == -1 then -- going west
          newDirectionToLook = -numberOfColumns
        end

        -- Look for tiles in the appropriate directions, which include the last one and the
        -- new one to make sure we don't leave any enclosed tiles behind when counting them
        for _, direction in ipairs({directionToLook, newDirectionToLook}) do
          if direction ~= nil then
            local auxPosition = currentTile.position + direction
            while map[auxPosition] ~= nil
            and map[auxPosition].minStepsToArrive == nil
            and (math.abs(direction) > 1 or (math.floor(auxPosition / numberOfColumns) == math.floor(currentTile.position / numberOfColumns)))
            do
              enclosedTiles[auxPosition] = 1
              map[auxPosition].isEnclosed = true
              auxPosition = auxPosition + direction
            end
          end
        end

        directionToLook = newDirectionToLook
        currentTile = neighbour
        break
      end
    end
  end

  for _, _ in pairs(enclosedTiles) do
    numberOfEnclosedTiles = numberOfEnclosedTiles + 1
  end

  return numberOfEnclosedTiles
end

local map, origin, numberOfColumns = read_map(read_lines(problemNumber))
print("part 1: " .. part_1(origin))
print("part 2: " .. part_2(map, origin, numberOfColumns))
