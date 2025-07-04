from time import sleep, time
import requests
from dotenv import load_dotenv
from os.path import join, dirname
import os

dotenv_path = join(dirname(__file__), '../.env')
load_dotenv(dotenv_path)

baseUrl = "http://127.0.0.1:3001"
BEARER_TOKEN = os.environ.get("BEARER_TOKEN")


def createUser():
    url = f"{baseUrl}/users"
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
        "Authorization": "Bearer " + BEARER_TOKEN,
    }

    try:
        response = requests.post(url, json=data, headers=headers)
        if response.status_code == 201:
            print("Data sent successfully:", response.json())
            return response.json().get("uid", "")
        else:
            print(
                f"Failed to send data. Status code: {response.status_code}, Response: {response.text}")
    except Exception as e:
        print("An error occurred:", e)


def createPlant(uid, device_id, plant_name):
    url = f"{baseUrl}/plants"
    headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer " + BEARER_TOKEN,
        "Device-ID": device_id,
        "UID": uid,
    }
    data = {
        "plant_name": plant_name
    }

    try:
        response = requests.post(url, json=data, headers=headers)
        if response.status_code == 201:
            print("Data sent successfully:", response.json())
        else:
            print(
                f"Failed to send data. Status code: {response.status_code}, Response: {response.text}")
    except Exception as e:
        print("An error occurred:", e)


def createPlantData(uid, device_id):
    url = f"{baseUrl}/weather"
    headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer " + BEARER_TOKEN,
        "Device-ID": device_id,
        "UID": uid,
    }
    data = {
        "temperature": round(20.0 + (time() % 10), 2),
        "moisture": round(40.0 + (time() % 20), 2),
        "humidity": round(30.0 + (time() % 20), 2),
        "hic": round(20.0 + (time() % 10), 2),
        "batteryVoltage": round(3.5 + (time() % 0.5), 2),
        "batteryPercentage": round(80 + (time() % 20), 2)
    }

    try:
        response = requests.post(url, json=data, headers=headers)

        if response.status_code == 201:
            print("Data sent successfully:", response.json())
        else:
            print(
                f"Failed to send data. Status code: {response.status_code}, Response: {response.text}")
    except Exception as e:
        print("An error occurred:", e)


def getPlantsFromUser(uid):
    url = f"{baseUrl}/users/{uid}/plants"
    headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer " + BEARER_TOKEN,
    }

    try:
        response = requests.get(url, headers=headers)
        if response.status_code == 200:
            print("Data retrieved successfully:", response.json())
        else:
            print(
                f"Failed to retrieve data. Status code: {response.status_code}, Response: {response.text}")
    except Exception as e:
        print("An error occurred:", e)


if __name__ == "__main__":
    uid = "48340ee1afb2fb9b"
    device_id = "F0:9E:9E:20:EF:44"
    plant_name = "Esp32"

    # uid = createUser()
    # sleep(1)
    createPlant(uid, device_id, plant_name)
    # sleep(1)
    # for _ in range(5):
    #     createPlantData(uid, device_id)
    #     sleep(1)
    # getPlantsFromUser(uid)
