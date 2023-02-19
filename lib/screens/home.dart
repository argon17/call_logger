import 'package:call_log/call_log.dart';
import 'package:call_logger/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Iterable<CallLogEntry> callLogEntries = const Iterable.empty();
  @override
  void initState() {
    fetchCallLogs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
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
    );
  }

  void fetchCallLogs() async {
    final PermissionStatus permissionStatus = await getPermission();
    if (!mounted) return;
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
