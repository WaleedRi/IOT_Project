import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:multicast_dns/multicast_dns.dart';
import 'tests_widget.dart';
import 'auth3_login_widget.dart';
import 'patients_progress_widget.dart';
import 'package:connectivity_plus/connectivity_plus.dart';  // Add connectivity package


import 'dart:io';
import 'globals.dart';


class WiFiSetupScreen extends StatefulWidget {
  @override
  _WiFiSetupScreenState createState() => _WiFiSetupScreenState();
}







class _WiFiSetupScreenState extends State<WiFiSetupScreen> {
  final TextEditingController _ssidController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
 // String _ipAddress =  ("connect to ESP_AP:\n 1)    in wifi then send your wifi and password") ;
  String instruction = "To connect to ESP:\n 1) If ESP already connected to a WIFI, connect to same WIFI and then press 'Connect to ESP32'"
      "\n 2) Otherwise, connect to ESP_AP and setup Your Wifi and Password.Then press 'Send Wi-Fi Credentials'   ";
  String _ipAddress = "";
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
  }

  Future<void> sendWiFiCredentials(String ssid, String password) async {
    setState(() {
      _isLoading = true; // Start loading
    });
    try {
      // Send Wi-Fi credentials to ESP32 via its Access Point
      final response = await http.post(
        Uri.parse('http://192.168.4.1/setWifi'), // ESP AP default IP
        body: {'ssid': ssid, 'password': password},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Wi-Fi credentials sent successfully!')),
        );
       // navigateToTestsWidget(ip);
        // Wait a few seconds for ESP32 to connect to the new network
        await Future.delayed(Duration(seconds: 40));
        setState(() {
          _ipAddress= "connect to your wifi, then press below button";
        });

        // Discover ESP32 on the network using mDNS
        _resolveESP32();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send Wi-Fi credentials.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: Unable to reach the ESP.')),
      );
    }finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }

// Function to check Wi-Fi connection status
  Future<bool> checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.wifi ||
        connectivityResult == ConnectivityResult.mobile) {
      return true;
    }
    return false;
  }
// Function to show no Wi-Fi connection dialog
  void _showNoWiFiDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("No Wi-Fi Connection"),
          content: const Text("Please connect to a Wi-Fi network and try again."),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  Future<void> _resolveESP32() async {
    print("Resolved IP");
    setState(() {
      _isLoading = true; // Start loading
    });
    try {
      bool isConnected = await checkInternetConnection();
      if (!isConnected) {
        _showNoWiFiDialog();
        return;
      }

      final String hostname = 'esp32.local';
      final MDnsClient client = MDnsClient();
      await client.start();


      final List<IPAddressResourceRecord> addresses = await client
          .lookup<IPAddressResourceRecord>(
        ResourceRecordQuery.addressIPv4(hostname),
      )
          .toList();
      if (addresses.isNotEmpty) {
        String ip = addresses.first.address.address;
        print("Resolved IP: $ip");
        ESPIP = ip;
        final User? user = FirebaseAuth.instance.currentUser;

        // Check if user is logged in
        if (user != null) {
          UID = user.uid;
          navigateToPatientsProgressWidget();
        } else {
          navigateToLoginWidget();

        }
      }
      setState(() {
        _ipAddress = addresses.isNotEmpty
            ? addresses.map((addr) => addr.address).join(", ")
            : "Connect again to same WIFI and then press 'Connect to ESP32'";
      });

      client.stop();
    } catch (e) {
      setState(() {
        _ipAddress = "Error: $e";
      });
    }finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }

  void navigateToPatientsProgressWidget() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => PatientsProgressWidget()),
          (Route<dynamic> route) => false, // Removes all previous routes
    );
  }
  void navigateToLoginWidget() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Auth3LoginWidget(),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ESP32 Wi-Fi Setup')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              instruction,
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 14),
            ),
            Divider(),
            TextField(
              controller: _ssidController,
              decoration: InputDecoration(labelText: 'Wi-Fi SSID'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Wi-Fi Password'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: () {
                sendWiFiCredentials(
                  _ssidController.text,
                  _passwordController.text,
                );
              },
              child: Text('Send Wi-Fi Credentials'),
            ),
        //   Divider(),
            if (_isLoading) // Show loading indicator when resolving
              CircularProgressIndicator(),
            if (!_isLoading)

          //  SizedBox(height: 20),
      /*      ElevatedButton(
              onPressed: _resolveESP32,
              child: Text('Connect to ESP32'),
            ),*/
            Text(
              _ipAddress,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

/*import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'tests_widget.dart'; // Import your second page

class WiFiSetupScreen extends StatefulWidget {
  @override
  _WiFiSetupScreenState createState() => _WiFiSetupScreenState();
}

class _WiFiSetupScreenState extends State<WiFiSetupScreen> {
  final TextEditingController _ssidController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> sendWiFiCredentials(String ssid, String password) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.4.1/setWifi'), // Use default AP IP
        body: {'ssid': ssid, 'password': password},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Wi-Fi credentials sent successfully!')),
        );

        // Wait for ESP32 to connect to the new network
        await Future.delayed(Duration(seconds: 60));

        // Confirm ESP32 is online using mDNS
        await checkEsp32Online();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send Wi-Fi credentials.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: Unable to reach the ESP.')),
      );
    }
  }

  Future<void> checkEsp32Online() async {
    try {
      final response = await http.get(Uri.parse('http://esp32.local/ping')); // Use mDNS hostname
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ESP32 is online!')),
        );

        // Navigate to the next page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TestsWidget(espIp: 'http://esp32.local'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to reach ESP32 via mDNS.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: Unable to reach ESP32 via mDNS.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ESP32 Wi-Fi Setup')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _ssidController,
              decoration: InputDecoration(labelText: 'Wi-Fi SSID'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Wi-Fi Password'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: () {
                sendWiFiCredentials(
                  _ssidController.text,
                  _passwordController.text,
                );
              },
              child: Text('Send Wi-Fi Credentials'),
            ),
          ],
        ),
      ),
    );
  }
}


 */
