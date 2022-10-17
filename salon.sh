#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"


# Display title

echo -e "\n~~~~~ My Salon ~~~~~"

# Welcome message
echo -e "\nWelcome to My Salon, how can I help you?\n"

# Main Menu
MAIN_MENU() {
  # Echo error message
  if [[ $1 ]]
  then
    
    echo -e "\n~~~ $1 ~~~\n"
  
  fi


  
  #

  echo "$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  
  read SERVICE_ID_SELECTED
  
  # If not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    # Send to main menu
    MAIN_MENU "Please use a number to make a selection."
  
  else 
  S_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  # If not a valid service
    if [[ -z $S_NAME ]]
    then
    # Send to main menu
    MAIN_MENU "Please choose a valid number."
    else
      REGISTRATION
    fi
  fi
}

REGISTRATION() {
  # Get customer details
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  
  # If not in database
  if [[ -z $CUSTOMER_NAME ]]
  then

    # Ask for name
    echo "What's your name?"
    read CUSTOMER_NAME
    # Insert record
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")

  fi
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  # Book time
  echo -e "\nWhat time would you like your $(echo $S_NAME | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')?"
  read SERVICE_TIME

  # Insert into appointments table
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME')")

  # Confirmation message
  echo -e "\nI have put you down for a $(echo $S_NAME | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
}

MAIN_MENU