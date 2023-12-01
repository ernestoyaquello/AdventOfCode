#include "day4.h"

const string required_fields[] = { "byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid" };
const string valid_eye_colors[] = { "amb", "blu", "brn", "gry", "grn", "hzl", "oth" };

int main()
{
	//part1();
	part2();

	return 0;
}

void part1()
{
	int valid_total = get_number_of_valid_passports(false);
	cout << valid_total;
}

void part2()
{
	int valid_total = get_number_of_valid_passports(true);
	cout << valid_total;
}

int get_number_of_valid_passports(bool validate_data)
{
	const int required_fields_size = sizeof(required_fields) / sizeof(required_fields[0]);
	string _;
	string field_value;
	char* field = new char[4];
	field[3] = '\0';
	int valid_passports = 0;

	while (!cin.eof())
	{
		int valid_required_found = 0;
		while (cin.peek() != '\n' && !cin.eof())
		{
			cin.read(field, 3);
			cin.get();
			cin >> field_value;
			if (cin.peek() == ' ' || cin.peek() == '\n') cin.get();

			bool is_required_field = find(begin(required_fields), end(required_fields), field) != end(required_fields);
			bool is_valid_value = !is_required_field || !validate_data || is_data_valid(field, field_value);
			valid_required_found += is_required_field && is_valid_value ? 1 : 0;
			if (valid_required_found == required_fields_size || !is_valid_value)
			{
				// At this point, we ignore the rest of the passport because we have already confirmed it is either valid or invalid
				while (cin.peek() != '\n' && !cin.eof())
				{
					cin >> _;
					if (cin.peek() == ' ' || cin.peek() == '\n') cin.get();
				}

				valid_passports += is_valid_value ? 1 : 0;
				break;
			}
		}

		while (cin.peek() == '\n') cin.get();
	}

	delete[] field;

	return valid_passports;
}

bool is_data_valid(char* field, string field_value)
{
	if (strcmp(field, "byr") == 0)
		return is_year_valid(field_value, 1920, 2002);

	else if (strcmp(field, "iyr") == 0)
		return is_year_valid(field_value, 2010, 2020);

	else if (strcmp(field, "eyr") == 0)
		return is_year_valid(field_value, 2020, 2030);

	else if (strcmp(field, "hgt") == 0)
		return is_height_valid(field_value);

	else if (strcmp(field, "hcl") == 0)
		return field_value.at(0) == '#' && regex_match(field_value, regex("#[a-f0-9]{6}"));

	else if (strcmp(field, "ecl") == 0)
		return find(begin(valid_eye_colors), end(valid_eye_colors), field_value) != end(valid_eye_colors);

	else if (strcmp(field, "pid") == 0)
		return regex_match(field_value, regex("[0-9]{9}"));

	return false;
}

bool is_year_valid(string year_string, int min_year, int max_year)
{
	int year = 0;
	stringstream year_stream(year_string);
	year_stream >> year;
	return year >= min_year && year <= max_year;
}

bool is_height_valid(string height_string)
{
	int height = 0;
	string units;
	stringstream field_value_stream(height_string);
	field_value_stream >> height >> units;

	if (units == "cm") return height >= 150 && height <= 193;
	else if (units == "in") return height >= 59 && height <= 76;

	return false;
}