require "input_helper"

local problemNumber = 12

local function read_records(lines)
  local records = {}

  for _, line in ipairs(lines) do
    local record, amountsString = line:gmatch("([#.%?]+) ([%d,]+)")()
    local amounts = {}
    for amount in amountsString:gmatch("%d+") do
      amounts[#amounts + 1] = tonumber(amount)
    end
    records[#records + 1] = { record = record, amounts = amounts }
  end

  return records
end


local function count_arrangements(recordInfo)
  local cache = {}

  local function count_arrangements_recursively(record, amounts)
    local key = record .. table.concat(amounts, ",")
    if cache[key] ~= nil then return cache[key] end
    cache[key] = 0

    if #amounts == 0 then
      if not record:find("#") then
        cache[key] = 1
      end
    else
      local currentAmount = amounts[1]

      -- Find the first valid index for a substring of hashes of the size indicated by the current amount
      local startIndex = 1
      local placeholder = string.rep("[%?#]", currentAmount)
      while not record:sub(startIndex, startIndex + currentAmount - 1):find(placeholder)
        or record:sub(startIndex + currentAmount, startIndex + currentAmount) == "#"
        or record:sub(1, startIndex - 1):find("#")
      do
        startIndex = startIndex + 1
        if (startIndex + currentAmount - 1) > #record then
          break
        end
      end

      if startIndex + currentAmount - 1 <= #record then
        -- Try pretending we put a string of hashes here
        local newAmounts = {}
        for i = 2, #amounts do newAmounts[#newAmounts + 1] = amounts[i] end
        local nextRecord = record:sub(startIndex + currentAmount + 1)
        cache[key] = cache[key] + count_arrangements_recursively(nextRecord, newAmounts)

        -- Try pretending to put a dot as an alternative when possible
        if record:sub(startIndex, startIndex + currentAmount - 1):find("%?") then
          startIndex = record:find("%?", startIndex)
          if not record:sub(1, startIndex - 1):find("#") then
            nextRecord = record:sub(startIndex + 1)
            cache[key] = cache[key] + count_arrangements_recursively(nextRecord, amounts)
          end
        end
      end
    end

    return cache[key]
  end

  return count_arrangements_recursively(recordInfo.record, recordInfo.amounts)
end

local function part_1(records)
  local arrangements = 0
  for _, recordInfo in ipairs(records) do
    arrangements = arrangements + count_arrangements(recordInfo)
  end
  return arrangements
end

local function part_2(records)
  local function unfold_record(recordInfo, numberOfFolds)
    local nextRecord = ""
    local newAmounts = {}
    for i = 1, numberOfFolds do
      nextRecord = nextRecord .. recordInfo.record
      if i < numberOfFolds then nextRecord = nextRecord .. "?" end

      for _, amount in ipairs(recordInfo.amounts) do
        newAmounts[#newAmounts + 1] = amount
      end
    end
    return { record = nextRecord, amounts = newAmounts }
  end

  local arrangements = 0
  for _, recordInfo in ipairs(records) do
    local currentRecordInfo = unfold_record(recordInfo, 5)
    arrangements = arrangements + count_arrangements(currentRecordInfo)
  end
  return arrangements
end

local records = read_records(read_lines(problemNumber))
print("part 1: " .. part_1(records))
print("part 2: " .. part_2(records))
