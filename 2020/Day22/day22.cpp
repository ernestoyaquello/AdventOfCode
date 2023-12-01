#include "day22.h"

int main()
{
	const auto start_time = std::chrono::steady_clock::now();

	const auto players_cards = read_data();
	std::cout << "Part 1: " << part1(players_cards) << std::endl;
	std::cout << "Part 2: " << part2(players_cards) << std::endl;

	const auto end_time = std::chrono::steady_clock::now();
	const std::chrono::duration<double> elapsed_seconds = end_time - start_time;
	std::cout << "Elapsed time: " << elapsed_seconds.count() << "s" << std::endl;

	return 0;
}

std::vector<std::vector<int>> read_data()
{
	auto players = std::vector<std::vector<int>>();

	std::string _;
	int number;
	while (!std::cin.eof())
	{
		auto cards = std::vector<int>();
		std::cin >> _ >> _;
		while (std::cin >> number)
			cards.push_back(number);
		std::cin.clear();
		std::cin.ignore();
		players.push_back(cards);
	}

	return players;
}

unsigned long long part1(std::vector<std::vector<int>> players_cards)
{
	auto winner = play_game(&players_cards, false);
	return winner.second;
}

unsigned long long part2(std::vector<std::vector<int>> players_cards)
{
	auto winner = play_game(&players_cards, true);
	return winner.second;
}

std::pair<int, unsigned long long> play_game(std::vector<std::vector<int>>* players_cards, bool recursive_rules)
{
	const auto total_cards = (*players_cards)[0].size() + (*players_cards)[1].size();
	auto winner = -1;
	auto game_history = std::vector<std::string>();
	while (winner == -1)
	{
		auto round_winner_card = -1;
		auto round_winner = -1;
		auto round_cards = std::vector<int>();

		std::string current_turn_string = "";
		for (const auto aux_player : { 0, 1 })
		{
			current_turn_string += std::to_string(aux_player) + ":";
			for (const auto& player_card : (*players_cards)[aux_player])
				current_turn_string += std::to_string(player_card) + ",";
			current_turn_string.erase(current_turn_string.begin() + current_turn_string.size() - 1);
			current_turn_string += aux_player == 0 ? "|" : "";
		}
		game_history.push_back(current_turn_string);

		if (recursive_rules)
		{
			for (size_t i = 0; i < (game_history.size() - 1) && winner == -1; i++)
				winner = game_history[i].compare(current_turn_string) == 0 ? 0 : -1;

			if (winner != -1)
				break;
		}

		for (const auto player : { 0, 1 })
		{
			auto& player_cards = (*players_cards)[player];
			if (player_cards.empty())
				continue;

			winner = player_cards.size() == total_cards ? player : -1;
			if (winner != -1)
				break;

			const auto player_turn_card = player_cards[0];
			if (player_turn_card > round_winner_card)
			{
				round_winner_card = player_turn_card;
				round_winner = player;
				round_cards.push_back(round_winner_card);
			}
			else
			{
				round_cards.push_back(round_cards[0]);
				round_cards[0] = player_turn_card;
			}
			player_cards.erase(player_cards.begin());
		}

		if (winner == -1)
		{
			if (recursive_rules)
			{
				const auto player1_round_card_value = round_cards[round_winner == 0 ? 1 : 0];
				const auto player2_round_card_value = round_cards[round_winner == 1 ? 1 : 0];
				if ((*players_cards)[0].size() >= player1_round_card_value && (*players_cards)[1].size() >= player2_round_card_value)
				{
					auto recursive_game_players_cards = std::vector<std::vector<int>>();
					for (const auto aux_player : { 0, 1 })
					{
						auto max_index = aux_player == 0 ? player1_round_card_value : player2_round_card_value;
						std::vector<int> new_player_cards((*players_cards)[aux_player].begin(), (*players_cards)[aux_player].begin() + max_index);
						recursive_game_players_cards.push_back(new_player_cards);
					}

					const auto subgame_result = play_game(&recursive_game_players_cards, true);
					if (subgame_result.first != round_winner)
					{
						round_winner = subgame_result.first;
						std::reverse(round_cards.begin(), round_cards.end());
					}
				}
			}

			for (int i = round_cards.size() - 1; i >= 0; i--)
				(*players_cards)[round_winner].push_back(round_cards[i]);
		}
	}

	unsigned long long winner_score = 0;
	auto& winner_cards = (*players_cards)[winner];
	for (size_t i = 0; i < winner_cards.size(); i++)
		winner_score += winner_cards[i] * (winner_cards.size() - i);

	return std::make_pair(winner, winner_score);
}