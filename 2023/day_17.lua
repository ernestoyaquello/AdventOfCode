require "input_helper"

local problemNumber = 17

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

local function calculate_average_heat_loss(map)
  local totalHeatLoss = 0
  local totalNodes = 0
  for _, node in pairs(map.nodes) do
    totalHeatLoss = totalHeatLoss + node.heatLoss
    totalNodes = totalNodes + 1
  end
  return totalHeatLoss / totalNodes
end

local function read_map_info(lines, coordGen)
  local map = { width = #lines[1], height = #lines, nodes = {} }

  -- Read nodes
  for y = 1, map.height do
    for x = 1, map.width do
      local heatLoss = tonumber(lines[y]:sub(x, x))
      local position = coordGen(x, y)
      map.nodes[position] = { position = position, heatLoss = heatLoss, connections = {} }
    end
  end

  -- Define the connections between adjacent nodes
  local destinationPosition = coordGen(map.width, map.height)
  local averageHeatLoss = calculate_average_heat_loss(map)
  for position, node in pairs(map.nodes) do
    local adjacentOffsets = {}
    if position.y > 1 then adjacentOffsets[#adjacentOffsets + 1] = { direction = "up", x = 0, y = -1 } end
    if position.x < map.width then adjacentOffsets[#adjacentOffsets + 1] = { direction = "right", x = 1, y = 0 } end
    if position.y < map.height then adjacentOffsets[#adjacentOffsets + 1] = { direction = "down", x = 0, y = 1 } end
    if position.x > 1 then adjacentOffsets[#adjacentOffsets + 1] = { direction = "left", x = -1, y = 0 } end

    for _, adjacentOffset in ipairs(adjacentOffsets) do
      node.connections[#node.connections + 1] = {
        direction = adjacentOffset.direction,
        node = map.nodes[coordGen(position.x + adjacentOffset.x, position.y + adjacentOffset.y)]
      }
    end

    -- Sort connections from most likely to be favourable to least
    table.sort(node.connections, function (first, second)
      local firstManhattanDistance = (destinationPosition.x - first.node.position.x) + (destinationPosition.y - first.node.position.y)
      local firstHeatLoss = first.node.heatLoss + (firstManhattanDistance * averageHeatLoss)

      local secondManhattanDistance = (destinationPosition.x - second.node.position.x) + (destinationPosition.y - second.node.position.y)
      local secondHeatLoss = second.node.heatLoss + (secondManhattanDistance * averageHeatLoss)

      return firstHeatLoss < secondHeatLoss
    end)
  end

  return map
end

local function is_valid_connection(candidateConnection, path, maxConsecutive)
  local isValid = false
  for i = #path - (maxConsecutive - 1), #path do
    if path[i] == nil or path[i].direction ~= candidateConnection.direction then
      isValid = true
      break
    end
  end
  return isValid
end

local function find_heat_loss_in_best_path(map, destinationPosition, coordGen, maxConsecutive, minMovesForNewDirection)
  local cache = {}
  local currentMinTotalHeatLoss = 1500

  -- This should have been done with A-star or whatever, but this deeptracking does the work (slowly, but still), so whatever
  local function find_min_heat_loss_recursively(currentPath, currentHeatLoss, currentNodeInfo)
    local consecutivesBefore = 0
    for i = #currentPath, #currentPath - (maxConsecutive - 1), -1 do
      if currentPath[i] == nil or currentPath[i].direction ~= currentNodeInfo.direction then
        break
      end
      consecutivesBefore = consecutivesBefore + 1
    end
    local cacheKey = "x=" .. currentNodeInfo.node.position.x .. ",y=" .. currentNodeInfo.node.position.y
    if currentNodeInfo.direction ~= nil then
      cacheKey = cacheKey .. ", " .. currentNodeInfo.direction .. ", " .. consecutivesBefore
    end

    if cache[cacheKey] == nil or cache[cacheKey].currentHeatLoss > currentHeatLoss then
      local minHeatLossAfterCurrentNode = math.maxinteger

      currentPath[#currentPath + 1] = currentNodeInfo
      for _, potentialConnectionInfo in ipairs(currentNodeInfo.node.connections) do
        local canMoveToConnection = not (currentNodeInfo.direction == "up" and potentialConnectionInfo.direction == "down")
          and not (currentNodeInfo.direction == "right" and potentialConnectionInfo.direction == "left")
          and not (currentNodeInfo.direction == "down" and potentialConnectionInfo.direction == "up")
          and not (currentNodeInfo.direction == "left" and potentialConnectionInfo.direction == "right")
        local potentialConnectionHeatLoss = potentialConnectionInfo.node.heatLoss

        -- If there is a minimum initial jump (minMovesForNewDirection), we make sure to enforce it
        if canMoveToConnection and currentNodeInfo.direction ~= potentialConnectionInfo.direction and minMovesForNewDirection > 1 then
          local connectionDiffX = potentialConnectionInfo.node.position.x - currentNodeInfo.node.position.x
          local connectionDiffY = potentialConnectionInfo.node.position.y - currentNodeInfo.node.position.y
          local finalConnectionPosition = coordGen(
            currentNodeInfo.node.position.x + (connectionDiffX * minMovesForNewDirection),
            currentNodeInfo.node.position.y + (connectionDiffY * minMovesForNewDirection)
          )
          if map.nodes[finalConnectionPosition] ~= nil then
            local nextConnectionPosition = potentialConnectionInfo.node.position
            potentialConnectionHeatLoss = 0
            for _ = 1, minMovesForNewDirection - 1 do
              currentPath[#currentPath + 1] = { node = map.nodes[nextConnectionPosition], direction = potentialConnectionInfo.direction }
              potentialConnectionHeatLoss = potentialConnectionHeatLoss + map.nodes[nextConnectionPosition].heatLoss
              nextConnectionPosition = coordGen(nextConnectionPosition.x + connectionDiffX, nextConnectionPosition.y + connectionDiffY)
            end
            potentialConnectionInfo = { node = map.nodes[nextConnectionPosition], direction = potentialConnectionInfo.direction }
            potentialConnectionHeatLoss = potentialConnectionHeatLoss + map.nodes[nextConnectionPosition].heatLoss
          else
            canMoveToConnection = false
          end
        end

        if canMoveToConnection then
          if is_valid_connection(potentialConnectionInfo, currentPath, maxConsecutive) then
            if potentialConnectionInfo.node.position ~= destinationPosition then
              -- Calculate the minimum heat loss to have from here, assuming every node along the way will have a heat loss of only 1 (there are no zeroes in the input)
              local manhattanDistance = (destinationPosition.y - potentialConnectionInfo.node.position.y) + (destinationPosition.x - potentialConnectionInfo.node.position.x)
              local minHeatLossPossible = currentHeatLoss + potentialConnectionHeatLoss + manhattanDistance
              if minHeatLossPossible < currentMinTotalHeatLoss then
                local heatLossAfterPotentialConnection = find_min_heat_loss_recursively(currentPath, currentHeatLoss + potentialConnectionHeatLoss, potentialConnectionInfo)
                if heatLossAfterPotentialConnection < math.maxinteger then
                  minHeatLossAfterCurrentNode = math.min(minHeatLossAfterCurrentNode, potentialConnectionHeatLoss + heatLossAfterPotentialConnection)
                end
              end
            else
              minHeatLossAfterCurrentNode = math.min(minHeatLossAfterCurrentNode, potentialConnectionHeatLoss)
              currentMinTotalHeatLoss = math.min(currentMinTotalHeatLoss, currentHeatLoss + potentialConnectionHeatLoss)
            end
          end

          -- Restore the path after handling the minimum initial jump
          if currentNodeInfo.direction ~= potentialConnectionInfo.direction and minMovesForNewDirection > 1 then
            for _ = 1, minMovesForNewDirection - 1 do
              table.remove(currentPath, #currentPath)
            end
          end
        end
      end
      table.remove(currentPath, #currentPath)

      cache[cacheKey] = { result = minHeatLossAfterCurrentNode, currentHeatLoss = currentHeatLoss }
    end

    return cache[cacheKey].result
  end

  return find_min_heat_loss_recursively({}, 0, { node = map.nodes[coordGen(1, 1)], direction = nil })
end

local function resolve(lines, maxConsecutive, minMovesForNewDirection)
  local coordGen = coordinate_generator()
  local map = read_map_info(lines, coordGen)
  local destinationPosition = coordGen(map.width, map.height)
  return find_heat_loss_in_best_path(map, destinationPosition, coordGen, maxConsecutive, minMovesForNewDirection)
end

print("part 1: " .. resolve(read_lines(problemNumber), 3, 1))
print("part 2: " .. resolve(read_lines(problemNumber), 10, 4))
