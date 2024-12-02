import input
from more_itertools import pairwise

PROBLEM_NUMBER = 2

def count_safe_reports(reports, error_tolerance = False):
    return sum(is_safe_report(report, error_tolerance) for report in reports)

def is_safe_report(report, error_tolerance):
    error_indices = find_potential_error_indices(report)

    # If the error tolerance is enabled, we remove each potentially problematic level and check if the report is safe
    if error_indices is not None and error_tolerance:
        for potential_error_index in error_indices:
            potentially_wrong_level = report.pop(potential_error_index)
            error_indices = find_potential_error_indices(report)
            report.insert(potential_error_index, potentially_wrong_level)
            if error_indices is None:
                # After removing the potentially problematic level, the report is now safe, no need to keep checking
                break

    return error_indices is None

def find_potential_error_indices(report):
    # This will indicate if the report is increasing or decreasing (1 if increasing, -1 if decreasing, 0 if neither)
    report_normal_diff = None
    for index, (first_level, second_level) in enumerate(pairwise(report)):
        diff = first_level - second_level
        normal_diff = diff / abs(diff) if diff != 0 else 0

        # Check if the level is valid, and return the potentially problematic level indices if not
        is_valid_level = abs(diff) >= 1 and abs(diff) <= 3 and (report_normal_diff is None or normal_diff == report_normal_diff)
        if not is_valid_level:
            if index != 1:
                # Either this level or the next one is causing the error
                return (index, index + 1)
            else:
                # The first level (index 0) might be the wrong one causing the error, so let's include it
                return (index - 1, index, index + 1)

        # Otherwise, stablish whether levels are increasing or decreasing and continue
        report_normal_diff = normal_diff

    # No error indices to return because the report is safe
    return None

reports = [[int(level) for level in report] for report in input.read_lists(problem_number = PROBLEM_NUMBER)]
print("Part 1: " + str(count_safe_reports(reports, error_tolerance = False)))
print("Part 2: " + str(count_safe_reports(reports, error_tolerance = True)))