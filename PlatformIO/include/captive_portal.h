#ifndef CAPTIVE_PORTAL_H
#define CAPTIVE_PORTAL_H

#include <DNSServer.h>
#include <Preferences.h>
#include <WebServer.h>

class CaptivePortal {
public:
  void begin();
  void startMDNS();

private:
  WebServer server;
  Preferences initialModePreferences;
  DNSServer dnsServer;
  void startServer();
  void handleRoot();
  void handleNotFound();
  void handleConnect();
  void handleScan();
  void handleCredentials();
  const char *INDEX_HTML = R"rawliteral(
<!DOCTYPE HTML>
<html>
<head>
  <title>Stacy - Device Setup</title>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style>
    /* Google Font */
    @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600&display=swap');

    /* Reset and Core Styles */
    :root {
      --theme-green: #86A89A;
      --theme-brown: #8d6e63;
      --theme-brown-dark: #795548;
      --bg-color: #eaf0f1;
      --text-gray-500: #6b7280;
      --text-gray-700: #374151;
      --text-gray-800: #1f2937;
      --border-gray-300: #d1d5db;
    }
    *, *::before, *::after { box-sizing: border-box; }
    body, h1, p, input, select, button { margin: 0; font-family: 'Poppins', sans-serif; }

    /* Main Layout */
    body {
      display: flex;
      align-items: center;
      justify-content: center;
      min-height: 100vh;
      background-color: var(--bg-color);
      color: var(--text-gray-700);
    }
    .container {
      width: 100%;
      max-width: 28rem; /* 448px */
      padding: 2rem; /* 32px */
      background-color: rgba(255, 255, 255, 0.7);
      backdrop-filter: blur(4px);
      -webkit-backdrop-filter: blur(4px);
      border-radius: 1.5rem; /* 24px */
      box-shadow: 0 10px 15px -3px rgba(0,0,0,0.1), 0 4px 6px -2px rgba(0,0,0,0.05);
      text-align: center;
    }

    /* Typography and Spacing */
    .title {
      font-size: 1.875rem; /* 30px */
      font-weight: 700;
      color: var(--text-gray-800);
      margin-top: 1rem;
    }
    .subtitle {
      color: var(--text-gray-500);
      margin-top: 0.5rem;
      margin-bottom: 1.5rem;
    }
    .form-content {
      text-align: left;
    }
    .form-content > div:not(:first-child) {
      margin-top: 1rem; /* space-y-4 */
    }
    label {
      display: block;
      font-size: 0.875rem; /* 14px */
      font-weight: 500;
      color: var(--text-gray-700);
      margin-bottom: 0.25rem;
    }

    /* Form Elements */
    input, select {
      width: 100%;
      padding: 0.75rem 1rem;
      border: 1px solid var(--border-gray-300);
      border-radius: 0.5rem;
      background-color: white;
      box-shadow: 0 1px 2px 0 rgba(0,0,0,0.05);
      transition: border-color 0.2s, box-shadow 0.2s;
    }
    input:focus, select:focus {
      outline: none;
      border-color: var(--theme-green);
      box-shadow: 0 0 0 2px rgba(134, 168, 154, 0.4);
    }
    .note {
      font-size: 0.75rem; /* 12px */
      color: var(--text-gray-500);
      margin-top: 0.25rem;
    }
    .submit-btn {
      width: 100%;
      padding: 0.85rem 1rem;
      border: none;
      border-radius: 0.75rem;
      background-color: var(--theme-brown);
      color: white;
      font-weight: 500;
      cursor: pointer;
      transition: background-color 0.3s;
      margin-top: 1.5rem;
    }
    .submit-btn:hover {
      background-color: var(--theme-brown-dark);
    }
    .hidden {
      display: none;
    }

    /* SVG and Spinners */
    .plant-svg {
      height: 6rem; /* 96px */
      width: 6rem;
      color: var(--text-gray-700);
      margin: 0 auto;
    }
    .loader-container {
        display: flex;
        align-items: center;
        margin-top: 0.25rem;
        font-size: 0.875rem;
        color: var(--text-gray-500);
    }
    .loader-small {
        width: 16px;
        height: 16px;
        border: 2px solid #f3f3f3;
        border-top: 2px solid var(--theme-green);
        border-radius: 50%;
        animation: spin 1s linear infinite;
        margin-right: 8px;
    }
    .loader-large {
      margin: 0 auto;
      border: 4px solid #f3f3f3;
      border-top: 4px solid var(--theme-green);
      border-radius: 50%;
      width: 40px;
      height: 40px;
      animation: spin 1s linear infinite;
    }
    @keyframes spin {
      0% { transform: rotate(0deg); }
      100% { transform: rotate(360deg); }
    }

    /* Status Messages */
    .status-message {
        display: none;
        padding: 1rem;
        margin-top: 1.5rem;
        border-radius: 0.5rem;
        text-align: center;
    }
    .status-success { background-color: #d1fae5; color: #065f46; }
    .status-error { background-color: #fee2e2; color: #991b1b; }
  </style>
</head>
<body>

  <div class="container">
    
    <svg class="plant-svg" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor">
        <path d="M17.61,4.2C17.61,4.2,16.46,2,14,2h-1c-2.76,0-5,2.24-5,5c0,1.1,0.9,2,2,2h1.59c-0.23,0.39-0.41,0.82-0.53,1.28 C7.53,10.93,5.3,13.92,5.03,17.47C4.99,18.01,5.43,18.5,6,18.5c0.55,0,1-0.45,1-1c0.07-2.07,1.24-3.95,3-5.23 c0.01,0,0.01,0,0.02,0c0.16-0.12,0.3-0.25,0.43-0.39c-0.64,1.35-0.95,2.83-0.95,4.32c0,3.31,2.69,6,6,6s6-2.69,6-6 C21.5,12.2,19.89,8.73,17.61,4.2z M19.5,16.2c0,2.21-1.79,4-4,4s-4-1.79-4-4c0-0.93,0.32-1.78,0.84-2.48 c1.23,1.06,2.79,1.78,4.53,1.92c-0.16,0.51-0.26,1.04-0.26,1.58c0,0.55,0.45,1,1,1s1-0.45,1-1c0-0.01,0-0.02,0-0.03 c0.01-0.16,0.03-0.32,0.05-0.47C18.89,14.81,19.5,15.45,19.5,16.2z"/>
    </svg>

    <h1 class="title">Welcome to Stacy</h1>
    <p class="subtitle">First, let's connect your device to the internet.</p>
    
    <form id="setupForm">
      <div class="form-content">
        <div>
          <label for="plant_name">Plant name</label>
          <input type="text" id="plant_name" name="plant_name" required>
        </div>
        
        <div>
          <label for="ssid">Select Wi-Fi Network</label>
          <div id="loadingNetworks" class="loader-container">
              <div class="loader-small"></div>
              <span>Scanning...</span>
          </div>
          <select id="ssid" name="ssid" class="hidden"></select>
        </div>
        <div>
          <label for="wifi_password">Wi-Fi Password</label>
          <input type="password" id="wifi_password" name="wifi_password">
          <p class="note">Leave blank if the network is open.</p>
        </div>

        <button type="submit" class="submit-btn">Connect</button>
      </div>
    </form>
    
    <div id="loadingSpinner" class="hidden loader-large"></div>
    <div id="statusMessage" class="status-message"></div>

  </div>

  <script>
    document.addEventListener('DOMContentLoaded', () => {
      const form = document.getElementById('setupForm');
      const ssidSelect = document.getElementById('ssid');
      const loadingNetworks = document.getElementById('loadingNetworks');
      const statusMessage = document.getElementById('statusMessage');
      const loadingSpinner = document.getElementById('loadingSpinner');

      function fetchWifiNetworks() {
        fetch('/scan')
          .then(response => {
            if (!response.ok) throw new Error('Network scan failed');
            return response.json();
          })
          .then(networks => {
            loadingNetworks.style.display = 'none';
            if (networks && networks.length > 0) {
              ssidSelect.innerHTML = '<option value="" disabled selected>Select your network</option>';
              networks.forEach(network => {
                const option = document.createElement('option');
                option.value = network;
                option.textContent = network;
                ssidSelect.appendChild(option);
              });
              ssidSelect.classList.remove('hidden');
            } else {
              loadingNetworks.innerHTML = 'No networks found. Please refresh.';
              loadingNetworks.style.display = 'flex';
            }
          })
          .catch(error => {
            console.error('Error fetching Wi-Fi networks:', error);
            loadingNetworks.innerHTML = 'Could not scan. Please <a href="/" style="text-decoration: underline;">refresh</a>.';
            loadingNetworks.style.display = 'flex';
          });
      }

      form.addEventListener('submit', (event) => {
        event.preventDefault();
        statusMessage.style.display = 'none';
        loadingSpinner.classList.remove('hidden');
        
        const data = {
          ssid: document.getElementById('ssid').value,
          wifi_password: document.getElementById('wifi_password').value,
          plant_name: document.getElementById('plant_name').value
        };

        fetch('/connect', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(data),
        })
          // then close the captive portal
          .then(response => {
            loadingSpinner.classList.add('hidden');
            if (!response.ok) throw new Error('Connection failed');
            return response.json();
          })
          .then(result => {
            if (result.success) {
              statusMessage.className = 'status-message status-success';
              statusMessage.textContent = 'Device connected successfully! Restarting...';
              statusMessage.style.display = 'block';
              setTimeout(() => {
                window.location.href = '/'; // Redirect to the root to close the captive portal
              }, 2000);
            } else {
              statusMessage.className = 'status-message status-error';
              statusMessage.textContent = result.error || 'Failed to connect. Please try again.';
              statusMessage.style.display = 'block';
            }
          })
          .catch(error => {
            loadingSpinner.classList.add('hidden');
            console.error('Error during connection:', error);
            statusMessage.className = 'status-message status-error';
            statusMessage.textContent = 'Connection failed: ' + error.message;
            statusMessage.style.display = 'block';
          });
      });

      fetchWifiNetworks();
    });
  </script>

</body>
</html>
)rawliteral";
};

#endif // CAPTIVE_PORTAL_H