require "input_helper"

local problemNumber = 7

local FIVE_OF_A_KIND, FOUR_OF_A_KIND, FULL_HOUSE, THREE_OF_A_KIND, TWO_PAIR, ONE_PAIR, HIGH_CARD = 7, 6, 5, 4, 3, 2, 1
local CARD_LABEL_STRENGTH = { A = 13, K = 12, Q = 11, J = 10, T = 9, ["9"] = 8, ["8"] = 7, ["7"] = 6, ["6"] = 5, ["5"] = 4, ["4"] = 3, ["3"] = 2, ["2"] = 1 }

local function read_hands(lines)
  local hands = {}

  for _, line in ipairs(lines) do
    hands[#hands + 1] = {
      cards = line:sub(1, 5),              -- E.g., 32T3K
      bet = tonumber(line:sub(7, #line)),  -- E.g., 765
    }
  end

  return hands
end

local function compare_hands(first, second)
  return first.type < second.type or (first.type == second.type and first.strength < second.strength)
end

local function enrich_hand(hand)
  -- Determine the strength of the hand based solely on the strength value of each card label and its position
  hand.strength = 0
  for i = 1, #hand.cards do
    local cardLabel = hand.cards:sub(i, i)
    hand.strength = hand.strength + ((14 ^ (5 - i)) * CARD_LABEL_STRENGTH[cardLabel]) -- numeric value calculated with base 14
  end

  -- Count the number of occurrences of each distinct card label within the hand
  local cardLabels = {} -- map/dictionary that will store the number of occurrences of each card label present in the hand
  for i = 1, #hand.cards do
    local cardLabel = hand.cards:sub(i, i)
    if cardLabels[cardLabel] == nil then
      cardLabels[cardLabel] = 1
    else
      cardLabels[cardLabel] = cardLabels[cardLabel] + 1
    end
  end
  local cardLabelCounts = {} -- sorted list with just the values of the map/dictionary "cardLabels" created above
  for _, cardLabelCount in pairs(cardLabels) do
    cardLabelCounts[#cardLabelCounts + 1] = cardLabelCount
  end
  table.sort(cardLabelCounts)

  -- Determine the type of hand based on the card label counts
  if #cardLabelCounts == 1 then
    hand.type = FIVE_OF_A_KIND  -- e.g., AAAAA
  elseif #cardLabelCounts == 2 and cardLabelCounts[1] == 1 then
    hand.type = FOUR_OF_A_KIND  -- e.g., AA8AA
  elseif #cardLabelCounts == 2 and cardLabelCounts[1] == 2 then
    hand.type = FULL_HOUSE      -- e.g., 23332
  elseif #cardLabelCounts == 3 and cardLabelCounts[1] == 1 and cardLabelCounts[2] == 1 then
    hand.type = THREE_OF_A_KIND -- e.g., TTT98
  elseif #cardLabelCounts == 3 and cardLabelCounts[1] == 1 and cardLabelCounts[2] == 2 then
    hand.type = TWO_PAIR        -- e.g., 23432
  elseif #cardLabelCounts == 4 and cardLabelCounts[4] == 2 then
    hand.type = ONE_PAIR        -- e.g., A23A4
  else
    hand.type = HIGH_CARD       -- e.g., 23456
  end
end

local function find_best_hand_version(hand, jokerPosition)
  local bestHand = hand

  -- Replace the joker with each one of the other card labels, then recursively keep doing it so we explore all the possibilities
  for newCardLabel, _ in pairs(CARD_LABEL_STRENGTH) do
    local candidateHandCards = hand.cards:sub(1, jokerPosition - 1) .. newCardLabel .. hand.cards:sub(jokerPosition + 1, #hand.cards)
    local candidateHand = { cards = candidateHandCards, bet = hand.bet }
    enrich_hand(candidateHand)
    candidateHand.strength = hand.strength -- The strength must remain unchanged after the card label substitution, only the type changes

    -- If there are more joker cards to substitute, we keep going down the tree
    local nextJokerPosition = candidateHand.cards:find("J", jokerPosition + 1)
    if nextJokerPosition ~= nil then
      candidateHand = find_best_hand_version(candidateHand, nextJokerPosition)
    end

    -- If the candidate card has a better score than the current best one, replace the current best one with it
    if compare_hands(bestHand, candidateHand) then bestHand = candidateHand end
  end

  return bestHand
end

local function enrich_hands(hands, includeJoker)
  if includeJoker then CARD_LABEL_STRENGTH.J = 0 end

  for i = 1, #hands do
    local hand = hands[i]
    enrich_hand(hand)

    if includeJoker then
      local firstJokerPosition = hand.cards:find("J")
      if firstJokerPosition ~= nil then
        hands[i] = find_best_hand_version(hand, firstJokerPosition)
      end
    end
  end

  table.sort(hands, compare_hands)
  CARD_LABEL_STRENGTH.J = 10 -- restore to its default value
end

local function calculateTotalWinnings(hands, includeJoker)
  local winnings = 0

  enrich_hands(hands, includeJoker)
  for rank = 1, #hands do
    winnings = winnings + (rank * hands[rank].bet)
  end

  return winnings
end

local hands = read_hands(read_lines(problemNumber))
print("part 1: " .. calculateTotalWinnings(hands, false))
print("part 2: " .. calculateTotalWinnings(hands, true))