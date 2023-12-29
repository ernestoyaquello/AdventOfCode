require "input_helper"

local problemNumber = 25

local function read_components(lines)
  local componentsSet = {}
  local connections = {}
  local graph = {}

  for _, line in ipairs(lines) do
    local componentName, componentConnections = line:gmatch("(%w+): ([%w ]+)")()
    componentsSet[componentName] = componentName

    for connectedComponentName in componentConnections:gmatch("%w+") do
      componentsSet[connectedComponentName] = connectedComponentName

      local connectionAlreadyExists = false
      for _, connection in ipairs(connections) do
        if (connection[1] == componentName and connection[2] == connectedComponentName) 
          or (connection[1] == connectedComponentName and connection[2] == componentName)
        then
          connectionAlreadyExists = true
          break
        end
      end
      if not connectionAlreadyExists then
        if componentName < connectedComponentName then
          connections[#connections + 1] = { componentName, connectedComponentName }
        else
          connections[#connections + 1] = { connectedComponentName, componentName }
        end
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

  table.sort(components)
  table.sort(connections, function (a, b) return a[1] < b[1] or (a[1] == b[1] and a[2] < b[2]) end)

  return components, connections, graph
end

local function get_group_hashes(components, graph)
  local function reach_components_recursively(component, reached)
    if reached[component] ~= nil then return reached end

    reached[component] = component
    for connection in pairs(graph[component]) do
      reach_components_recursively(connection, reached)
    end

    return reached
  end

  local reachedHashes = {}
  for startComponent in pairs(graph) do
    local reachedComponents = reach_components_recursively(startComponent, {})

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
