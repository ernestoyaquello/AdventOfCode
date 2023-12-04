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
    local firstSetIndex = 1
    local secondSetIndex = 1
    while firstSetIndex <= #firstSet do
      while secondSetIndex <= #secondSet and secondSet[secondSetIndex] <= firstSet[firstSetIndex] do
        if secondSet[secondSetIndex] == firstSet[firstSetIndex] then
          numberOfMatches = numberOfMatches + 1
        end
        secondSetIndex = secondSetIndex + 1
      end
      firstSetIndex = firstSetIndex + 1
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
  local function count_cards(card)
    -- If the result is already stored, return it directly
    if card.cardCount ~= nil then return card.cardCount end

    -- Recursively get the total number of cards associated with this one
    local cardCount = 1
    for cardNumberOffset = 1, card.numberOfMatches do
      cardCount = cardCount + count_cards(cards[card.cardNumber + cardNumberOffset])
    end

    -- Store the result to avoid doing the same calculations again if this card comes up once more
    card.cardCount = cardCount
    return cardCount
  end

  local numberOfCards = 0
  for _, card in pairs(cards) do
    numberOfCards = numberOfCards + count_cards(card)
  end
  return numberOfCards
end

local cards = read_cards(read_lines(problemNumber))

print("part 1: " .. part_1(cards))
print("part 2: " .. part_2(cards))
