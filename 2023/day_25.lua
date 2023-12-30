require "input_helper"

local problemNumber = 25

local function find_length_of_fastest_route_to_self(graph, startComponent, mandatoryNextComponent)
  local distances = {}
  local notVisited = {}

  local function dijkstra_me_this(startComponent, destinationComponent, forbiddenConnection)
    for component in pairs(graph) do
      distances[component] = math.maxinteger
      notVisited[#notVisited + 1] = component
    end
    distances[startComponent] = 0
  
    while #notVisited > 0 do
      -- Find the closest not visited component
      local currentComponent = nil
      local currentComponentIndex = nil
      local destinationVisited = false
      for notVisitedComponentIndex, notVisitedComponent in ipairs(notVisited) do
        if currentComponent == nil or distances[notVisitedComponent] < distances[currentComponent] then
          currentComponent = notVisitedComponent
          currentComponentIndex = notVisitedComponentIndex
        end
        destinationVisited = destinationVisited or notVisitedComponent == destinationComponent
      end

      -- We have already reached the destination, no need to keep looking
      if not destinationVisited then break end

      -- Remove the component we are visiting now from the table of not visited components
      table.remove(notVisited, currentComponentIndex)

      -- For each connection, see if the distance would be lower this way and adjust the values appropriately if so
      for connectionComponent in pairs(graph[currentComponent]) do
        if not (forbiddenConnection[1] == currentComponent and forbiddenConnection[2] == connectionComponent)
          and not (forbiddenConnection[1] == connectionComponent and forbiddenConnection[2] == currentComponent)
        then
          local isNotVisited = false
          for _, notVisitedComponent in ipairs(notVisited) do
            if notVisitedComponent == connectionComponent then
              isNotVisited = true
              break
            end
          end

          if isNotVisited then
            local candidateDistance = distances[currentComponent] + 1
            if candidateDistance < distances[connectionComponent] then
              distances[connectionComponent] = candidateDistance
            end
          end
        end
      end
    end
  end

  dijkstra_me_this(mandatoryNextComponent, startComponent, { mandatoryNextComponent, startComponent })
  return distances[startComponent]
end

local function read_components(lines)
  local componentsSet = {}
  local connectionsSet = {}
  local graph = {}

  for _, line in ipairs(lines) do
    local componentName, componentConnections = line:gmatch("(%w+): ([%w ]+)")()
    componentsSet[componentName] = componentName

    for connectedComponentName in componentConnections:gmatch("%w+") do
      componentsSet[connectedComponentName] = connectedComponentName

      local connection = { componentName, connectedComponentName }
      if connectedComponentName < componentName then connection = { connectedComponentName, componentName } end

      local connectionName = connection[1] .. "|" .. connection[2]
      if connectionsSet[connectionName] == nil then
        connectionsSet[connectionName] = connection
      end

      if graph[componentName] == nil then graph[componentName] = {} end
      if graph[connectedComponentName] == nil then graph[connectedComponentName] = {} end
      graph[componentName][connectedComponentName] = true
      graph[connectedComponentName][componentName] = true
    end
  end

  local components = {}
  for component in pairs(componentsSet) do
    components[#components + 1] = component
  end

  local connections = {}
  for _, connection in pairs(connectionsSet) do
    -- For each connection, find how difficult it is to get back to the initial component
    local firstRouteLength = find_length_of_fastest_route_to_self(graph, connection[1], connection[2])
    local secondRouteLength = find_length_of_fastest_route_to_self(graph, connection[2], connection[1])
    local routeLength = math.min(firstRouteLength, secondRouteLength)
    connections[#connections + 1] = { connection[1], connection[2], routeLength }
  end

  -- Make sure we first try disconnecting the connections where the path to return to the initial component is longer.
  -- This way, the recursion we'll do later to find the right cables to disconnect will get to the result much faster.
  -- This is still extremely slow because the loop used above takes a long time with the real input. And while I could
  -- optimise quite a few things, this is never going to be very performant anyway – I'm sure I am missing some cool
  -- trick or logic. But I am quite sick right now, and as usual, a star is a star, so I cannot be bothered to do things
  -- better here, or even to clean up this mess. This works if you give it some time, which is good enough in my book!
  table.sort(connections, function (a, b) return a[3] > b[3] end)

  return components, connections, graph
end

local function reach_components(graph, startComponent)
  local function reach_components_recursively(component, reached)
    if reached[component] ~= nil then return reached end

    reached[component] = component
    for connection in pairs(graph[component]) do
      reach_components_recursively(connection, reached)
    end

    return reached
  end

  return reach_components_recursively(startComponent, {})
end

local function get_group_hashes(components, graph)
  local reachedHashes = {}
  for startComponent in pairs(graph) do
    local reachedComponents = reach_components(graph, startComponent)

    local reachedHash = ""
    for _, component in ipairs(components) do
      if reachedComponents[component] ~= nil then
        if #reachedHash == 0 then
          reachedHash = reachedHash .. component
        else
          reachedHash = reachedHash .. ", " .. component
        end
      end
    end
    reachedHashes[reachedHash] = reachedHash

    local _, numberOfCommasInHash = string.gsub(reachedHash, ",", "")
    if (numberOfCommasInHash + 1) == #components then
      break
    end
  end

  local groupHashes = {}
  for groupHash in pairs(reachedHashes) do
    groupHashes[#groupHashes + 1] = groupHash
  end
  return groupHashes
end

local function find_final_configuration(components, connections, graph)
  local function find_final_configuration_recursively(connectionIndex, removedConnections)
    local connection = connections[connectionIndex]
    for _, removeConnection in ipairs({ true, false }) do
      local numberOfGroups = 1
      if removeConnection then
        graph[connection[1]][connection[2]] = nil
        graph[connection[2]][connection[1]] = nil
        removedConnections[#removedConnections + 1] = connection
        if #removedConnections == 3 then
          numberOfGroups = #get_group_hashes(components, graph)
        end
      end

      if numberOfGroups == 2 then
        return removedConnections
      elseif #removedConnections < 3 and connectionIndex < #connections then
        local finalRemovedConnections = find_final_configuration_recursively(connectionIndex + 1, removedConnections)
        if #finalRemovedConnections == 3 then
          return finalRemovedConnections
        end
      end

      if removeConnection then
        table.remove(removedConnections, #removedConnections)
        graph[connection[2]][connection[1]] = true
        graph[connection[1]][connection[2]] = true
      end
    end
    return {}
  end

  find_final_configuration_recursively(1, {})
end

local function part_1(components, connections, graph)
  find_final_configuration(components, connections, graph)
  local result = 1
  for _, groupHash in ipairs(get_group_hashes(components, graph)) do
    local _, numberOfCommasInHash = string.gsub(groupHash, ",", "")
    result = result * (numberOfCommasInHash + 1)
  end
  return result
end

local components, connections, graph = read_components(read_lines(problemNumber))
print("part 1: " .. part_1(components, connections, graph))
