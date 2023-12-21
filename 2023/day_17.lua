require "input_helper"

local problemNumber = 17

local function get_node_key(nodeInfo)
  return "position=" .. nodeInfo.position
    .. ", up=" .. nodeInfo.connections.up
    .. ", right=" .. nodeInfo.connections.right
    .. ", down=" .. nodeInfo.connections.down
    .. ", left=" .. nodeInfo.connections.left
end

local function confine_node_to_map_limits(map, nodeInfo)
    -- Limit the connections to account for the borders of the map
    local row = math.floor(nodeInfo.position / map.width) + 1
    local column = (nodeInfo.position % map.width) + 1
    nodeInfo.connections.up = math.min(nodeInfo.connections.up, row - 1)
    nodeInfo.connections.right = math.min(nodeInfo.connections.right, map.width - column)
    nodeInfo.connections.down = math.min(nodeInfo.connections.down, map.height - row)
    nodeInfo.connections.left = math.min(nodeInfo.connections.left, column - 1)
end

local function find_neighbour_nodes(map, nodeInfo, minInitialMoves, maxRepeatedMoves)
  local extraNodes = {} -- the ones whose neighbours need to be found too
  nodeInfo.neighbours = {}

  --[[
    We create new virtual nodes based on the current one and the possible moves from it.
    Basically, for each position, instead of having just one node, we have multiple ones,
    and they are different because of how the node was entered, which in turn determines
    where we can go from it. In a way, we are simply visualizing the network of nodes
    differently, with extra nodes and connections that aren't there in plain sight, but
    that make sense logically. This probably sounds like nonsense, but I know what I mean.
    
    This works, and I even thought that it was kinda clever when I envisioned it, but it
    is veeeery slow with the actual input because that input is absurdly huge. Thus, this
    was just a terrible idea, which I think becomes apparent when looking at this awful
    code, as it is a massive mess that I barely understand, especially after adapting it
    for part 2, which changed the requirements in a way I didn't see coming. In any case,
    I committed to this idea for some reason (partially because of stubborness, but also
    because I couldn't be arsed to start over just to solve this whole problem properly),
    so I simply left the script running until I finally got the results. It's dirty and
    ugly work, but a star is a star.

    CORRECTION: This gives the right result for all the example inputs, but not for the
    real one – I've discovered this after a long, long wait. Back to the drawing board... 😥
  ]]
  for direction, numberOfMoves in pairs(nodeInfo.connections) do
    local effectiveMinInitialMoves = minInitialMoves
    if nodeInfo.completedDirection == direction then effectiveMinInitialMoves = 1 end

    if numberOfMoves >= effectiveMinInitialMoves then
      local directionOffset = 0
      if direction == "up" then directionOffset = -map.width
      elseif direction == "right" then directionOffset = 1
      elseif direction == "down" then directionOffset = map.width
      elseif direction == "left" then directionOffset = -1 end

      local lastNeighbourNodeInfo = nodeInfo
      local neighbourNodeInfo = { position = nodeInfo.position, connections = { up = 0, right = 0, down = 0, left = 0 }, neighbours = {} }
      neighbourNodeInfo.connections[direction] = numberOfMoves

      for moveNumber = 1, effectiveMinInitialMoves do
        neighbourNodeInfo.connections = { up = neighbourNodeInfo.connections.up, right = neighbourNodeInfo.connections.right, down = neighbourNodeInfo.connections.down, left = neighbourNodeInfo.connections.left }
        neighbourNodeInfo.position = neighbourNodeInfo.position + directionOffset
        if direction == "up" then
          neighbourNodeInfo.connections.up = neighbourNodeInfo.connections.up - 1
          neighbourNodeInfo.connections.down = 0
        elseif direction == "right" then
          neighbourNodeInfo.connections.right = neighbourNodeInfo.connections.right - 1
          neighbourNodeInfo.connections.left = 0
        elseif direction == "down" then
          neighbourNodeInfo.connections.down = neighbourNodeInfo.connections.down - 1
          neighbourNodeInfo.connections.up = 0
        elseif direction == "left" then
          neighbourNodeInfo.connections.left = neighbourNodeInfo.connections.left - 1
          neighbourNodeInfo.connections.right = 0
        end

        if moveNumber == effectiveMinInitialMoves then
          for neighbourDirection, _ in pairs(neighbourNodeInfo.connections) do
            if neighbourDirection ~= direction then
              neighbourNodeInfo.connections[neighbourDirection] = maxRepeatedMoves
            end
          end
          if direction == "up" then neighbourNodeInfo.connections.down = 0
          elseif direction == "right" then neighbourNodeInfo.connections.left = 0
          elseif direction == "down" then neighbourNodeInfo.connections.up = 0
          elseif direction == "left" then neighbourNodeInfo.connections.right = 0
          end
        end

        confine_node_to_map_limits(map, neighbourNodeInfo)
        neighbourNodeInfo.key = get_node_key(neighbourNodeInfo)
        lastNeighbourNodeInfo.neighbours[#lastNeighbourNodeInfo.neighbours + 1] = neighbourNodeInfo

        if moveNumber == effectiveMinInitialMoves then
          extraNodes[#extraNodes + 1] = neighbourNodeInfo
          neighbourNodeInfo.completedDirection = direction
        else
          map.nodes[neighbourNodeInfo.key] = neighbourNodeInfo
        end

        lastNeighbourNodeInfo = neighbourNodeInfo
        neighbourNodeInfo = { position = neighbourNodeInfo.position, connections = neighbourNodeInfo.connections, neighbours = {} }
      end
    end
  end

  return extraNodes
end

local function add_node_and_find_neighbours(map, nodeInfo, minInitialMoves, maxRepeatedMoves)
  local extraNodesToAdd = {}

  -- Add the node to the collection of nodes, unless it is already there, in which case we just leave
  nodeInfo.key = get_node_key(nodeInfo)
  if map.nodes[nodeInfo.key] == nil then
    map.nodes[nodeInfo.key] = nodeInfo
    extraNodesToAdd = find_neighbour_nodes(map, nodeInfo, minInitialMoves, maxRepeatedMoves)
  end

  return extraNodesToAdd
end

local function read_map_info(lines, minInitialMoves, maxRepeatedMoves)
  local map = {
    width = #lines[1],
    height = #lines,
    nodes = {},
    heatLosses = {},
    firstNodeInfo = nil,
  }

  for row = 1, map.height do
    for column = 1, map.width do
      local heatLoss = tonumber(lines[row]:sub(column, column))
      local position = ((row - 1) * map.width) + (column - 1)
      map.heatLosses[position] = heatLoss
    end
  end

  -- Create the network of connected nodes iteratively, starting with the first one
  map.firstNodeInfo = {
    position = 0,
    connections = { up = maxRepeatedMoves, right = maxRepeatedMoves, down = maxRepeatedMoves, left = maxRepeatedMoves },
  }
  confine_node_to_map_limits(map, map.firstNodeInfo)
  map.firstNodeInfo.key = get_node_key(map.firstNodeInfo)
  local extraNodesToAdd = add_node_and_find_neighbours(map, map.firstNodeInfo, minInitialMoves, maxRepeatedMoves)
  while #extraNodesToAdd > 0 do
    local newExtraNodesToAdd = {}
    for _, extraNodeToAdd in ipairs(extraNodesToAdd) do
      local extraExtraNodesToAdd = add_node_and_find_neighbours(map, extraNodeToAdd, minInitialMoves, maxRepeatedMoves)
      for _, extraExtraNodeToAdd in ipairs(extraExtraNodesToAdd) do
        newExtraNodesToAdd[#newExtraNodesToAdd + 1] = extraExtraNodeToAdd
      end
    end
    extraNodesToAdd = newExtraNodesToAdd
  end

  return map
end

local function dijkstra_me_this(map, firstNodeInfo, destinationPosition)
  local path = {}
  local heatLosses = {} -- i.e., distances
  local notVisited = {}

  for nodeKey, nodeInfo in pairs(map.nodes) do
    heatLosses[nodeKey] = math.maxinteger
    notVisited[#notVisited + 1] = nodeInfo
  end
  heatLosses[firstNodeInfo.key] = 0

  while #notVisited > 0 do
    print(#notVisited .. " remaining...")

    -- Find the closest not visited node
    local currentNode = nil
    local currentNodeIndex = nil
    local destinationFullyVisited = false
    for notVisitedNodeIndex, notVisitedNodeInfo in ipairs(notVisited) do
      if currentNode == nil or heatLosses[notVisitedNodeInfo.key] < heatLosses[currentNode.key] then
        currentNode = notVisitedNodeInfo
        currentNodeIndex = notVisitedNodeIndex
      end
      destinationFullyVisited = destinationFullyVisited or notVisitedNodeInfo.position == destinationPosition
    end

    -- All the nodes located at the destination position have been visited already, no need to keep looking
    if not destinationFullyVisited then break end

    -- Remove the node we are visiting now from the table of not visited nodes
    table.remove(notVisited, currentNodeIndex)

    -- For each neighbour, see if the heat loss would be lower this way and adjust the values appropriately if so
    for _, neighbourNode in ipairs(currentNode.neighbours) do
      local candidateDistance = heatLosses[currentNode.key] + map.heatLosses[neighbourNode.position]
      if candidateDistance < heatLosses[neighbourNode.key] then
        heatLosses[neighbourNode.key] = candidateDistance
        path[neighbourNode.key] = currentNode.key
      end
    end
  end

  return path, heatLosses
end

local function resolve(map)
  local destinationPosition = (map.width * map.height) - 1
  local _, heatLosses = dijkstra_me_this(map, map.firstNodeInfo, destinationPosition)

  local minHeatLoss = math.maxinteger
  for nodeKey, nodeHeatLoss in pairs(heatLosses) do
    if map.nodes[nodeKey].position == destinationPosition and nodeHeatLoss < minHeatLoss then
      minHeatLoss = nodeHeatLoss
    end
  end
  return minHeatLoss
end

print("part 1: " .. resolve(read_map_info(read_lines(problemNumber), 1, 3)))
print("part 2: " .. resolve(read_map_info(read_lines(problemNumber), 4, 10)))
