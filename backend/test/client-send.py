import requests

# URL of the server endpoint
url = "http://10.99.110.30:3001/weather"

# Data to send in the POST request
data = {
    "deviceId": "00:1A:2B:3C:4D:5E",
    "temperature": 20.5,
    "moisture": 45.0,
    "humidity": 60.2,
    "pressure": 1013.25,
    "hic" : 21.7,
    "batteryVoltage": 3.7,
    "batteryPercentage": 85,
}

try:
    # Sending POST request
    headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer BEARER_TOKEN",
        "Device-ID": "esp32-1",
    }
    
    response = requests.post(url, json=data, headers=headers)

    # Checking the response
    if response.status_code == 200:
        print("Data sent successfully:", response.json())
    else:
        print(f"Failed to send data. Status code: {response.status_code}, Response: {response.text}")
except Exception as e:
    print("An error occurred:", e)