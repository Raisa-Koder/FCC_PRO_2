#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Welcom to Salon ~~~~~\n"

echo -e "\nWhat would you like to do today?\n"
SERVICES=$($PSQL "SELECT * FROM services")
MAIN_MENU () {
  # print the argument if present
  if [[ $1 ]]
  then 
    echo -e "\n$1"
  fi
  # print the list of service
  echo "$SERVICES" | while IFS="," read SERVICE_ID SERVICE
  do
    echo "$SERVICE_ID $SERVICE" | sed 's/ |/)/; s/^ *//'
  done
  # select a service
  read SERVICE_ID_SELECTED
  SELECTED_SERVICE=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  # check if the service id is valid
  if [[ -z $SELECTED_SERVICE ]]
  then 
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    # get the customer phone number
    echo -e "\nEnter your phone number please:"
    read CUSTOMER_PHONE

    # get the customer id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    # if the customer id is not present
    if [[ -z $CUSTOMER_ID ]]
    then
      echo -e "\nPlease enter your name:"
      read CUSTOMER_NAME
      # insert the customer info in the customers table
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone,name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    # customer id is present
    else
      # get customer name
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID")
    fi
    # make an appintment
    echo -e "\nWhat time would you like to make the appointment?"
    read SERVICE_TIME
    # insert the appointment
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
    # prent the result
    echo -e "\nI have put you down for a $SELECTED_SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}
MAIN_MENU
