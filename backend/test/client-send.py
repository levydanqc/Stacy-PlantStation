from time import sleep
import requests

def createUser():
    url = "http://127.0.0.1:3001/users"
    data = {
        "username": "levydanqc",
        "email": "email@danlevy.ca",
        "password_hash": "passwd"
    }
    headers = {
            "Content-Type": "application/json",
            "Authorization": "Bearer BEARER_TOKEN",
    }

    try:
        response = requests.post(url, json=data, headers=headers)
        if response.status_code == 200:
            print("Data sent successfully:", response.json())
        else:
            print(f"Failed to send data. Status code: {response.status_code}, Response: {response.text}")
    except Exception as e:
        print("An error occurred:", e)

def createPlant():
    url = "http://127.0.0.1:3001/plants"
    headers = {
            "Content-Type": "application/json",
            "Authorization": "Bearer BEARER_TOKEN",
            "Device-ID" : "01:01:01:01:01",
            "User-ID" : "1"
    }
    data = {
        "plant_name": "mint"
    }

    try:
        response = requests.post(url, json=data, headers=headers)
        if response.status_code == 200:
            print("Data sent successfully:", response.json())
        else:
            print(f"Failed to send data. Status code: {response.status_code}, Response: {response.text}")
    except Exception as e:
        print("An error occurred:", e)
  
def createSensorData():
    url = "http://127.0.0.1:3001/weather"
    headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer BEARER_TOKEN",
        "Device-ID" : "01:01:01:01:01",
        "User-ID" : "1"
    }
    data = {
        "temperature": 20.5,
        "moisture": 45.0,
        "humidity": 60.2,
        "pressure": 1013.25,
        "hic" : 21.7,
        "batteryVoltage": 3.7,
        "batteryPercentage": 85,
    }
    
    try:        
        response = requests.post(url, json=data, headers=headers)

        if response.status_code == 200:
            print("Data sent successfully:", response.json())
        else:
            print(f"Failed to send data. Status code: {response.status_code}, Response: {response.text}")
    except Exception as e:
        print("An error occurred:", e)
  

if __name__ == "__main__":
    # createUser()
    # sleep(1)
    # createPlant()
    # sleep(1)
    createSensorData()