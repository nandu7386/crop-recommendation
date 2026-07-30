# SmartAgri

SmartAgri is a full-stack crop recommendation project built with FastAPI, React, and an ESP8266-based IoT flow. It accepts environmental readings, stores them in SQLite, runs a crop prediction pipeline, and shows the latest results in a live dashboard.

## Project Structure

```text
agri/
+-- backend/
�   +-- main.py
�   +-- ml_pipeline.py
�   +-- models.py
�   +-- schemas.py
�   +-- database.py
�   +-- auth.py
�   +-- requirements.txt
+-- frontend/
�   +-- src/
�   +-- package.json
�   +-- vite.config.js
+-- iot/
�   +-- nodemcu_code.ino
+-- cleaned_dataset.csv
+-- model.joblib
+-- scaler.joblib
+-- README.md
```

## Stack

- Backend: FastAPI, SQLAlchemy, SQLite
- Frontend: React, Vite, Tailwind CSS, Recharts
- ML: scikit-learn Random Forest
- IoT: ESP8266 / NodeMCU, DHT11, HC-SR04

## Features

- User signup and login
- Sensor data ingestion through REST APIs
- Automatic crop prediction after sensor submission
- Recent sensor and prediction history
- Live dashboard polling for near real-time updates
- Manual prediction input from the dashboard

## Requirements

- Python 3.10 or newer
- Node.js 18 or newer
- npm
- Arduino IDE for ESP8266 programming

## Backend Setup

From the project root:

```powershell
cd "c:\Web Develop\agri"
python -m venv .venv
.venv\Scripts\activate
pip install -r backend\requirements.txt
```

Start the backend:

```powershell
cd backend
..\.venv\Scripts\python -m uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

Notes:

- `--host 0.0.0.0` lets devices on the same Wi-Fi network, including the ESP8266, reach the API.
- The backend creates the SQLite database automatically.
- If `model.joblib` and `scaler.joblib` are missing, the ML pipeline trains a model from `cleaned_dataset.csv`.

API docs:

```text
http://localhost:8000/docs
```

## Frontend Setup

In a separate terminal:

```powershell
cd "c:\Web Develop\agri\frontend"
npm install
npm run dev
```

Open:

```text
http://localhost:5173
```

## IoT Setup

Open `iot/nodemcu_code.ino` in Arduino IDE and update:

- `ssid`
- `password`
- `serverName`
- `TANK_HEIGHT_CM`

Example:

```cpp
const char* ssid = "Your_WiFi_Name";
const char* password = "Your_WiFi_Password";
const char* serverName = "http://192.168.1.2:8000/sensor-data";
const float TANK_HEIGHT_CM = 30.0;
```

### Current Hardware Assumptions

The sketch is currently written for:

- DHT11 temperature and humidity sensor
- HC-SR04 ultrasonic sensor for water level

Important notes:

- The current code does not require a real soil moisture sensor.
- If no soil moisture hardware is connected, a placeholder value can be sent to the backend.
- Use a voltage divider on the HC-SR04 `ECHO` pin before connecting it to the ESP8266.

### Water Level Calculation

The ultrasonic sensor measures the distance from the sensor to the water surface.

The sketch computes:

```text
water level = tank height - measured distance
```

The result is then converted into the `water_availability` value sent to the backend.

## Main API Endpoints

Authentication:

- `POST /signup`
- `POST /login`
- `POST /verify-otp`

Sensor and dashboard:

- `POST /sensor-data`
- `POST /predict`
- `GET /dashboard-data`
- `GET /latest-data`

Current auth note:

- The current local signup flow marks users as verified immediately, so OTP is not required for regular local testing.

## Example Requests

### Signup

`POST /signup`

```json
{
  "email": "farmer@example.com",
  "password": "strongpassword123",
  "confirm_password": "strongpassword123"
}
```

### Login

`POST /login`

```json
{
  "email": "farmer@example.com",
  "password": "strongpassword123"
}
```

### Send Sensor Data

`POST /sensor-data`

```json
{
  "temperature": 26.5,
  "humidity": 75.0,
  "soil_moisture": 45.0,
  "water_availability": 110.0,
  "ph": 6.8
}
```

### Manual Prediction

`POST /predict`

```json
{
  "temperature": 26.5,
  "humidity": 75.0,
  "soil_moisture": 45.0,
  "water_availability": 110.0,
  "ph": 6.8
}
```

## ML Notes

The current model was trained on agricultural features such as:

- N
- P
- K
- pH
- rainfall
- water per season

The live hardware currently provides fewer direct measurements than the training dataset expects. Because of that, the backend maps available sensor values into model inputs and uses fallback values for missing features.

This means:

- predictions are suitable for a prototype/demo
- repeated predictions can happen when inputs do not vary much
- low confidence values are normal when sensor coverage is incomplete

## Local Files Generated During Development

Common generated files and folders:

- `backend/agri.db`
- `model.joblib`
- `scaler.joblib`
- `frontend/node_modules/`
- `frontend/dist/`
- `.venv/`

Most of these are ignored by the root `.gitignore`.

## Troubleshooting

### ESP8266 shows `HTTP POST failed: connection failed`

Check:

- the backend is running
- the backend was started with `--host 0.0.0.0`
- `serverName` uses your PC's LAN IP address, not `localhost`
- the ESP8266 and your computer are on the same Wi-Fi network
- Windows Firewall allows traffic on port `8000`

### Dashboard does not update until refresh

Check:

- the backend is receiving new `POST /sensor-data` requests
- `GET /latest-data` is returning fresh values
- both frontend and backend are running

### The same crop appears repeatedly

This usually happens when:

- sensor inputs do not change much
- some ML features are fixed fallback values
- incomplete hardware data is being mapped to a richer training dataset

## Useful Commands

Backend:

```powershell
cd "c:\Web Develop\agri\backend"
..\.venv\Scripts\python -m uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

Frontend:

```powershell
cd "c:\Web Develop\agri\frontend"
npm install
npm run dev
```

Production frontend build:

```powershell
cd "c:\Web Develop\agri\frontend"
npm run build
```

## Suggested Next Improvements

- add real soil moisture sensing
- retrain the model around the sensors actually available in hardware
- return top 3 crop recommendations instead of only one
- move API base URLs into environment variables
- add production deployment instructions when the stack is finalized
