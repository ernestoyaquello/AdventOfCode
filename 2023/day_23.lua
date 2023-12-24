require "input_helper"

local problemNumber = 23

-- Generates a small table representing a coordinate, making sure that coordinates with the same
-- content (x, y) are actually the same instance. That way, we can compare them properly.
local function coordinate_generator()
  local coordinates = {}
  return function(x, y)
    if coordinates[x] == nil then coordinates[x] = {} end
    if coordinates[x][y] == nil then coordinates[x][y] = { x = x, y = y } end
    return coordinates[x][y]
  end
end

local function read_map(lines, coordGen, ignoreSlopes)
  local map = {
    width = #lines[1] - 2,
    height = #lines,
    tiles = {},
  }

  -- Read tiles into the map
  for y = 1, map.height do
    local line = lines[y]
    for x = 1, map.width do
      local tileCharacter = line:sub(x + 1, x + 1) -- ignore first and last column
      local tilePosition = coordGen(x, y)
      if tileCharacter == "." and not (x == 1 and y == 1) then
        map.tiles[tilePosition] = { position = tilePosition, character = ".", direction = nil, oppositeDirection = nil, connections = {} }
      elseif tileCharacter == "^" then
        map.tiles[tilePosition] = { position = tilePosition, character = "^", direction = "up", oppositeDirection = "down", connections = {} }
      elseif tileCharacter == ">" then
        map.tiles[tilePosition] = { position = tilePosition, character = ">", direction = "right", oppositeDirection = "left", connections = {} }
      elseif tileCharacter == "v" or (x == 1 and y == 1) then
        map.tiles[tilePosition] = { position = tilePosition, character = "v", direction = "down", oppositeDirection = "up", connections = {} }
      elseif tileCharacter == "<" then
        map.tiles[tilePosition] = { position = tilePosition, character = "<", direction = "left", oppositeDirection = "right", connections = {} }
      end
    end
  end

  -- Create connections
  local connectionOffsets = {
    { direction = "up", offset = coordGen(0, -1) },
    { direction = "right", offset = coordGen(1, 0) },
    { direction = "down", offset = coordGen(0, 1) },
    { direction = "left", offset = coordGen(-1, 0) },
  }
  for position, tileInfo in pairs(map.tiles) do
    for _, connectionOffset in ipairs(connectionOffsets) do
      if tileInfo.direction == nil or ignoreSlopes or tileInfo.direction == connectionOffset.direction then
        local connectedPosition = coordGen(position.x + connectionOffset.offset.x, position.y + connectionOffset.offset.y)
        if map.tiles[connectedPosition] ~= nil then
          tileInfo.connections[connectionOffset.direction] = map.tiles[connectedPosition]
        end
      end
    end
  end

  -- Filter out connections that end up leading us against a slope, which isn't allowed
  if not ignoreSlopes then
    for position, tileInfo in pairs(map.tiles) do
      if tileInfo.direction ~= nil then
        if tileInfo.position.x < map.width or tileInfo.position.y < map.height then
          local currentTileInfo = tileInfo
          local nextTileInfo = map.tiles[tileInfo.connections[tileInfo.direction].position]

          while nextTileInfo ~= nil and nextTileInfo.direction == nil do
            nextTileInfo.direction = currentTileInfo.direction
            if nextTileInfo.direction == "up" then nextTileInfo.oppositeDirection = "down" end
            if nextTileInfo.direction == "right" then nextTileInfo.oppositeDirection = "left" end
            if nextTileInfo.direction == "down" then nextTileInfo.oppositeDirection = "up" end
            if nextTileInfo.direction == "left" then nextTileInfo.oppositeDirection = "right" end
            nextTileInfo.connections[nextTileInfo.oppositeDirection] = nil

            local nextTileNumberOfConnections = 0
            for nextTileConnectionDirection in pairs(nextTileInfo.connections) do
              if nextTileConnectionDirection ~= nextTileInfo.direction then
                nextTileInfo.direction = nil
                nextTileInfo.oppositeDirection = nil
              end
              nextTileNumberOfConnections = nextTileNumberOfConnections + 1
            end

            if nextTileInfo.direction == nil and nextTileNumberOfConnections == 1 then
              for nextTileConnectionDirection in pairs(nextTileInfo.connections) do
                nextTileInfo.direction = nextTileConnectionDirection
                if nextTileInfo.direction == "up" then nextTileInfo.oppositeDirection = "down" end
                if nextTileInfo.direction == "right" then nextTileInfo.oppositeDirection = "left" end
                if nextTileInfo.direction == "down" then nextTileInfo.oppositeDirection = "up" end
                if nextTileInfo.direction == "left" then nextTileInfo.oppositeDirection = "right" end
              end
            end

            currentTileInfo = nextTileInfo
            nextTileInfo = nextTileInfo.connections[nextTileInfo.direction]
          end
        end
      end
    end
  end

  --[[
  -- Print map
  for y = 1, map.height do
    local rowOutput = ""
    for x = 1, map.width do
      local tileInfo = map.tiles[coordGen(x, y)]
      if tileInfo == nil then
        rowOutput = rowOutput .. "###"
      elseif tileInfo.direction == nil then
        rowOutput = rowOutput .. " . "
      elseif tileInfo.direction == "up" then
        rowOutput = rowOutput .. " ^ "
      elseif tileInfo.direction == "right" then
        rowOutput = rowOutput .. " > "
      elseif tileInfo.direction == "down" then
        rowOutput = rowOutput .. " v "
      elseif tileInfo.direction == "left" then
        rowOutput = rowOutput .. " < "
      end
    end
    print(rowOutput)
  end
  ]]

  return map
end

local function part_1(lines, coordGen)
  local longestPathLength = 0

  local function find_longest_path_recursively(map, currentPath)
    local nextCurrentPath = {}
    for _, pathTileInfo in ipairs(currentPath) do
      nextCurrentPath[#nextCurrentPath + 1] = pathTileInfo
    end

    local lastTileInfo = nextCurrentPath[#nextCurrentPath]
    while lastTileInfo.direction ~= nil and (lastTileInfo.position.x ~= map.with or lastTileInfo.position.y ~= map.height) do
      lastTileInfo = lastTileInfo.connections[lastTileInfo.direction]
      if lastTileInfo ~= nil then
        nextCurrentPath[#nextCurrentPath + 1] = lastTileInfo
      else
        break
      end
    end

    if lastTileInfo == nil then
      longestPathLength = math.max(longestPathLength, #nextCurrentPath)
    else
      for _, connectedTileInfo in pairs(lastTileInfo.connections) do
        nextCurrentPath[#nextCurrentPath + 1] = connectedTileInfo
        find_longest_path_recursively(map, nextCurrentPath)
        table.remove(nextCurrentPath, #nextCurrentPath)
      end
    end
  end

  local map = read_map(lines, coordGen)
  find_longest_path_recursively(map, { map.tiles[coordGen(1, 1)] })
  return longestPathLength - 1
end

local function part_2(lines, coordGen)
  local longestPathLength = 0

  -- The path is full of long corridors, so I am sure I could create a simplified graph.
  -- However, I don't know how much that would help, and since this eventually gives a
  -- result anyway, there is no need for it. There might be a more elegant intended solution
  -- here, but brute force does the job once again.
  local function find_longest_path_recursively(map, currentPath, visitedPositions)
    local lastTileInfo = currentPath[#currentPath]
    if lastTileInfo.position.x == map.width and lastTileInfo.position.y == map.height then
      if #currentPath > longestPathLength then
        longestPathLength = #currentPath
        print(longestPathLength)
      end
    else
      for _, connectedTileInfo in pairs(lastTileInfo.connections) do
        if not visitedPositions[connectedTileInfo.position] then
          visitedPositions[connectedTileInfo.position] = true
          currentPath[#currentPath + 1] = connectedTileInfo
          find_longest_path_recursively(map, currentPath, visitedPositions)
          table.remove(currentPath, #currentPath)
          visitedPositions[connectedTileInfo.position] = nil
        end
      end
    end
  end

  local map = read_map(lines, coordGen, true)
  find_longest_path_recursively(map, { map.tiles[coordGen(1, 1)] }, { [coordGen(1, 1)] = true })
  return longestPathLength - 1
end

print("part 1: " .. part_1(read_lines(problemNumber), coordinate_generator()))
print("part 2: " .. part_2(read_lines(problemNumber), coordinate_generator()))