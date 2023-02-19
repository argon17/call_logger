import 'dart:io';
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
      home: CallLogsPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CallLogsPage extends StatefulWidget {
  const CallLogsPage({super.key});

  @override
  CallLogsPageState createState() => CallLogsPageState();
}

class CallLogsPageState extends State<CallLogsPage> {
  Future<void> _createCsvFile() async {
    const String csvHeader = "phone_number,duration,call_type,timestamp\n";
    final PermissionStatus permissionStatus = await _getPermission();
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

  Future<PermissionStatus> _getPermission() async {
    final phoneStatus = await Permission.phone.request();
    final storageStatus = await Permission.storage.request();
    if (phoneStatus == PermissionStatus.granted &&
        storageStatus == PermissionStatus.granted) {
      return PermissionStatus.granted;
    } else {
      return PermissionStatus.denied;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: const Color(0xff000000),
            backgroundColor: const Color(0xfff4c095),
          ),
          onPressed: _createCsvFile,
          child: const Text("Export Call Logs"),
        ),
      ),
      backgroundColor: const Color(0xff1d7874),
    );
  }
}
