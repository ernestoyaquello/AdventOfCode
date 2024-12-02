import input
from more_itertools import pairwise

PROBLEM_NUMBER = 2

def count_safe_reports(reports, error_tolerance = False):
    number_of_safe_reports = 0

    for report in reports:
        error_indices = find_potential_error_indices(report)
        if error_indices is not None and error_tolerance:
            for potential_error_index in error_indices:
                if potential_error_index >= 0:
                    potentially_wrong_level = report.pop(potential_error_index)
                    error_indices = find_potential_error_indices(report)
                    if error_indices is None:
                        break
                    report.insert(potential_error_index, potentially_wrong_level)

        is_safe = error_indices is None
        number_of_safe_reports += 1 if is_safe else 0

    return number_of_safe_reports

def find_potential_error_indices(report):
    report_normal_diff = None
    for index, (first_level, second_level) in enumerate(pairwise(report)):
        diff = first_level - second_level
        normal_diff = diff / abs(diff) if diff != 0 else 0
        is_valid_level = abs(diff) >= 1 and abs(diff) <= 3 and (report_normal_diff is None or normal_diff == report_normal_diff)
        if not is_valid_level:
            return (index - 1, index, index + 1)
        report_normal_diff = normal_diff

    return None

reports = [[int(level) for level in report] for report in input.read_lists(problem_number = PROBLEM_NUMBER)]
print("Part 1: " + str(count_safe_reports(reports, error_tolerance = False)))
print("Part 2: " + str(count_safe_reports(reports, error_tolerance = True)))