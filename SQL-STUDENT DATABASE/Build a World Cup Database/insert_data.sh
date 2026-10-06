#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
# Read the CSV one row at a time.
# The comma is used as the separator.
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do

  # Skip the first/header row:
  # year,round,winner,opponent,winner_goals,opponent_goals
  if [[ $YEAR != "year" ]]
  then


    # =======================================
    # WINNER TEAM
    # =======================================

    # Search teams to see if the winner already exists.
    # If it exists, this gives us its team_id.
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")


    # -z means the variable is empty.
    # If WINNER_ID is empty, this team hasn't been inserted yet.
    if [[ -z $WINNER_ID ]]
    then

      # Add the winner to the teams table.
      $PSQL "INSERT INTO teams(name) VALUES('$WINNER')"

    fi


    # =======================================
    # OPPONENT TEAM
    # =======================================

    # Search teams to see if the opponent already exists.
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")


    # If no ID was returned, the opponent doesn't exist yet.
    if [[ -z $OPPONENT_ID ]]
    then

      # Add the opponent to the teams table.
      $PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')"

    fi


    # =======================================
    # GET THE IDs
    # =======================================

    # We query again because one or both teams may have
    # just been inserted above.

    # Get winner's team_id.
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")

    # Get opponent's team_id.
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")


    # =======================================
    # INSERT GAME
    # =======================================

    # Insert the current CSV game.
    #
    # Notice that we DON'T hard-code team IDs.
    # WINNER_ID and OPPONENT_ID came from the teams table.
    $PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)"

  fi

done