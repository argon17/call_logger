import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  Iterable<CallLogEntry> callLogEntries = const Iterable.empty();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchCallLogs();
  }

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
      appBar: AppBar(
        title: const Text("call_logger"),
        backgroundColor: Colors.white24,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () {
              _createCsvFile();
            },
          ),
        ],
      ),
      body: Center(
        child: ListView.builder(
          itemCount: callLogEntries.length,
          itemBuilder: (context, i) {
            return ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 2.0),
              title: Text(
                callLogEntries.elementAt(i).number ?? "",
                style: const TextStyle(color: Colors.white70),
              ),
              subtitle: Text(
                getDateTimeStringFromTimeStamp(
                    callLogEntries.elementAt(i).timestamp),
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
              trailing: Text(
                formatSeconds(callLogEntries.elementAt(i).duration ?? 0),
                style: const TextStyle(color: Colors.white54),
              ),
              leading: Icon(
                getIconDataFromCallType(callLogEntries.elementAt(i).callType),
                color: Colors.white54,
              ),
            );
          },
        ),
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

  void fetchCallLogs() async {
    final PermissionStatus permissionStatus = await _getPermission();
    if (permissionStatus == PermissionStatus.granted) {
      Iterable<CallLogEntry> fetchedEntries = await CallLog.get();
      setState(() {
        callLogEntries = fetchedEntries;
      });
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

IconData getIconDataFromCallType(CallType? callType) {
  String callTypeString = callType.toString();
  IconData iconData = Icons.call;
  if (callTypeString.contains("missed")) {
    iconData = Icons.call_missed;
  } else if (callTypeString.contains("incoming")) {
    iconData = Icons.call_received;
  } else if (callTypeString.contains("outgoing")) {
    iconData = Icons.call_made;
  }
  return iconData;
}

String getDateTimeStringFromTimeStamp(int? timestamp) {
  String dateTimeString = "";
  dateTimeString = DateFormat('yyyy-MM-dd hh:mm:ss')
      .format(DateTime.fromMillisecondsSinceEpoch(timestamp ?? 0));
  return dateTimeString;
}

String formatSeconds(int seconds) {
  Duration duration = Duration(seconds: seconds);
  int hours = duration.inHours;
  int minutes = duration.inMinutes.remainder(60);
  int secs = duration.inSeconds.remainder(60);
  return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
}
