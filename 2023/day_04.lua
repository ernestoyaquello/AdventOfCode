require "input_helper"

local problemNumber = 4

local function shallow_copy(list)
  local copiedList = {}
  for key, value in pairs(list) do copiedList[key] = value end
  return copiedList
end

local function find_number_of_matches(cards)
  for _, card in pairs(cards) do
    -- Sort the numbers to find matches efficiently, making sure to copy the collections to avoid messing up the initial data
    local firstSet = shallow_copy(card.firstSet)
    local secondSet = shallow_copy(card.secondSet)
    table.sort(firstSet)
    table.sort(secondSet)

    -- Keep indices for both sets and increment them with single steps to find matches without having to nest full loops
    local numberOfMatches = 0
    local winningNumberIndex = 1
    local ownedNumberIndex = 1
    while winningNumberIndex <= #firstSet do
      while ownedNumberIndex <= #secondSet and secondSet[ownedNumberIndex] <= firstSet[winningNumberIndex] do
        if secondSet[ownedNumberIndex] == firstSet[winningNumberIndex] then
          numberOfMatches = numberOfMatches + 1
        end
        ownedNumberIndex = ownedNumberIndex + 1
      end
      winningNumberIndex = winningNumberIndex + 1
    end

    -- Store the number of matches directly in the card
    card.numberOfMatches = numberOfMatches
  end
end

local function read_cards(lines)
  local cards = {}

  for _, line in ipairs(lines) do
    -- Lua doesn't have proper regex, so we need to simplify things in the expression and then apply extra operations... :(
    local cardNumberRaw, firstSetRaw, secondSetRaw = line:gmatch("Card +(%d+): ([%d ]+) | ([%d ]+)")()

    local firstSet = {}
    for number in firstSetRaw:gmatch(" *(%d+) *") do firstSet[#firstSet + 1] = tonumber(number) end

    local secondSet = {}
    for number in secondSetRaw:gmatch(" *(%d+) *") do secondSet[#secondSet + 1] = tonumber(number) end

    local cardNumber = tonumber(cardNumberRaw)
    cards[cardNumber] = { cardNumber = cardNumber, firstSet = firstSet, secondSet = secondSet }
  end

  find_number_of_matches(cards)
  return cards
end

local function part_1(cards)
  local result = 0

  for _, card in pairs(cards) do
    local cardPoints = 0
    for _ = 1, card.numberOfMatches do
      if cardPoints == 0 then cardPoints = 1 else cardPoints = cardPoints << 1 end
    end
    result = result + cardPoints
  end

  return result
end

local function part_2(cards)
  local newCards = {}
  for _, card in pairs(cards) do newCards[#newCards + 1] = card end

  local cardIndex = 1
  while cardIndex < #newCards do
    local card = newCards[cardIndex]
    for offset = 1, card.numberOfMatches do
      newCards[#newCards + 1] = cards[newCards[card.cardNumber + offset].cardNumber]
    end
    cardIndex = cardIndex + 1
  end

  return #newCards
end

local cards = read_cards(read_lines(problemNumber))

print("part 1: " .. part_1(cards))
print("part 2: " .. part_2(cards))
