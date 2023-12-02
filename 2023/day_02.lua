require "input_helper"

local problemNumber = 2

local function read_games(lines)
  local games = {}

  for _, line in ipairs(lines) do
    line = line .. ";"
    for gameNumber, gameInfo in line:gmatch("Game (%d+): (.+)") do
      local game = { number = tonumber(gameNumber), reveals = {} }
      for reveal in gameInfo:gmatch(" ?([^;]+);") do
        local revealInfo = {}
        for cubeAmount, cubeColor in reveal:gmatch("(%d+) (%w+)") do
          revealInfo[cubeColor] = tonumber(cubeAmount)
        end
        game.reveals[#game.reveals + 1] = revealInfo
      end
      games[#games + 1] = game
    end
  end

  return games
end

local function part_1(games)
  local possibleGames = 0
  local maximums = { red = 12, green = 13, blue = 14 }

  for _, game in ipairs(games) do
    local isValid = true

    for _, reveal in ipairs(game.reveals) do
      for cubeColor, amount in pairs(reveal) do
        if amount > maximums[cubeColor] then
          isValid = false
          break
        end
      end
      if not isValid then break end
    end

    if isValid then possibleGames = possibleGames + game.number end
  end

  return possibleGames
end

local function part_2(games)
  local result = 0

  for _, game in ipairs(games) do
    local maxFound = { red = 0, green = 0, blue = 0 }

    for _, reveal in ipairs(game.reveals) do
      for cubeColor, amount in pairs(reveal) do
        if amount > maxFound[cubeColor] then
          maxFound[cubeColor] = amount
        end
      end
    end

    result = result + (maxFound.red * maxFound.green * maxFound.blue)
  end

  return result
end

local games = read_games(read_lines(problemNumber))
print("part 1: " .. part_1(games))
print("part 2: " .. part_2(games))
