import asyncio
import websockets
    
async def receive_data():
    uri = "ws://localhost:3001"
    async with websockets.connect(uri) as websocket:
        print(f"Connected to {uri}")
        
        await websocket.send('{"clientId": "Flutter-Client"}')
        print("Client ID sent to server.")
        try:
            async for message in websocket:
                print(f"Received: {message}")
        except websockets.ConnectionClosedError:
            print("Connection closed by the server.")
        except Exception as e:
            print(f"An error occurred: {e}")

if __name__ == "__main__":
    asyncio.run(receive_data())