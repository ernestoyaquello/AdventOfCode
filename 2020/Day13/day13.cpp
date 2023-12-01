#include "day13.h"

int main()
{
	auto start_time = std::chrono::steady_clock::now();

	//auto result = part1();
	auto result = part2();
	std::cout << "Result: " << result << std::endl;

	auto end_time = std::chrono::steady_clock::now();
	const std::chrono::duration<double> elapsed_seconds = end_time - start_time;
	std::cout << "Elapsed time: " << elapsed_seconds.count() << "s" << std::endl;

	return 0;
}

int part1()
{
	int min_time;
	std::cin >> min_time;
	auto bus_ids_with_times = read_bus_ids_with_times(min_time);
	auto min = bus_ids_with_times[0];
	for (std::size_t i = 1; i < bus_ids_with_times.size(); i++)
		min = bus_ids_with_times[i].second < min.second ? bus_ids_with_times[i] : min;

	auto waiting_time = min.second - min_time;
	return waiting_time * min.first;
}

unsigned long long part2()
{
	// To avoid unnecessary calculations, we assume the minimum time will be 100000000000000 because it says so in the puzzle
	const unsigned long long min_time = 100000000000000L;
	const auto bus_ids_with_offsets = read_bus_ids_with_offsets();
	unsigned long long time_increment = bus_ids_with_offsets[0].first;
	unsigned long long timestamp = (min_time / time_increment) * time_increment;
	for (std::size_t i = 1; i < bus_ids_with_offsets.size(); i++)
	{
		const unsigned long long local_time = bus_ids_with_offsets[i].first;
		const unsigned long long local_offset = bus_ids_with_offsets[i].second;
		while (((timestamp + local_offset) % local_time) != 0)
			timestamp += time_increment;

		// This would need to be the least common multiple, but since all the numbers in the input are prime numbers...
		time_increment = local_time * time_increment;
	}

	return timestamp;
}

std::vector<std::pair<unsigned short, unsigned int>> read_bus_ids_with_times(int min_time)
{
	std::vector<std::pair<unsigned short, unsigned int>> bus_ids_with_times;
	for (unsigned short bus_id = 0; !std::cin.eof() && std::cin >> bus_id; )
	{
		unsigned int time = (min_time / bus_id) * bus_id;
		time = time < min_time ? (time + bus_id) : time;
		bus_ids_with_times.push_back(std::make_pair(bus_id, time));

		while (std::cin.peek() == ',' || std::cin.peek() == 'x' || std::cin.peek() == '\n')
			std::cin.get();
	}

	return bus_ids_with_times;
}

std::vector<std::pair<unsigned short, unsigned short>> read_bus_ids_with_offsets()
{
	// Ignore first number
	int ignored;
	std::cin >> ignored;
	std::cin.get();

	// Read times
	std::vector<std::pair<unsigned short, unsigned short>> bus_ids_with_offsets;
	for (unsigned short bus_id = 0, offset = 0; !std::cin.eof() && std::cin >> bus_id; offset++)
	{
		bus_ids_with_offsets.push_back(std::make_pair(bus_id, offset));
		while (std::cin.peek() == ',' || std::cin.peek() == 'x' || std::cin.peek() == '\n')
		{
			if (std::cin.peek() == 'x') offset++;
			std::cin.get();
		}
	}

	return bus_ids_with_offsets;
}