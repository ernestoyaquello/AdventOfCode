require "input_helper"

local problemNumber = 8

local function read_network_and_instructions(lines)
  local network, instructions = {}, {}

  -- Read nodes of the network
  for lineIndex = 2, #lines do
    local line = lines[lineIndex]
    local nodeLabel, leftNodeLabel, rightNodeLabel = line:gmatch("(%w+) = %((%w+), (%w+)%)")()
    network[nodeLabel] = { label = nodeLabel, L = leftNodeLabel, R = rightNodeLabel }
  end

  -- Read instructions
  for instructionIndex = 1, #lines[1] do
    instructions[#instructions + 1] = lines[1]:sub(instructionIndex, instructionIndex)
  end

  return network, instructions
end

local function find_steps_needed_to_reach_valid_destinations(network, instructions, nodeLabel)
  local stepsToReachDestinations = {}

  local instructionIndex = 1
  local steps = 0
  local currentNodeLabel = nodeLabel
  local visitedNodes = {}
  while true do
    -- Apply the next instruction
    local instruction = instructions[instructionIndex]
    currentNodeLabel = network[currentNodeLabel][instruction]
    steps = steps + 1

    -- Try to detect if we have to stop the search because we have reached a loop in the path
    local pathLoopFound = false
    if visitedNodes[currentNodeLabel] ~= nil then
      for _, lastVisitInstructionIndex in pairs(visitedNodes[currentNodeLabel]) do
        if lastVisitInstructionIndex == instructionIndex then
          pathLoopFound = true
          break
        end
      end
      if pathLoopFound then break end
    end

    -- Save the visited node information, as this will be used to find path loops
    if visitedNodes[currentNodeLabel] == nil then visitedNodes[currentNodeLabel] = {} end
    visitedNodes[currentNodeLabel][#visitedNodes[currentNodeLabel] + 1] = instructionIndex
    if currentNodeLabel:sub(3, 3) == "Z" then
      stepsToReachDestinations[#stepsToReachDestinations + 1] = steps
    end

    -- Increment instruction index for the next iteration
    if instructionIndex < #instructions then instructionIndex = instructionIndex + 1 else instructionIndex = 1 end
  end

  return stepsToReachDestinations
end

local function calculate_gcd(a, b)
  if b == 0 then return a end
  return calculate_gcd(b, a % b)
end

local function calculate_lcm(x, y)
  return (x * y) / calculate_gcd(x, y)
end

local function part_1(network, instructions)
  local steps = 0

  local instructionIndex = 0
  local currentNodeLabel = "AAA"
  while currentNodeLabel ~= "ZZZ" do
    -- Read the next instruction
    local instruction = instructions[1 + (instructionIndex % #instructions)]
    instructionIndex = instructionIndex + 1
    -- Apply the instruction to move to the next node
    currentNodeLabel = network[currentNodeLabel][instruction]
    steps = steps + 1
  end

  return steps
end

local function part_2(network, instructions)
  -- Find the start nodes
  local startNodeLabels = {}
  for nodeLabel in pairs(network) do
    if nodeLabel:sub(3, 3) == "A" then
      startNodeLabels[#startNodeLabels + 1] = nodeLabel
    end
  end

  -- For each start node, we find the number of steps needed to reach a valid destination
  for _, startNodeLabel in ipairs(startNodeLabels) do
    network[startNodeLabel].stepsToReachDestinations = find_steps_needed_to_reach_valid_destinations(network, instructions, startNodeLabel)
  end

  -- Finally, we calculate the lowest common multiple between the lowest number of steps needed to reach a destination from each one of the start nodes.
  -- This only works because the input data guarantees that only one destination node will be visited from any start node before a path loop is reached.
  -- If the input weren't so nice, we would have multiple ways to reach a destination from each start node, which would complicate things a little here.
  local firstStartNodeLabel = network[startNodeLabels[1]]
  local stepsToReachCommonDestination = firstStartNodeLabel.stepsToReachDestinations[1]
  for i = 2, #startNodeLabels do
    local nextStartNodeLabel = network[startNodeLabels[i]]
    stepsToReachCommonDestination = calculate_lcm(stepsToReachCommonDestination, nextStartNodeLabel.stepsToReachDestinations[1])
  end
  return math.floor(stepsToReachCommonDestination) -- using math.floor() to get rid of the ".0" that would be displayed when printing this number
end

local network, instructions = read_network_and_instructions(read_lines(problemNumber))
print("part 1: " .. part_1(network, instructions))
print("part 2: " .. part_2(network, instructions))
