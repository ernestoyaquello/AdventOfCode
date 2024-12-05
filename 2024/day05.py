import input
import re

PROBLEM_NUMBER = 5

def read_rules_and_updates():
    rules, updates = [], []

    for line in input.read_lines(problem_number = PROBLEM_NUMBER):
        if "|" in line:
            rules.append((line.split("|")[0], line.split("|")[1]))
        elif len(line) > 0:
            updates.append(line.split(","))

    return rules, updates

def process_updates(sum_type):
    valid_updates = []
    corrected_updates = []

    # Process the updates to see if they are valid and to correct them if not when necessary
    rules, updates_to_process = read_rules_and_updates()
    while len(updates_to_process) > 0:
        next_updates_to_process = []
        for update in updates_to_process:
            # Go over all the rules to see if the update is currently breaking any
            broken_rule = None
            update_as_string = ",".join(update)
            for rule_left, rule_right in rules:
                if rule_left in update and rule_right in update:
                    rule_pattern = re.compile(rule_left + r",(?:.+,)?" + rule_right)
                    if rule_pattern.search(update_as_string) is None:
                        broken_rule = (rule_left, rule_right)
                        break

            if broken_rule is None:
                # No rules were broken, which means that the update is valid
                valid_updates.append(update)
            elif sum_type == "middle_page_corrected_updates":
                # At least one rule was broken and correction is enabled, so we need to correct the update
                index_left = update.index(broken_rule[0])
                index_right = update.index(broken_rule[1])
                update[index_left], update[index_right] = update[index_right], update[index_left]
                if update not in corrected_updates:
                    corrected_updates.append(update)

                # Let's process the corrected update again just in case the correction caused other rules to break
                next_updates_to_process.append(update)

        # Ensure we update the list of updates to process
        updates_to_process = next_updates_to_process

    # Print the middle pages of the corresponding updates as stated in the problem
    if sum_type == "middle_page_valid_updates":
        return sum(int(valid_update[len(valid_update) // 2]) for valid_update in valid_updates)
    elif sum_type == "middle_page_corrected_updates":
        return sum(int(valid_update[len(valid_update) // 2]) for valid_update in corrected_updates)

print("Part 1: " + str(process_updates("middle_page_valid_updates")))
print("Part 2: " + str(process_updates("middle_page_corrected_updates")))