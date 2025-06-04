#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

GUESS_GAME() {
  echo "Enter your username:"
  read USERNAME
  USER_IN_DB=$($PSQL "SELECT username, games_played, best_game FROM users WHERE username = '$USERNAME'")
  if [[ -z $USER_IN_DB ]]
  then
    echo "Welcome, $USERNAME! It looks like this is your first time here."
    # create user
    INSERT_NEW_USER=$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME', 0, 9999)")
    # get user info
    USER_IN_DB=$($PSQL "SELECT games_played, best_game FROM users WHERE username = '$USERNAME'")
    IFS='|' read -r GAMES_PLAYED BEST_GAME <<< "$USER_IN_DB"
  else
    # get user info
    USER_IN_DB=$($PSQL "SELECT games_played, best_game FROM users WHERE username = '$USERNAME'")
    IFS='|' read -r GAMES_PLAYED BEST_GAME <<< "$USER_IN_DB"
    # display returning user welcome
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  fi
  # generate random number and save to variable
  SECRET_NUMBER=$((1 + $RANDOM % 1000))
  NUMBER_OF_GUESSES=1
  echo Guess the secret number between 1 and 1000:
  read GUESS
  while [[ $GUESS -ne $SECRET_NUMBER ]]
  do
    if [[ ! $GUESS =~ ^[0-9]+$ ]]
    then
      echo "That is not an integer, guess again:"
      read GUESS
    else
      if [[ $GUESS -lt $SECRET_NUMBER ]]
      then
        echo "It's higher than that, guess again:"
        read GUESS
      elif [[ $GUESS -gt $SECRET_NUMBER ]]
      then
        echo "It's lower than that, guess again:"
        read GUESS
      fi
    fi
    ((NUMBER_OF_GUESSES++))
  done

  # add 1 to $GAMES_PLAYED
  INSERT_NEWEST_GAME=$($PSQL "UPDATE users SET games_played = games_played + 1 WHERE username = '$USERNAME'")
  # if $NUMBER_OF_GUESSES < $BEST_GAME, update the value
  if [[ -z $NUMBER_OF_GUESSES || $NUMBER_OF_GUESSES -lt $BEST_GAME ]]
  then
    INSERT_HIGH_SCORE=$($PSQL "UPDATE users SET best_game = $NUMBER_OF_GUESSES WHERE username = '$USERNAME'")
  fi
  echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
}

GUESS_GAME