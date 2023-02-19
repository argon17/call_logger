// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:call_logger/screens/home.dart';
import 'package:call_logger/screens/stats.dart';
import 'package:call_logger/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:call_log/call_log.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: AppPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AppPage extends StatefulWidget {
  const AppPage({super.key});

  @override
  AppPageState createState() => AppPageState();
}

class AppPageState extends State<AppPage> {
  Iterable<CallLogEntry> callLogEntries = const Iterable.empty();
  int _currentIndex = 0;

  static const List<Widget> _widgetOptions = [
    HomePage(),
    StatsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("call_logger"),
        backgroundColor: Colors.white24,
        actions: _currentIndex == 0
            ? <Widget>[
                IconButton(
                  icon: const Icon(Icons.file_download),
                  onPressed: () {
                    _createCsvFile();
                  },
                ),
              ]
            : null,
      ),
      body: Center(
        child: _widgetOptions[_currentIndex],
      ),
      backgroundColor: const Color.fromARGB(255, 53, 61, 82),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white10,
        currentIndex: _currentIndex,
        selectedFontSize: 0,
        onTap: (int newIndex) {
          setState(() {
            _currentIndex = newIndex;
          });
        },
        items: const [
          BottomNavigationBarItem(
            label: 'Home',
            icon: Icon(Icons.home),
          ),
          BottomNavigationBarItem(
            label: 'Stats',
            icon: Icon(Icons.insights),
          )
        ],
      ),
    );
  }

  Future<void> _createCsvFile() async {
    const String csvHeader = "phone_number,duration,call_type,timestamp\n";
    final PermissionStatus permissionStatus = await getPermission();
    if (!mounted) return;
    if (permissionStatus == PermissionStatus.granted) {
      var directory = await Directory('/storage/emulated/0/Download/CallLogger')
          .create(recursive: true);
      final File csvFile = File('${directory.path}/call_logs.csv');
      if (kDebugMode) {
        print(csvFile.path);
      }
      String csvContent = csvHeader;
      Iterable<CallLogEntry> entries = await CallLog.get();
      for (var call in entries) {
        csvContent +=
            "${call.number},${call.duration},${call.callType.toString()},${call.timestamp}\n";
      }
      // Write the CSV content to the file
      await csvFile.writeAsString(csvContent);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: const Color(0xfff4c095),
          title: const Text("Success"),
          content: Text("Call logs exported to ${csvFile.path}"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'Cancel'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xff071e22),
              ),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'OK'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xff071e22),
              ),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text("Permission Denied"),
          content: Text("You must grant the necessary permissions"),
        ),
      );
    }
  }
}
