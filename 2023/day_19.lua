require "input_helper"

local problemNumber = 19

local function create_condition_function(conditionString, propertyNames)
  local propertyName, sign, value = conditionString:gmatch("(%w+)([<>])(%d+)")()
  propertyNames[propertyName] = propertyName
  if sign == "<" then
    return function (item) return item[propertyName] < tonumber(value) end
  elseif sign == ">" then
    return function (item) return item[propertyName] > tonumber(value) end
  end
  return nil
end

local function read_data(lines)
  local workflows = {}
  local parts = {}
  local rulesByDestination = {}
  local propertyNames = {}

  for _, line in ipairs(lines) do
    if line:sub(1, 1) ~= "{" then -- Read workflow
      local name, content = line:gmatch("(%w+)%{([^%}]+)%}")()
      local workflow = { name = name, startRule = nil }
      content = content .. ","
      local previousRule = nil
      for ruleContent in content:gmatch("([^,]+),") do
        local newRule = { successWorkflowName = ruleContent, parentWorkflowName = workflow.name }
        if ruleContent:find(":") then
          local condition, success = ruleContent:gmatch("(%w+[<>]%d+):(%w+)")()
          newRule = {
            condition = create_condition_function(condition, propertyNames),
            conditionString = condition,
            successWorkflowName = success,
            parentWorkflowName = workflow.name,
          }
        end

        if workflow.startRule == nil then
          workflow.startRule = newRule
        end

        if previousRule ~= nil then
          previousRule.failureRule = newRule
          newRule.failureAt = previousRule
        end

        if rulesByDestination[newRule.successWorkflowName] == nil then rulesByDestination[newRule.successWorkflowName] = {} end
        rulesByDestination[newRule.successWorkflowName][#rulesByDestination[newRule.successWorkflowName] + 1] = newRule

        previousRule = newRule
      end
      workflows[workflow.name] = workflow
    else -- Read part
      local part = {}
      for property, propertyValue in line:sub(2, #line - 1):gmatch("(%w+)=(%d+)") do
        part[property] = tonumber(propertyValue)
      end
      parts[#parts + 1] = part
    end
  end

  return workflows, parts, rulesByDestination, propertyNames
end

local function part_1(workflows, parts)
  local totalValueAcceptedParts = 0
  for _, part in ipairs(parts) do
    local workflowName = "in"
    while workflowName ~= "A" and workflowName ~= "R" do
      local workflow = workflows[workflowName]
      local rule = workflow.startRule
      workflowName = nil
      while workflowName == nil do
        if rule.condition == nil or rule.condition(part) then
          workflowName = rule.successWorkflowName
        else
          rule = rule.failureRule
        end
      end
    end
    if workflowName == "A" then
      for _, value in pairs(part) do
        totalValueAcceptedParts = totalValueAcceptedParts + value
      end
    end
  end
  return totalValueAcceptedParts
end

local function part_2(workflows, rulesByDestination, propertyNames)
  local function find_rule_conditions(rule, rulesByDestination, propertyNames)
    local allRuleConditions = {}
    local ruleConditions = {}

    if rule.condition ~= nil then
      local propertyName, sign, value = rule.conditionString:gmatch("(%w+)([<>])(%d+)")()
      if ruleConditions[propertyName] == nil then
        ruleConditions[propertyName] = { minimum = 0, maximum = 4001 }
      end
      if sign == ">" then ruleConditions[propertyName].minimum = math.max(ruleConditions[propertyName].minimum, tonumber(value)) end
      if sign == "<" then ruleConditions[propertyName].maximum = math.min(ruleConditions[propertyName].maximum, tonumber(value)) end
    end

    local previousRule = rule.failureAt
    while previousRule ~= nil do
      local propertyName, sign, value = previousRule.conditionString:gmatch("(%w+)([<>])(%d+)")()
      if ruleConditions[propertyName] == nil then
        ruleConditions[propertyName] = { minimum = 0, maximum = 4001 }
      end
      if sign == "<" then ruleConditions[propertyName].minimum = math.max(ruleConditions[propertyName].minimum, tonumber(value) - 1) end
      if sign == ">" then ruleConditions[propertyName].maximum = math.min(ruleConditions[propertyName].maximum, tonumber(value) + 1) end
      previousRule = previousRule.failureAt
    end

    if rule.parentWorkflowName ~= "in" then
      for _, ruleToGetHere in ipairs(rulesByDestination[rule.parentWorkflowName]) do
        local ruleToGetHereConditions = find_rule_conditions(ruleToGetHere, rulesByDestination, propertyNames)
        for _, ruleToGetHereCondition in ipairs(ruleToGetHereConditions) do
          local newCondition = {}
          for propertyName, condition in pairs(ruleConditions) do
            newCondition[propertyName] = { minimum = condition.minimum, maximum = condition.maximum }
          end
          for propertyName, condition in pairs(ruleToGetHereCondition) do
            if newCondition[propertyName] == nil then
              newCondition[propertyName] = { minimum = 0, maximum = 4001 }
            end
            newCondition[propertyName] = {
              minimum = math.max(newCondition[propertyName].minimum, condition.minimum),
              maximum = math.min(newCondition[propertyName].maximum, condition.maximum),
            }
          end
          allRuleConditions[#allRuleConditions + 1] = newCondition
        end
      end
    else
      allRuleConditions[#allRuleConditions + 1] = ruleConditions
    end

    for _, ruleCondition in ipairs(allRuleConditions) do
      for propertyName in pairs(propertyNames) do
        if ruleCondition[propertyName] == nil then
          ruleCondition[propertyName] = { minimum = 0, maximum = 4001 }
        end
      end
    end

    return allRuleConditions
  end

  local totalPossibitilies = 0

  local allPropertyRanges = {}
  for _, acceptedRule in ipairs(rulesByDestination["A"]) do
    local ruleConditions = find_rule_conditions(acceptedRule, rulesByDestination, propertyNames)
    for _, propertyRanges in ipairs(ruleConditions) do
      allPropertyRanges[#allPropertyRanges + 1] = propertyRanges
      local possibilities = 1
      for propertyName in pairs(propertyNames) do
        possibilities = possibilities * (1 + (propertyRanges[propertyName].maximum - 1) - (propertyRanges[propertyName].minimum + 1))
      end
      totalPossibitilies = totalPossibitilies + possibilities
    end
  end

  return totalPossibitilies
end

local workflows, parts, rulesByDestination, propertyNames = read_data(read_lines(problemNumber))
print("part 1: " .. part_1(workflows, parts))
print("part 2: " .. part_2(workflows, rulesByDestination, propertyNames))
