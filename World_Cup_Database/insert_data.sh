#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo $($PSQL "TRUNCATE TABLE games, teams")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPP WIN_GOALS OPP_GOALS
do
	if [[ $YEAR != "year" ]]
	then
		#get team_id for winner
		WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
		#if not found
		if [[ -z $WINNER_ID ]]
		then
			#insert and create team_id
			INSERT_WINNER_ID=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
			if [[ $INSERT_WINNER_ID == "INSERT 0 1" ]]
			then
				echo Inserted into teams, winner: $WINNER
			fi
			#get newly create team id
			WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
		fi
		#get team_id for opp
		OPP_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPP'")
		#if not found
		if [[ -z $OPP_ID ]]
		then
			#insert and create team_id
			INSERT_OPP_ID=$($PSQL "INSERT INTO teams(name) VALUES('$OPP')")
			if [[ $INSERT_OPP_ID == "INSERT 0 1" ]]
			then
				echo Inserted into teams, the opp: $OPP
			fi
			#get newly create team id
			OPP_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPP'")
		fi
    INSERT_GAME=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPP_ID, $WIN_GOALS, $OPP_GOALS)")
    if [[ $INSERT_OPP_ID == "INSERT 0 1" ]]
			then
				echo Inserted into games, $YEAR, $ROUND, $WINNER $OPP
		fi 
	fi
done