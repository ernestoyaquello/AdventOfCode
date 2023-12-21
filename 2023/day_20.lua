require "input_helper"

local problemNumber = 20

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

    module.tempOutputNames = {}
    for outputName in outputsString:gmatch("(%w+), ") do
      module.tempOutputNames[#module.tempOutputNames + 1] = outputName
    end

    modules[module.name] = module
  end

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
  local buttonPresses = 1000
  for _ = 1, buttonPresses do
    modules["button"].processInput(false, "human")
    while #pulsesQueue > 0 do
      local pulse = pulsesQueue[1]
      table.remove(pulsesQueue, 1)
      pulse.execute()
    end
  end
  local recordedLowPulses = 0
  local recordedHighPulses = 0
  for _, pulse in ipairs(pulsesHistory) do
    if pulse.high then recordedHighPulses = recordedHighPulses + 1
    else recordedLowPulses = recordedLowPulses + 1 end
  end
  return recordedLowPulses * recordedHighPulses
end

local function part_2()
  local pulsesQueue = {}
  local pulsesHistory = {}
  local modules = read_modules(read_lines(problemNumber), pulsesQueue, pulsesHistory)
  local buttonPresses = 0
  while true do
    modules["button"].processInput(false, "human")
    buttonPresses = buttonPresses + 1
    while #pulsesQueue > 0 do
      local pulse = pulsesQueue[1]
      if pulse.destination == "rx" and not pulse.high then
        break
      end
      table.remove(pulsesQueue, 1)
      pulse.execute()
    end
    if #pulsesQueue > 0 then
      break
    end
  end
  return buttonPresses
end

print("part 1: " .. part_1())
print("part 2: " .. part_2())
