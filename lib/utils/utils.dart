import 'package:call_log/call_log.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import 'chart_data.dart';

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

Future<PermissionStatus> getPermission() async {
  final phoneStatus = await Permission.phone.request();
  final storageStatus = await Permission.storage.request();
  if (phoneStatus == PermissionStatus.granted &&
      storageStatus == PermissionStatus.granted) {
    return PermissionStatus.granted;
  } else {
    return PermissionStatus.denied;
  }
}

List<ChartData> createDurationList(List<ChartData> fetchedLogs) {
  final Map<String, double> durationMap = {};
  for (var data in fetchedLogs) {
    final String phone = data.phone;
    final double duration = data.duration;
    String cleanedPhone = cleanPhoneNumber(phone);

    final double currentDuration = durationMap[cleanedPhone] ?? 0.0;
    durationMap[cleanedPhone] = currentDuration + duration;
  }
  return durationMap.entries
      .map((entry) => ChartData(entry.key, entry.value))
      .toList();
}

String cleanPhoneNumber(String phone) {
  String cleanedPhone = phone;
  if (phone.startsWith("+91")) {
    cleanedPhone = phone.substring(3);
  } else if (phone.startsWith("91") && phone.length == 12) {
    cleanedPhone = phone.substring(2);
  }
  return cleanedPhone;
}
