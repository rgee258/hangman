require "yaml"

class Hangman

	def initialize
		@guesses_remaining = 100
		@word = []
		@word_display = []
		@used_letters = []
		@misses = []
		@game_status = "ongoing"
	end

	# Methods for starting program

	def program_start
		puts "Let's play a round of Hangman!"
		puts "Would you like to start a new game or do want to load an old saved game lying around? Choose from:"
		puts "- New"
		puts "- Load"
		start_choice = gets.chomp.downcase
		puts ""
		if (start_choice == "new")
			start_game(new_word)
		elsif (start_choice == "load")
			load_game
		else
			puts "Your input was invalid, program starting again...\n\n"
			program_start
		end
	end

	def new_word
		# All reading for the 5desk.txt file is done here only.
		word_list = File.readlines("../5desk.txt")
		loop do
			rand_num = rand(word_list.length - 1)
			word = word_list.sample.strip!
			if (word.length > 4 && word.length < 13)
				return word.upcase
			end
		end
	end

	def start_game(word)
		# Set up all of the game's instance variables necessary for the new game.
		@guesses_remaining = 6
		word.each_char do |c|
			@word.push(c)
			@word_display.push("_")
		end
		game_handler
	end

	def load_game
		# Load a saved game from outside of the lib directory, start a new game otherwise.
		begin
			load = YAML::load_file("../save.yml")
			puts "Game successfully loaded, let's continue!\n\n"
			load.game_handler
		rescue
			puts "There is no existing save file."
			puts "Let's start a new game then!\n\n"
			start_game(new_word)
		end
	end

	# Methods for game handling

	def game_handler
		while @guesses_remaining > -1
			display_game
			# Check for win condition here to properly display when we're out of guesses.
			if (game_finished?)
				end_game
			end
			make_turn
		end
	end

	def display_game
		puts "Guesses remaining: #{@guesses_remaining}"
		puts "Your word: #{@word_display.join(" ")}"
		puts "Misses: #{@misses.join(" ")}\n\n"
	end

	def game_finished?
		finished = true
		# Check for any display placeholders, if they exit the game is not finished.
		@word_display.each do |c|
			if (c == "_")
				finished = false
				break
			end
		end

		# If there are no placeholder marks and guesses remaining, then the player has won and the game is finished.
		if (finished)
			if (@guesses_remaining > 0)
				@game_status = "win"
			end
		# There are still placeholders, so if we have no more guesses then the player has lost and the game is finished.
		else
			if (@guesses_remaining == 0)
				@game_status = "lose"
				finished = true
			end
		end
		finished
	end

	def end_game
		if (@game_status == "win")
			puts "Wow, good job guessing that word!"
			if (@guesses_remaining > 1)
				puts "You still had #{@guesses_remaining} guesses to spare!"
			else
				puts "You still had #{@guesses_remaining} guess to spare!"
			end
		elsif (@game_status == "lose")
			puts "Looks like you couldn't guess the word in time."
			puts "The word you were trying to guess was: #{@word.join}"
			puts "Maybe you'll get it next time!"
		end
		exit(0)
	end

	def make_turn
		puts "What would you like to do this turn? Choose from:"
		puts "- Guess"
		puts "- Save"
		turn_choice = gets.chomp.downcase

		if (turn_choice == "guess")
			guess
		elsif (turn_choice == "save")
			save_game
		else
			puts "\nYour input was invalid, let's try again...\n\n"
			make_turn
		end
	end

	def guess
		valid = false
		until valid
			puts "\nTime to guess a letter, which will you pick?"
			letter = gets.chomp.upcase
			# Check for length to ensure we have a single character.
			if letter.length > 1
				puts "\nYou need to guess a single letter, try again.\n"
			# Ensure that our single character is a letter and not otherwise.
			elsif /[a-zA-Z]/.match(letter).nil?
				puts "\nThat's not a valid letter, try again.\n"
			else
				# Check against our used letters and ask for a new letter if it's been repeated.
				not_repeated = true
				@used_letters.each do |c|
					if (letter == c)
						not_repeated = false
						puts "\nYou already used that letter, try a different one!\n"
						break
					end
				end

				if (not_repeated)
					correct = false
					# Check this letter against our word, replacing the correct letters in their respective positions.
					@word.each_with_index do |c, i|
						if (letter == c)
							correct = true
							@word_display[i] = letter
						end
					end
					if (correct)
						@used_letters.push(letter)
					# If the letter is not correct, add it to both the used and missed letters and reduce the guess counter.
					else
						@used_letters.push(letter)
						@misses.push(letter)
						@guesses_remaining -= 1
					end
					valid = true
				end
			end
		end
		puts "\nGuess: #{letter}"
	end

	def save_game
		# Save our game outside of the lib folder.
		File.write("../save.yml", self.to_yaml)
		puts "\nYour game was saved!\n\n"
	end

end

game = Hangman.new
game.program_start