require "input_helper"

local problemNumber = 20

local function calculate_gcd(a, b)
  if b == 0 then return a end
  return calculate_gcd(b, a % b)
end

local function calculate_lcm(x, y)
  return (x * y) / calculate_gcd(x, y)
end

local function queue_pulse(pulsesQueue, pulsesHistory, senderModule, receiverModule, high)
  pulsesQueue[#pulsesQueue + 1] = {
    origin = senderModule.name,
    destination = receiverModule.name,
    high = high,
    execute = function () receiverModule.processInput(high, senderModule.name) end,
  }
  pulsesHistory[#pulsesHistory + 1] = pulsesQueue[#pulsesQueue]
end

local function generate_flip_flop_module(name, pulsesQueue, pulsesHistory)
  local module = { type = "flip-flop", name = name, on = false, inputModules = {}, outputModules = {}, processInput = nil }
  module.processInput = function (high, senderName)
    if not high then
      module.on = not module.on
      for _, receiverModule in ipairs(module.outputModules) do
        queue_pulse(pulsesQueue, pulsesHistory, module, receiverModule, module.on)
      end
    end
  end
  return module
end

local function generate_conjuction_module(name, pulsesQueue, pulsesHistory)
  local module = { type = "conjuction", name = name, lastReceivedFromInputs = {}, inputModules = {}, outputModules = {}, processInput = nil }
  module.processInput = function (high, senderName)
    module.lastReceivedFromInputs[senderName] = high
    local allHigh = true
    for _, inputModule in ipairs(module.inputModules) do
      if module.lastReceivedFromInputs[inputModule.name] ~= true then
        allHigh = false
        break
      end
    end
    for _, receiverModule in ipairs(module.outputModules) do
      queue_pulse(pulsesQueue, pulsesHistory, module, receiverModule, not allHigh)
    end
  end
  return module
end

local function generate_broascast_module(pulsesQueue, pulsesHistory)
  local module = { type = "broascast", name = "broadcaster", inputModules = {}, outputModules = {}, processInput = nil }
  module.processInput = function (high, senderName)
    for _, receiverModule in ipairs(module.outputModules) do
      queue_pulse(pulsesQueue, pulsesHistory, module, receiverModule, high)
    end
  end
  return module
end

local function read_modules(lines, pulsesQueue, pulsesHistory)
  local modules = {}

  -- Read all the modules
  for _, line in ipairs(lines) do
    local firstCharacter = line:sub(1, 1)
    local outputsString = line:gmatch(" -> (.+)")() .. ", "
    local module = nil
    if firstCharacter == "%" then
      local name = line:sub(2, #line):gmatch("(%w+) ")()
      module = generate_flip_flop_module(name, pulsesQueue, pulsesHistory)
    elseif firstCharacter == "&" then 
      local name = line:sub(2, #line):gmatch("(%w+) ")()
      module = generate_conjuction_module(name, pulsesQueue, pulsesHistory)
    else
      module = generate_broascast_module(pulsesQueue, pulsesHistory)
    end

    -- Save the output module names for the node we just read on a temporary table
    module.tempOutputNames = {}
    for outputName in outputsString:gmatch("(%w+), ") do
      module.tempOutputNames[#module.tempOutputNames + 1] = outputName
    end

    modules[module.name] = module
  end

  -- Now that we have finally read all the modules, make them reference each other as inputs and outputs
  for _, module in pairs(modules) do
    for _, outputName in ipairs(module.tempOutputNames) do
      local outputModule = modules[outputName]
      if outputModule == nil then
        outputModule = { type = "unknown", name = outputName, inputModules = {}, outputModules = {}, processInput = function (high, senderName) end }
        modules[outputModule.name] = outputModule
      end
      module.outputModules[#module.outputModules + 1] = outputModule
      outputModule.inputModules[#outputModule.inputModules + 1] = module
    end
    module.tempOutputNames = nil
  end

  -- Add the button module, which isn't defined in the input
  local buttonModule = { type = "button", name = "button", inputModules = {}, outputModules = { modules["broadcaster"] }, processInput = nil }
  buttonModule.processInput = function (high, senderName)
    for _, receiverModule in ipairs(buttonModule.outputModules) do
      queue_pulse(pulsesQueue, pulsesHistory, buttonModule, receiverModule, false)
    end
  end
  modules["broadcaster"].inputModules[#modules["broadcaster"].inputModules + 1] = buttonModule
  modules[buttonModule.name] = buttonModule

  return modules
end

local function part_1()
  local pulsesQueue = {}
  local pulsesHistory = {}
  local modules = read_modules(read_lines(problemNumber), pulsesQueue, pulsesHistory)

  -- Execute 1000 button presses
  local buttonPresses = 1000
  for _ = 1, buttonPresses do
    modules["button"].processInput(false, "human")
    while #pulsesQueue > 0 do
      local pulse = pulsesQueue[1]
      table.remove(pulsesQueue, 1)
      pulse.execute()
    end
  end

  -- Calculate the result looking at the history of pulses
  local recordedLowPulses = 0
  local recordedHighPulses = 0
  for _, pulse in ipairs(pulsesHistory) do
    if pulse.high then recordedHighPulses = recordedHighPulses + 1
    else recordedLowPulses = recordedLowPulses + 1 end
  end
  return recordedLowPulses * recordedHighPulses
end

-- Unfortunately, I cannot claim I solved this part on my own today, as I spoiled myself
-- accidentally by going in the Subreddit before I was done – rookie mistake, I know.
-- I think I would have figured this out though, but the fact remains that a visualisation
-- I saw kinda gave it away, so I didn't have to apply much thinking myself.
local function part_2()
  local pulsesQueue = {}
  local pulsesHistory = {}
  local modules = read_modules(read_lines(problemNumber), pulsesQueue, pulsesHistory)

  -- Once all all these modules receive a high pulse in the same cycle, "rx" will get a low pulse.
  -- This works with the input the problem gives us, but it isn't a general solution by any means.
  -- This is one of those problems where undernstading the input is more important than coding...
  local modulesToTrack = modules["rx"].inputModules[1].inputModules
  local trackedModulesLoopCycles = {}
  for _, moduleToTrack in ipairs(modulesToTrack) do
    trackedModulesLoopCycles[moduleToTrack.name] = -1
  end

  local buttonPresses = 0
  local pulsesHistoryIndex = 1
  while true do
    -- Press the button and handle the consequent pulses
    modules["button"].processInput(false, "human")
    buttonPresses = buttonPresses + 1
    while #pulsesQueue > 0 do
      local pulse = pulsesQueue[1]
      table.remove(pulsesQueue, 1)
      pulse.execute()
    end

    -- Check if any of the tracked modules received a high pulse during this cycle
    for i = pulsesHistoryIndex, #pulsesHistory do
      local pulse = pulsesHistory[i]
      if pulse.high and trackedModulesLoopCycles[pulse.origin] == -1 then
        trackedModulesLoopCycles[pulse.origin] = buttonPresses
      end
    end
    pulsesHistoryIndex = #pulsesHistory + 1

    -- If we have found all the loop cycles, no need to keep pressing the button!
    local cyclesForAllTrackedModulesFound = true
    for _, cyclePresses in pairs(trackedModulesLoopCycles) do
      if cyclePresses == -1 then
        cyclesForAllTrackedModulesFound = false
        break
      end
    end
    if cyclesForAllTrackedModulesFound then
      break
    end
  end

  -- We do the LCM of all of these loop cycles to get the final loop cycle, which is the problem's result
  local loopCycles = {}
  for _, trackedModulesLoopCycle in pairs(trackedModulesLoopCycles) do
    loopCycles[#loopCycles + 1] = trackedModulesLoopCycle
  end
  local fullCycle = loopCycles[1]
  for i = 2, #loopCycles do
    -- The LCM works because the cycles repeat perfectly over and over, what a "lucky" coincidence!
    -- P.S. Actually, they all are primes, we could just multiple them together. Even luckier!
    fullCycle = calculate_lcm(fullCycle, loopCycles[i])
  end

  return fullCycle
end

print("part 1: " .. string.format("%.0f", part_1()))
print("part 2: " .. string.format("%.0f", part_2()))
