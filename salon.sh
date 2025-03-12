#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n\e[32m~~~~~ SALON ~~~~~\e[0m\n"

MAIN() {
  if [[ $1 ]]
  then
    echo -e "\n\e[33m$1\e[0m\n"
  else  
    echo -e "Welcome, how can I help you?\n"
  fi

  BOOK_SERVICE
}

BOOK_SERVICE() {
  DISPLAY_SERVICES
  
  read USER_SELECTION
  SERVICE_ID_SELECTED=$($PSQL "SELECT service_id FROM services WHERE service_id = $USER_SELECTION")

  if [[ -z $SERVICE_ID_SELECTED ]]
  then
    MAIN "I could not find that service. Here are the list of available services."
  else
    CREATE_APPOINTMENT
  fi
}

DISPLAY_SERVICES() {
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
}

CREATE_APPOINTMENT() {
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  if [[ -z $CUSTOMER_NAME ]] 
  then
    echo -e "\nWhat's your name?"
    read CUSTOMER_NAME
    $($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  fi

  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  echo -e "\nGreeting $CUSTOMER_NAME. Tell us what time you would like for your $SERVICE_NAME:"
  read SERVICE_TIME
  
  $($PSQL "INSERT INTO appointments(customer_id, name, service_id, time) VALUES($CUSTOMER_ID, '$CUSTOMER_NAME', $SERVICE_ID, '$SERVICE_TIME')")

  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}

MAIN