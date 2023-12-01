#include "day14.h"

int main()
{
	const auto start_time = std::chrono::steady_clock::now();

	//const auto total = part1();
	const auto total = part2();
	std::cout << "Result: " << total << std::endl;

	const auto end_time = std::chrono::steady_clock::now();
	const std::chrono::duration<double> elapsed_seconds = end_time - start_time;
	std::cout << "Elapsed time: " << elapsed_seconds.count() << "s" << std::endl;

	return 0;
}

unsigned long long part1()
{
	const auto memory = read_memory(false);
	unsigned long long total = 0;
	for (const auto memory_value : memory) total += memory_value.second;
	return total;
}

unsigned long long part2()
{
	const auto memory = read_memory(true);
	unsigned long long total = 0;
	for (const auto memory_value : memory) total += memory_value.second;
	return total;
}

std::map<unsigned long long, unsigned long long> read_memory(bool use_address_decoder)
{
	std::map<unsigned long long, unsigned long long> memory;
	unsigned long long or_mask = 0, and_mask = 0b111111111111111111111111111111111111;
	std::string mask;

	char _[6];
	char command;
	std::cin.get();
	while (!std::cin.eof() && (command = std::cin.get()))
	{
		if (command == 'a') // Mask
		{
			std::cin.read(_, 5);
			std::cin >> mask;

			if (!use_address_decoder)
			{
				or_mask = 0;
				and_mask = 0b111111111111111111111111111111111111;
				for (std::size_t i = 0; i < mask.size(); i++)
					if (mask[i] == '1')
						or_mask += std::pow(2, mask.size() - i - 1);
					else if (mask[i] == '0')
						and_mask -= std::pow(2, mask.size() - i - 1);
			}
		}
		else if (command == 'e') // Memory access
		{
			unsigned long long address, value;
			std::cin.read(_, 2);
			std::cin >> address;
			std::cin.read(_, 4);
			std::cin >> value;
			value = value & and_mask | or_mask;

			const auto memory_addresses = !use_address_decoder ? std::vector<unsigned long long> { address } : get_decoded_addresses(address, mask, 0);
			for (const auto memory_address : memory_addresses)
			{
				std::map<unsigned long long, unsigned long long>::iterator it;
				if ((it = memory.find(memory_address)) == memory.end())
					memory.insert(std::make_pair(memory_address, value));
				else
					it->second = value;
			}
		}

		while (std::cin.peek() == '\n' || std::cin.peek() == 'm')
			std::cin.get();
	}

	return memory;
}

std::vector<unsigned long long> get_decoded_addresses(unsigned long long address, std::string mask, std::size_t index)
{
	const char mandatory_zero_char = '#'; // Normal zero characters are ignored here, but this special representation of a zero will be applied
	const char floating_bit_char = 'X';
	std::vector<unsigned long long> result;
	
	if (index == mask.size()) // Base case: no more characters to process, so now we apply the final mask(s) to the address
	{
		unsigned long long or_mask = 0, and_mask = 0b111111111111111111111111111111111111;
		for (std::size_t i = 0; i < mask.size(); i++)
			if (mask[i] != mandatory_zero_char)
				or_mask += mask[i] == '1' ? std::pow(2, mask.size() - i - 1) : 0;
			else
				and_mask -= std::pow(2, mask.size() - i - 1);

		result.push_back(address & and_mask | or_mask);
	}
	else if (mask[index] == floating_bit_char) // Floating bit: we need to replace it with a zero AND with a one
	{
		for (auto const mask_char : { mandatory_zero_char, '1' })
		{
			mask[index] = mask_char;
			const auto mask_addresses = get_decoded_addresses(address, mask, index + 1);
			for (const auto address_to_add : mask_addresses)
				result.push_back(address_to_add);
		}
	}
	else // No processing needed here: we just get the result from the next level
	{
		result = get_decoded_addresses(address, mask, index + 1);
	}

	return result;
}