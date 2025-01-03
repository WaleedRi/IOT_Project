/*import 'package:flutter/material.dart';
import 'tests_widget.dart'; // Import the TestsWidget file

void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Patient Tests',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100], // Default background color
      ),
      home: const TestsWidget(), // Set TestsWidget as the home screen
    );
  }
}
*/

/*
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('ESP32 Control')),
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              // Replace with your ESP32 IP address
              final url = Uri.parse('http://172.20.10.13/start');
              try {
                final response = await http.get(url);
                if (response.statusCode == 200) {
                  print('Command sent successfully!');
                } else {
                  print('Failed to send command.');
                }
              } catch (e) {
                print('Error: $e');
              }
            },
            child: Text('Start'),
          ),
        ),
      ),
    );
  }
}
*/

/*
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ESP Wi-Fi Setup',
      home: WiFiSetupScreen(),
    );
  }
}

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
        Uri.parse('http://192.168.4.1/setWifi'), // ESP default AP IP
        body: {'ssid': ssid, 'password': password},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Wi-Fi credentials sent successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send Wi-Fi credentials.')),
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: Unable to reach the ESP.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Connect ESP to Wi-Fi')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
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
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                sendWiFiCredentials(
                  _ssidController.text,
                  _passwordController.text,
                );
              },
              child: Text('Connect ESP'),
            ),
          ],
        ),
      ),
    );
  }
}
*/

/*
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ESP32 Test Controller',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: WiFiSetupScreen(),
    );
  }
}

class WiFiSetupScreen extends StatefulWidget {
  @override
  _WiFiSetupScreenState createState() => _WiFiSetupScreenState();
}

class _WiFiSetupScreenState extends State<WiFiSetupScreen> {
  final TextEditingController _ssidController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _espIpController = TextEditingController();

  Future<void> sendWiFiCredentials(String ssid, String password) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.4.1/setWifi'), // ESP AP default IP
        body: {'ssid': ssid, 'password': password},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Wi-Fi credentials sent successfully!')),
        );
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

  Future<void> startTest(String espIp) async {
    try {
      final response = await http.get(Uri.parse('http://$espIp/start'));
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Test started successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start the test.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: Unable to reach the ESP.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ESP32 Wi-Fi & Test Control')),
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
            TextField(
              controller: _espIpController,
              decoration: InputDecoration(labelText: 'ESP32 IP Address'),
            ),
            ElevatedButton(
              onPressed: () {
                startTest(_espIpController.text);
              },
              child: Text('Start Test'),
            ),
          ],
        ),
      ),
    );
  }
}

 */


import 'package:flutter/material.dart';
import 'wifi_setup_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ESP32 Controller',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WiFiSetupScreen(), // Initial screen of the app
    );
  }
}




/*import 'package:flutter/material.dart';
import 'package:multicast_dns/multicast_dns.dart';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ResolveESP32(),
    );
  }
}

class ResolveESP32 extends StatefulWidget {
  @override
  _ResolveESP32State createState() => _ResolveESP32State();
}

class _ResolveESP32State extends State<ResolveESP32> {
  String _ipAddress = "Press the button to resolve ESP32.local";

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Resolve ESP32.local'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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

 */




