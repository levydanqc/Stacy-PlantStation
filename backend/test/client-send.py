from time import sleep, time
import requests

def createUser():
    url = "http://192.168.45.162:3001/users"
    rand_username = "user" + str(int(time()))
    rand_email = "email" + str(int(time())) + "@danlevy.ca"
    rand_pwd = "passwd" + str(int(time()))
    data = {
        "username": rand_username,
        "email": rand_email,
        "password": rand_pwd
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
            "Device-ID" : "02:02:02:02:02",
            "UID" : "bd91244764d4360a",
    }
    data = {
        "plant_name": "aloe"
    }

    try:
        response = requests.post(url, json=data, headers=headers)
        if response.status_code == 200:
            print("Data sent successfully:", response.json())
        else:
            print(f"Failed to send data. Status code: {response.status_code}, Response: {response.text}")
    except Exception as e:
        print("An error occurred:", e)
  
def createPlantData():
    url = "http://127.0.0.1:3001/weather"
    headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer BEARER_TOKEN",
        "Device-ID" : "02:02:02:02:02",
        "UID" : "bd91244764d4360a",
    }
    data = {
        "temperature": round(20.0 + (time() % 10), 2),
        "moisture": round(40.0 + (time() % 20), 2),
        "humidity": round(30.0 + (time() % 20), 2),
        "pressure": round(1000.0 + (time() % 50), 2),
        "hic" : round(20.0 + (time() % 10), 2),
        "batteryVoltage": round(3.5 + (time() % 0.5), 2),
        "batteryPercentage": round(80 + (time() % 20), 2)
    }
    
    try:        
        response = requests.post(url, json=data, headers=headers)

        if response.status_code == 200:
            print("Data sent successfully:", response.json())
        else:
            print(f"Failed to send data. Status code: {response.status_code}, Response: {response.text}")
    except Exception as e:
        print("An error occurred:", e)

def getPlantsFromUser():
    uid = "bd91244764d4360a"
    url = f"http://192.168.45.162:3001/users/{uid}/plants"
    headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer BEARER_TOKEN",
    }

    try:
        response = requests.get(url, headers=headers)
        if response.status_code == 200:
            print("Data retrieved successfully:", response.json())
        else:
            print(f"Failed to retrieve data. Status code: {response.status_code}, Response: {response.text}")
    except Exception as e:
        print("An error occurred:", e)
        

if __name__ == "__main__":
    # createUser()
    # sleep(1)
    # createPlant()
    # sleep(1)
    # createPlantData()
    # sleep(1)
    getPlantsFromUser()