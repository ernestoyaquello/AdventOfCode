require "input_helper"

local problemNumber = 22

-- Generates a small table representing a coordinate, making sure that coordinates with the same
-- content (x, y, z) are actually the same instance. That way, we can compare them properly.
local function coordinate_generator()
  local coordinates = {}
  return function(x, y, z)
    if coordinates[x] == nil then coordinates[x] = {} end
    if coordinates[x][y] == nil then coordinates[x][y] = {} end
    if z == nil then z = "none" end
    if coordinates[x][y][z] == nil then coordinates[x][y][z] = { x = x, y = y, z = z } end
    return coordinates[x][y][z]
  end
end

local function read_bricks_info(lines, coordGen)
  local bricksInfo = {
    bricksById = {},
    occupiedCubes = {},
  }

  local count = 0
  for _, line in ipairs(lines) do
    local rawX, rawY, rawZ, rawX2, rawY2, rawZ2 = line:gmatch("(%d+),(%d+),(%d+)~(%d+),(%d+),(%d+)")()
    local brick = {
      id = count + 1,
      firstCorner = coordGen(tonumber(rawX), tonumber(rawY), tonumber(rawZ)),
      secondCorner = coordGen(tonumber(rawX2), tonumber(rawY2), tonumber(rawZ2)),
      cubes = {},
    }
    brick.getMinZ = function () return math.min(brick.firstCorner.z, brick.secondCorner.z) end
    brick.getMaxZ = function () return math.max(brick.firstCorner.z, brick.secondCorner.z) end

    local xIncrement = 1
    if brick.firstCorner.x > brick.secondCorner.x then xIncrement = -1 end
    for x = brick.firstCorner.x, brick.secondCorner.x, xIncrement do
      local yIncrement = 1
      if brick.firstCorner.y > brick.secondCorner.y then yIncrement = -1 end
      for y = brick.firstCorner.y, brick.secondCorner.y, yIncrement do
        local zIncrement = 1
        if brick.firstCorner.z > brick.secondCorner.z then zIncrement = -1 end
        for z = brick.firstCorner.z, brick.secondCorner.z, zIncrement do
          local cubePosition = coordGen(x, y, z)
          brick.cubes[cubePosition] = cubePosition
          bricksInfo.occupiedCubes[cubePosition] = brick
        end
      end
    end

    bricksInfo.bricksById[brick.id] = brick
    count = count + 1
  end

  return bricksInfo
end

local function make_bricks_fall(bricksInfo, coordGen)
  local bricksThatFellById = {}

  for _, brick in pairs(bricksInfo.bricksById) do
    brick.supportedBricksById = {}
    brick.supporterBricksById = {}
  end

  local fallingBricks = bricksInfo.bricksById
  while #fallingBricks > 0 do
    local nextFallingBricks = {}

    for _, fallingBrick in pairs(fallingBricks) do
      local brickCubesAfterFall = {}
      for cubePosition in pairs(fallingBrick.cubes) do
        local nextCubePosition = coordGen(cubePosition.x, cubePosition.y, cubePosition.z - 1)
        if bricksInfo.occupiedCubes[nextCubePosition] ~= nil and bricksInfo.occupiedCubes[nextCubePosition] ~= fallingBrick then
          brickCubesAfterFall = nil -- the cube cannot actually fall any further
          local supporterBrick = bricksInfo.occupiedCubes[nextCubePosition]
          fallingBrick.supporterBricksById[supporterBrick.id] = supporterBrick
          supporterBrick.supportedBricksById[fallingBrick.id] = fallingBrick
        elseif nextCubePosition.z < 1 then
          brickCubesAfterFall = nil -- the cube cannot actually fall any further
          fallingBrick.supporterBricksById[0] = { id = 0 } -- zero is the ID for the floor
        elseif brickCubesAfterFall ~= nil then
          brickCubesAfterFall[nextCubePosition] = nextCubePosition
        end
      end
      if brickCubesAfterFall ~= nil then
        for outdatedCubePosition in pairs(fallingBrick.cubes) do
          bricksInfo.occupiedCubes[outdatedCubePosition] = nil
        end
        fallingBrick.cubes = brickCubesAfterFall
        for newCubePosition in pairs(fallingBrick.cubes) do
          bricksInfo.occupiedCubes[newCubePosition] = fallingBrick
        end
        for _, supportedCube in pairs(fallingBrick.supportedBricksById) do
          nextFallingBricks[#nextFallingBricks + 1] = supportedCube
          supportedCube.supporterBricksById[fallingBrick.id] = nil
        end
        fallingBrick.supportedBricksById = {}
        fallingBrick.firstCorner = coordGen(fallingBrick.firstCorner.x, fallingBrick.firstCorner.y, fallingBrick.firstCorner.z - 1)
        fallingBrick.secondCorner = coordGen(fallingBrick.secondCorner.x, fallingBrick.secondCorner.y, fallingBrick.secondCorner.z - 1)
        nextFallingBricks[#nextFallingBricks + 1] = fallingBrick
        bricksThatFellById[fallingBrick.id] = fallingBrick
      end
    end

    fallingBricks = nextFallingBricks
  end

  local numberOfFallenBricks = 0
  for _ in pairs(bricksThatFellById) do
    numberOfFallenBricks = numberOfFallenBricks + 1
  end
  return numberOfFallenBricks
end

local function find_safely_removable_bricks(bricksInfo)
  local bricksThatCanBeDisintegrated = {}
  for _, brick in pairs(bricksInfo.bricksById) do
    local allSupportedHaveOtherSupporters = true
    for _, supportedBrick in pairs(brick.supportedBricksById) do
      local hasOtherSupporters = false
      for _, supportedSupporterBrick in pairs(supportedBrick.supporterBricksById) do
        if supportedSupporterBrick.id ~= brick.id then
          hasOtherSupporters = true
          break
        end
      end
      if not hasOtherSupporters then
        allSupportedHaveOtherSupporters = false
        break
      end
    end

    if allSupportedHaveOtherSupporters then
      bricksThatCanBeDisintegrated[#bricksThatCanBeDisintegrated + 1] = brick
    end
  end

  return bricksThatCanBeDisintegrated
end

local function part_1(coordGen)
  local bricksInfo = read_bricks_info(read_lines(problemNumber), coordGen)
  make_bricks_fall(bricksInfo, coordGen)
  return #find_safely_removable_bricks(bricksInfo)
end

local function part_2(coordGen)
  local bricksInfo = read_bricks_info(read_lines(problemNumber), coordGen)
  make_bricks_fall(bricksInfo, coordGen)
  local safelyRemovableBricks = find_safely_removable_bricks(bricksInfo)

  -- Find the bricks that aren't safe to remove, as those are the ones who will cause others to fall when removed
  local brickToRemoveIds = {}
  for brickToRemoveId in pairs(bricksInfo.bricksById) do
    local isSafelyRemovable = false
    for _, safelyRemovableBrick in ipairs(safelyRemovableBricks) do
      if safelyRemovableBrick.id == brickToRemoveId then
        isSafelyRemovable = true
        break
      end
    end
    if not isSafelyRemovable then
      brickToRemoveIds[#brickToRemoveIds + 1] = brickToRemoveId
    end
  end

  -- See how many bricks would fall as a consequence of removing each one of the unsafely removable bricks
  local totalNumberOfFallenBricks = 0
  for _, brickToRemoveId in ipairs(brickToRemoveIds) do
    local brickToRemove = bricksInfo.bricksById[brickToRemoveId]
    -- Create a backup of all the data before removing the brick
    local bricksInfoBackup = { bricksById = {}, occupiedCubes = {} }
    for brickToBackupId in pairs(bricksInfo.bricksById) do
      local brickToBackup = bricksInfo.bricksById[brickToBackupId]
      local brickBackUp = {
        id = brickToBackup.id,
        firstCorner = coordGen(brickToBackup.firstCorner.x, brickToBackup.firstCorner.y, brickToBackup.firstCorner.z),
        secondCorner = coordGen(brickToBackup.secondCorner.x, brickToBackup.secondCorner.y, brickToBackup.secondCorner.z),
        cubes = {},
        supportedBricksById = {},
        supporterBricksById = {},
      }
      brickBackUp.getMinZ = function () return math.min(brickBackUp.firstCorner.z, brickBackUp.secondCorner.z) end
      brickBackUp.getMaxZ = function () return math.max(brickBackUp.firstCorner.z, brickBackUp.secondCorner.z) end
      for position in pairs(brickToBackup.cubes) do
        brickBackUp.cubes[position] = position
        bricksInfoBackup.occupiedCubes[position] = brickBackUp
      end
      bricksInfoBackup.bricksById[brickBackUp.id] = brickBackUp
    end
    for brickBackUpId, brickBackUp in pairs(bricksInfoBackup.bricksById) do
      local brickToBackup = bricksInfo.bricksById[brickBackUpId]
      for supportedBrickId, _ in pairs(brickToBackup.supportedBricksById) do
        brickBackUp.supportedBricksById[supportedBrickId] = bricksInfoBackup.bricksById[supportedBrickId]
      end
      for supporterBrickId, _ in pairs(brickToBackup.supporterBricksById) do
        brickBackUp.supporterBricksById[supporterBrickId] = bricksInfoBackup.bricksById[supporterBrickId]
      end
    end

    -- Remove the brick and see how many other bricks fall as a consequence
    for _, supportedBrick in pairs(brickToRemove.supportedBricksById) do
      supportedBrick.supporterBricksById[brickToRemove.id] = nil
    end
    for _, supporterBrick in pairs(brickToRemove.supporterBricksById) do
      if supporterBrick.id ~= 0 then -- avoid the floor "brick"
        supporterBrick.supportedBricksById[brickToRemove.id] = nil
      end
    end
    for cubePosition in pairs(brickToRemove.cubes) do
      bricksInfo.occupiedCubes[cubePosition] = nil
    end
    bricksInfo.bricksById[brickToRemove.id] = nil
    totalNumberOfFallenBricks = totalNumberOfFallenBricks + make_bricks_fall(bricksInfo, coordGen)

    -- Restore the data from before the brick had been removed
    bricksInfo = bricksInfoBackup
  end

  return totalNumberOfFallenBricks
end

print("part 1: " .. part_1(coordinate_generator()))
print("part 2: " .. part_2(coordinate_generator()))
