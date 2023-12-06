require "input_helper"

local problemNumber = 6

local function read_games(lines)
  local games = {}

  -- Read times
  for time in lines[1]:gmatch("%d+") do
    games[#games + 1] = { time = tonumber(time) }
  end

  -- Read the distance for each time
  local distanceStart, distanceEnd, i = 1, 1, 1
  while i <= #games do
    distanceStart, distanceEnd = lines[2]:find("%d+", distanceStart)
    games[i].distance = tonumber(lines[2]:sub(distanceStart, distanceEnd))
    distanceStart = distanceEnd + 1
    i = i + 1
  end

  return games
end

local function read_as_single_game(games)
  local time, distance = "", ""
  for _, game in ipairs(games) do
    time = time .. tostring(game.time)
    distance = distance .. tostring(game.distance)
  end
  return { time = tonumber(time), distance = tonumber(distance) }
end

local function count_possible_victories(game)
  -- DISTANCE = (TIME - pressTime) * pressTime == (pressTime * pressTime) - (TIME * pressTime) + DISTANCE = 0
  -- pressTime = (TIME +/- sqrt((TIME * TIME) - (4 * DISTANCE))) / 2
  local cuadratiqSquare = math.sqrt((game.time * game.time) - (4 * game.distance))
  local minPressTimeToBeatRecord = math.floor((game.time - cuadratiqSquare) / 2) + 1
  local maxPressTimeToBeatRecord = math.ceil((game.time + cuadratiqSquare) / 2) - 1
  return maxPressTimeToBeatRecord - minPressTimeToBeatRecord + 1
end

local function part_1(games)
  local result = nil
  for _, game in ipairs(games) do
    local possibleVictories = count_possible_victories(game)
    if result == nil then result = possibleVictories else result = result * possibleVictories end
  end
  return result
end

local function part_2(games)
  local game = read_as_single_game(games)
  return count_possible_victories(game)
end

local games = read_games(read_lines(problemNumber))
print("part 1: " .. part_1(games))
print("part 2: " .. part_2(games))
