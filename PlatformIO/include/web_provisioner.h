// This should be the web server header file to wait for requests
// with Wi-Fi credentials and user information.
// This is not a captive portal, but a simple web server that listens for POST
// requests to receive the Wi-Fi credentials and user information. It is used in
// the initial mode of the device, when no Wi-Fi credentials are stored

#ifndef WEB_PROVISIONER_H
#define WEB_PROVISIONER_H

#include <Preferences.h>
#include <WebServer.h>

class WebProvisioner {
public:
  WebProvisioner(const char *apSSID);
  void begin();

private:
  const char *_apSSID;
  WebServer _server;
  Preferences _preferences;

  void startAccessPoint();
  void setupRoutes();
  void handleRoot();
  void handleSetWiFi();
};

#endif // WEB_PROVISIONER_H
