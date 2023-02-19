import 'package:call_log/call_log.dart';
import 'package:call_logger/utils/chart_data.dart';
import 'package:call_logger/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  Future<Iterable<CallLogEntry>>? _callLogEntriesFuture;
  late List<ChartData> _data;
  late TooltipBehavior _tooltip;

  @override
  void initState() {
    _callLogEntriesFuture = fetchCallLogs();
    _data = [];
    _tooltip = TooltipBehavior(enable: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Iterable<CallLogEntry>>(
      future: _callLogEntriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          var fetchedLogs = snapshot.data!
              .map((e) => ChartData(e.number ?? "", e.duration! / 60))
              .toList();
          _data = createDurationList(fetchedLogs);
          _data.sort(
            (a, b) => b.duration.compareTo(a.duration),
          );
          _data = _data.take(10).toList().reversed.toList();
          return Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 50.0),
            child: SfCartesianChart(
              primaryXAxis: CategoryAxis(
                //Hide the gridlines of x-axis
                majorGridLines: const MajorGridLines(width: 0),
                //Hide the axis line of x-axis
                axisLine: const AxisLine(width: 0),
              ),
              primaryYAxis: NumericAxis(
                minimum: 0, maximum: 1000, interval: 100,
                //Hide the gridlines of x-axis
                majorGridLines: const MajorGridLines(width: 0),
                //Hide the axis line of x-axis
                axisLine: const AxisLine(width: 0),
              ),
              tooltipBehavior: _tooltip,
              series: <ChartSeries<ChartData, String>>[
                BarSeries<ChartData, String>(
                  dataSource: _data,
                  xValueMapper: (ChartData data, _) => data.phone,
                  yValueMapper: (ChartData data, _) => data.duration,
                  name: 'call_duration (mins)',
                  color: const Color.fromRGBO(8, 142, 255, 1),
                ),
              ],
              plotAreaBorderWidth: 0,
            ),
          );
        } else {
          return const Center(child: Text('Failed to fetch call logs'));
        }
      },
    );
  }

  Future<Iterable<CallLogEntry>> fetchCallLogs() async {
    final PermissionStatus permissionStatus = await getPermission();
    if (!mounted) return const Iterable.empty();
    if (permissionStatus == PermissionStatus.granted) {
      Iterable<CallLogEntry> fetchedEntries = await CallLog.get();
      return fetchedEntries;
    } else {
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text("Permission Denied"),
          content: Text("You must grant the necessary permissions"),
        ),
      );
    }
    return const Iterable.empty();
  }
}
