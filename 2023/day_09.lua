require "input_helper"

local problemNumber = 9

local function findNextValue(sequence, lookForLeadingValues)
  local edgeSequenceValues = {}
  while true do
    -- Store the value that is located on the edge of the sequence (i.e., at the start or the end)
    edgeSequenceValues[#edgeSequenceValues + 1] = sequence[#sequence]
    if lookForLeadingValues then edgeSequenceValues[#edgeSequenceValues] = sequence[1] end

    -- Reduce the sequence to a smaller sequence that contains the difference between each consecutive value
    local reducedSequence = {}
    local reducedSequenceOnlyHasZeroes = true
    for valueIndex = 1, #sequence - 1 do
      reducedSequence[#reducedSequence + 1] = sequence[valueIndex + 1] - sequence[valueIndex]
      reducedSequenceOnlyHasZeroes = reducedSequenceOnlyHasZeroes and reducedSequence[#reducedSequence] == 0
    end
    sequence = reducedSequence

    -- If the reduced sequence is all zeroes, calculate the next value for this sequence and end its loop.
    -- Technically, we don't need to wait until it's all zeroes, we could stop as soon as the sequence is
    -- any unique number repeated, but who cares, this is easier.
    if reducedSequenceOnlyHasZeroes then
      local nextEdgeValue = sequence[#sequence]
      if lookForLeadingValues then nextEdgeValue = sequence[1] end

      for edgeValueIndex = #edgeSequenceValues, 1, -1 do
        if lookForLeadingValues then
          nextEdgeValue = edgeSequenceValues[edgeValueIndex] - nextEdgeValue
        else
          nextEdgeValue = edgeSequenceValues[edgeValueIndex] + nextEdgeValue
        end
      end
      return nextEdgeValue
    end
  end
end

local function resolve(sequences, isSecondPart)
  local result = 0

  for _, sequence in ipairs(sequences) do
    result = result + findNextValue(sequence, isSecondPart)
  end

  return result
end

local sequences = read_sequences(problemNumber, true)
print("part 1: " .. resolve(sequences, false))
print("part 2: " .. resolve(sequences, true))
