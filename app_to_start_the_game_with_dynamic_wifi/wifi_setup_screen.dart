import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:multicast_dns/multicast_dns.dart';
import 'tests_widget.dart';
import 'dart:io';


class WiFiSetupScreen extends StatefulWidget {
  @override
  _WiFiSetupScreenState createState() => _WiFiSetupScreenState();
}







class _WiFiSetupScreenState extends State<WiFiSetupScreen> {
  final TextEditingController _ssidController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _ipAddress = "Press the button to resolve ESP32.local";

  @override
  void initState() {
    super.initState();
  }

  Future<void> sendWiFiCredentials(String ssid, String password) async {
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

        // Wait a few seconds for ESP32 to connect to the new network
       // await Future.delayed(Duration(seconds: 40));

        // Discover ESP32 on the network using mDNS
       // _resolveESP32();
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


  Future<void> _resolveESP32() async {
    try {
      final String hostname = 'esp32.local';
      final MDnsClient client = MDnsClient();
      await client.start();

      final List<IPAddressResourceRecord> addresses = await client
          .lookup<IPAddressResourceRecord>(
        ResourceRecordQuery.addressIPv4(hostname),
      )
          .toList();
      if (addresses.isNotEmpty){
        String ip =  addresses.first.address.address;
        print("Resolved IP: $ip");
        navigateToTestsWidget(ip);
      }

      setState(() {
        _ipAddress = addresses.isNotEmpty
            ? addresses.map((addr) => addr.address).join(", ")
            : "No IP found for $hostname";
      });

      client.stop();
    } catch (e) {
      setState(() {
        _ipAddress = "Error: $e";
      });
    }
  }


  void navigateToTestsWidget(String espIp) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TestsWidget(espIp: espIp),
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
            Divider(),
            Text(
              _ipAddress,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _resolveESP32,
              child: Text('Resolve ESP32.local'),
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
