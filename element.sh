#!/bin/bash 

# Function to get element information from the database
get_element_info() {
    element=$1

    if [[ $element =~ ^[0-9]+$ ]]; then
        condition="e.atomic_number = $element"
    else
        condition="e.symbol = '$element' OR e.name ILIKE '$element'"
    fi


    # Query the database for the element using atomic number, symbol, or name
    result=$(psql --username=freecodecamp --dbname=periodic_table -t -c "
    SELECT e.atomic_number, e.symbol, e.name, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius
    FROM elements e
    JOIN properties p ON e.atomic_number = p.atomic_number
    JOIN types t ON p.type_id = t.type_id
    WHERE $condition LIMIT 1;
")

    # Check if the result is empty
    if [ -z "$result" ]; then
        echo "I could not find that element in the database."
    else
        # Extract the values from the query result
        atomic_number=$(echo "$result" | cut -d'|' -f1 | xargs)
        symbol=$(echo "$result" | cut -d'|' -f2 | xargs)
        name=$(echo "$result" | cut -d'|' -f3 | xargs)
        type=$(echo "$result" | cut -d'|' -f4 | xargs)
        atomic_mass=$(echo "$result" | cut -d'|' -f5 | xargs)
        melting_point=$(echo "$result" | cut -d'|' -f6 | xargs)
        boiling_point=$(echo "$result" | cut -d'|' -f7 | xargs)

        # Output the element information in the specified format
        echo "The element with atomic number $atomic_number is $name ($symbol). It's a $type, with a mass of $atomic_mass amu. $name has a melting point of $melting_point celsius and a boiling point of $boiling_point celsius."
    fi
}

# Check if an argument was provided
if [ -z "$1" ]; then
    echo "Please provide an element as an argument."
    exit
fi

# Call the function with the provided argument
get_element_info "$1"
