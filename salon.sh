#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -tA -c"

# Main menu function to display services
MAIN_MENU() {
  echo -e "\n~~~~~ MY SALON ~~~~~\n"
  echo -e "\nWelcome to my salon. How may I help you?"

  # Get the count of services
  serviceCount=$($PSQL "SELECT COUNT(name) FROM services")
  totalServices=$(echo "$serviceCount" | grep -oP '\d+')
  
  # Loop to fetch and display each service name
  for (( i = 1; i <= totalServices; i++ ))
  do
    echo "$i) $(GET_SERVICE $i)"
  done
}

# Function to retrieve service name by service_id
GET_SERVICE() {
  local service_id=$1
  local serviceName=$($PSQL "SELECT name FROM services WHERE service_id = '$service_id'")
  serviceName="${serviceName//name/}"  # Remove 'name'
  serviceName="${serviceName//-/}"     # Remove '-'
  serviceName=$(echo "$serviceName" | grep -oP '\w+$')  # Extract last word
  
  echo "$serviceName"
}

# Function to get customer's preferred appointment time
GET_CUSTOMER_TIME() {
  echo -e "What time would you like your service, $CUSTOMER_NAME?"
  read SERVICE_TIME
  
  # Get customer_id based on CUSTOMER_NAME
  user_customer_id=$($PSQL "SELECT customer_id FROM customers WHERE name='$CUSTOMER_NAME'")
  user_customer_id=$(echo "$user_customer_id" | grep -oP '\d+')
  
  # Insert appointment info into appointments table
  INSERT_APPOINTMENT_INFO=$($PSQL "INSERT INTO appointments(service_id, time, customer_id) VALUES('$SERVICE_ID_SELECTED', '$SERVICE_TIME', $user_customer_id)")
  echo "$INSERT_APPOINTMENT_INFO"
  serviceSelected=$(GET_SERVICE $SERVICE_ID_SELECTED)
  echo "I have put you down for a $serviceSelected at $SERVICE_TIME, $CUSTOMER_NAME."
}

# Main script logic
MAIN_MENU
read SERVICE_ID_SELECTED

# Validate selected service
if [[ -z $(GET_SERVICE $SERVICE_ID_SELECTED) ]]; then
  echo -e "\nI could not find that service. Please choose a valid service number."
    # Get the count of services
  serviceCount=$($PSQL "SELECT COUNT(name) FROM services")
  totalServices=$(echo "$serviceCount" | grep -oP '\d+')
  
  # Loop to fetch and display each service name
  for (( i = 1; i <= totalServices; i++ ))
  do
    echo "$i) $(GET_SERVICE $i)"
  done
fi

# Prompt for customer's phone number
echo -e "\nWhat is your phone number?"
read CUSTOMER_PHONE

# Retrieve customer's name based on phone number
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
CUSTOMER_NAME="${CUSTOMER_NAME//name/}"  # Remove 'name'
CUSTOMER_NAME="${CUSTOMER_NAME//-/}"     # Remove '-'
CUSTOMER_NAME=$(echo "$CUSTOMER_NAME" | grep -oP '\w+$')  # Extract last word

# Check if customer exists in the database
if [[ -z "$CUSTOMER_NAME" ]]; then
  # If customer does not exist, prompt for their name and add to database
  echo -e "\nI don't have a record for that phone number. What's your name?"
  read CUSTOMER_NAME
  INSERT_USER_NAME=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  echo "$INSERT_USER_NAME"

fi

# Get the appointment time from the customer
GET_CUSTOMER_TIME
