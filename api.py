from flask import Flask, jsonify, request
from datetime import datetime
from dotenv import load_dotenv
import requests
import os

app = Flask(__name__)

load_dotenv()
API_KEY = os.getenv("OPENWEATHER_API_KEY")

# e.g /weather?city=Lagos
@app.route('/weather', methods=['GET'])
def fetch_weather():
        # Extract query params
        city = request.args.get('city', 'Manchester')  # Default to "Manchester" if not provided

        """Fetch weather data from OpenWeather API"""
        base_url = "https://api.openweathermap.org/data/2.5/weather"
        params = {
            "q": city,
            "appid": API_KEY,
            "units": "imperial"
        }
        
        try:
            response = requests.get(base_url, params=params)
            response.raise_for_status()
            data = response.json()

            weather = data.get("weather", [{}])[0].get("description", "N/A")
            temp = data.get("main", {}).get("temp", "N/A")
            humidity = data.get("main", {}).get("humidity", "N/A")
            wind_speed = data.get("wind", {}).get("speed", "N/A")
            today = datetime.now().strftime('%d-%m-%Y, %H:%M')

            return jsonify({
                "message": f"Fetched weather stats successfully for {city}", 
                "stats": {
                    "summary": weather,
                    "temperature": f"{temp}°F",
                    "humidity": f"{humidity}%",
                    "wind_speed": f"{wind_speed} mph",
                    "today": today
                }}), 200
        
        except Exception as e:
            return jsonify({
                "message": f"Could not fetch weather data for {city}",
                "error": str(e).split(": https")[0].strip()
                }), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)