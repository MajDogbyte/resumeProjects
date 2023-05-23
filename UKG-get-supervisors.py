import sqlite3
import requests
from sqlite3 import Error
from pyminifier import minification

# Constants
API_BASE_URL = 'https://your-ukg-pro-api-url.com'
API_TOKEN = None  # Will be loaded from a secure configuration

# Function to fetch supervisor information for each active employee
def fetch_employee_supervisors():
    # Create a SQLite database connection
    conn = None
    cursor = None
    try:
        conn = sqlite3.connect('employee_data.db')
        cursor = conn.cursor()

        # Create an "employees" table with the required columns
        cursor.execute('''CREATE TABLE IF NOT EXISTS employees (
                          employee_id TEXT PRIMARY KEY,
                          first_name TEXT,
                          last_name TEXT,
                          hire_date TEXT,
                          email TEXT,
                          supervisor TEXT,
                          supervisor_email TEXT
                      )''')

        # Fetch active employee data from UKG Pro API
        response = requests.get(f'{API_BASE_URL}/employees/active', headers={'Authorization': API_TOKEN})
        if response.status_code == 200:
            employee_data = response.json()

            # Iterate over each employee and fetch supervisor information
            for employee in employee_data:
                employee_id = employee['employee_id']
                first_name = employee['first_name']
                last_name = employee['last_name']
                hire_date = employee['hire_date']
                email = employee['email']

                # Fetch supervisor information for the current employee
                supervisor_id = employee['supervisor_id']
                supervisor_data = fetch_employee_data(supervisor_id)

                if supervisor_data:
                    supervisor_name = f"{supervisor_data['first_name']} {supervisor_data['last_name']}"
                    supervisor_email = supervisor_data['email']
                else:
                    supervisor_name = 'N/A'
                    supervisor_email = 'N/A'

                # Insert the employee's data into the database
                cursor.execute("INSERT OR REPLACE INTO employees VALUES (?, ?, ?, ?, ?, ?, ?)",
                               (employee_id, first_name, last_name, hire_date, email, supervisor_name, supervisor_email))

            # Commit changes and close the database connection
            conn.commit()
            print('Data saved successfully!')
        else:
            print('Failed to fetch employee data.')
    except Error as e:
        print(f"Database error: {e}")
    finally:
        # Close the database connection
        if cursor:
            cursor.close()
        if conn:
            conn.close()

# Function to fetch employee data from UKG Pro API
def fetch_employee_data(employee_id):
    response = requests.get(f'{API_BASE_URL}/employees/{employee_id}', headers={'Authorization': API_TOKEN})
    if response.status_code == 200:
        return response.json()
    else:
        return None

# Load API token from secure configuration
try:
    with open('config.txt', 'r') as config_file:
        API_TOKEN = config_file.read().strip()
except FileNotFoundError:
    print("Configuration file not found.")
    exit(1)

# Fetch and save employee supervisors
fetch_employee_supervisors()