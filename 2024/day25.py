import input

PROBLEM_NUMBER = 25

def count_fitting_pairs():
    count = 0
    data = read_data()
    for key in data["keys"]:
        for lock in data["locks"]:
            fit = True
            for i in range(0, len(key)):
                if (key[i] + lock[i]) > 5:
                    fit = False
                    break
            if fit:
                count += 1
    return count

def read_data():
    data = { "locks": [], "keys": [] }
    locks_and_keys = [lock_or_key.split("\n") for lock_or_key in input.read(problem_number = PROBLEM_NUMBER).split("\n\n")]
    for lock_or_key in locks_and_keys:
        key = "locks"
        y_start = 1
        y_until = len(lock_or_key) - 1
        y_step = 1
        if lock_or_key[0] == ("." * len(lock_or_key[0])):
            key = "keys"
            y_start = len(lock_or_key) - 2
            y_until = -1
            y_step = -1

        pin_lengths = []
        for x in range(0, len(lock_or_key[0])):
            pin_lengths.append(0)
            for y in range(y_start, y_until, y_step):
                pin_lengths[x] += 1 if lock_or_key[y][x] == "#" else 0
        data[key].append(pin_lengths)
    return data

print("Result: " + str(count_fitting_pairs()))