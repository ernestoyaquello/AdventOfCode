require "input_helper"

local problemNumber = 15

local function get_steps(stepStrings)
  local steps = {}
  for _, stepString in ipairs(stepStrings) do
    local label, operation, focalLength = stepString:gmatch("(%w+)([=-]*)(%d*)")()
    steps[#steps + 1] = { label = label, operation = operation, focalLength = focalLength }
  end
  return steps
end

local function calculate_hash(stepString)
  local hash = 0
  for i = 1, #stepString do
    local character = stepString:sub(i, i)
    local characterAsciiNumber = string.byte(character)
    hash = hash + characterAsciiNumber
    hash = hash * 17
    hash = hash % 256
  end
  return hash
end

local function part_1(stepStrings)
  local result = 0
  for _, stepString in ipairs(stepStrings) do
    result = result + calculate_hash(stepString)
  end
  return result
end

local function part_2(stepStrings)
  local boxes = {}
  local steps = get_steps(stepStrings)
  for _, step in ipairs(steps) do
    -- Get the right box
    local boxNumber = calculate_hash(step.label)
    if boxes[boxNumber] == nil then
      boxes[boxNumber] = {} -- make sure the box is a table where we can fit lenses
    end
    local box = boxes[boxNumber]

    -- Try to find the lens inside the box
    local lensPositionInBox = -1
    for lensPosition = 1, #box do
      if box[lensPosition].label == step.label then
        lensPositionInBox = lensPosition
        break
      end
    end

    -- Apply the operation
    if step.operation == "=" then
      if lensPositionInBox >= 0 then
        -- The lens is inside the box, let's replace it
        box[lensPositionInBox] = { label = step.label, focalLength = step.focalLength }
      else
         -- The lens is not inside the box, let's add it at the end
         box[#box + 1] = { label = step.label, focalLength = step.focalLength }
      end
    elseif step.operation == "-" then
      if lensPositionInBox >= 0 then
        -- The lens is inside the box, let's remove it and shift the next boxes forward
        for nextLensIndex = lensPositionInBox + 1, #box + 1 do
          box[nextLensIndex - 1] = box[nextLensIndex]
        end
      end
    end
  end

  -- Calculate the total focusing power of all the lenses in all the boxes
  local totalFocusingPower = 0
  for number, box in pairs(boxes) do
    for lensIndex = 1, #box do
      local lens = box[lensIndex]
      local focusingPower = 1 + number
      focusingPower = focusingPower * lensIndex
      focusingPower = focusingPower * lens.focalLength
      totalFocusingPower = totalFocusingPower + focusingPower
    end
  end
  return totalFocusingPower
end

print("part 1: " .. part_1(read_sequences(problemNumber, false, ",")[1]))
print("part 2: " .. part_2(read_sequences(problemNumber, false, ",")[1]))
