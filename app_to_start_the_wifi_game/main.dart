import 'package:flutter/material.dart';
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