#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

INPUT="$1"

if [[ -z "$INPUT" ]] 
then
  echo "Please provide an element as an argument."
fi

GET_DATA() {
	if [[ $INPUT =~ ^[0-9]+$ ]]
	then
    ELEMENT_IN_DB=$($PSQL "SELECT elements.atomic_number, symbol, name, melting_point_celsius, boiling_point_celsius, types.type, atomic_mass FROM elements JOIN properties ON elements.atomic_number = properties.atomic_number JOIN types ON properties.type_id = types.type_id WHERE elements.atomic_number = $INPUT;")
    if [[ -z $ELEMENT_IN_DB ]]
    then
      echo "I could not find that element in the database."
    else
      IFS='|' read -r ATOMIC_NUMBER SYMBOL NAME MELTING_POINT BOILING_POINT TYPE ATOMIC_MASS <<< "$ELEMENT_IN_DB"
      echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
    fi
  else
  if [[ $INPUT =~ ^[A-Za-z]+$ ]]
  then
    ELEMENT_IN_DB=$($PSQL "SELECT elements.atomic_number, symbol, name, melting_point_celsius, boiling_point_celsius, types.type, atomic_mass FROM elements JOIN properties ON elements.atomic_number = properties.atomic_number JOIN types ON properties.type_id = types.type_id WHERE symbol = '$INPUT';")
    if [[ -z $ELEMENT_IN_DB ]]
    then
      ELEMENT_IN_DB=$($PSQL "SELECT elements.atomic_number, symbol, name, melting_point_celsius, boiling_point_celsius, types.type, atomic_mass FROM elements JOIN properties ON elements.atomic_number = properties.atomic_number JOIN types ON properties.type_id = types.type_id WHERE name = '$INPUT';")
      if [[ -z $ELEMENT_IN_DB ]]
      then
        echo "I could not find that element in the database."
      else
        IFS='|' read -r ATOMIC_NUMBER SYMBOL NAME MELTING_POINT BOILING_POINT TYPE ATOMIC_MASS <<< "$ELEMENT_IN_DB"
        echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
      fi
    else
      IFS='|' read -r ATOMIC_NUMBER SYMBOL NAME MELTING_POINT BOILING_POINT TYPE ATOMIC_MASS <<< "$ELEMENT_IN_DB"
      echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
      fi
    fi
	fi
}

GET_DATA
