#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e '\n~~~~~ MY SALON ~~~~~\n'
echo -e 'Welcome to My Salon, how can I help you?\n'

MAIN_MENU() {

  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # get service info
  SERVICE_INFO=$($PSQL "SELECT * FROM services")
  echo "$SERVICE_INFO" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  read SERVICE_ID_SELECTED

  case $SERVICE_ID_SELECTED in
    [1-5])
      # get customer info
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

      # if not found
      if [[ -z $CUSTOMER_NAME ]]
      then
        # get new name
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME
        # insert into customers
        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
      fi

      # ask for time
      echo -e "\nWhat time would you like your cut, $CUSTOMER_NAME?"
      read SERVICE_TIME

      # get customer_id
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      # insert into appointments
      INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

      # get service name
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
      # show appointment info
      echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    ;;
    *)
      MAIN_MENU "I could not find that service. What would you like today?"
    ;;
  esac
}

MAIN_MENU
