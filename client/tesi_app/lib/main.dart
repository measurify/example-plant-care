// ignore_for_file: unnecessary_breaks

import 'dart:convert';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as https;
import 'package:syncfusion_flutter_charts/charts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'PlantCare App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green.shade800),
          useMaterial3: false,
        ),
        home: const MyHomePage(title: 'PlantCare App'),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeratorHomePage();
        break;
      case 1:
        page = ChartPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: Container(
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: page,
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.stacked_line_chart_sharp),
              label: 'Chart',
            ),
          ],
          currentIndex: selectedIndex,
          onTap: (int index) {
            setState(() {
              selectedIndex = index;
            });
          },
        ),
      );
    });
  }
}

class GeratorHomePage extends StatefulWidget {
  @override
  State<GeratorHomePage> createState() => _GeratorHomePageState();
}

class _GeratorHomePageState extends State<GeratorHomePage> {
  final String authToken =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJkZXZpY2UiOnsiZmVhdHVyZXMiOlsibW9uaXRvcmluZyJdLCJ0aGluZ3MiOlsidmluZTEiXSwidmlzaWJpbGl0eSI6InB1YmxpYyIsInBlcmlvZCI6IjVzIiwiY3ljbGUiOiIxMG0iLCJyZXRyeVRpbWUiOiIxMHMiLCJfaWQiOiJlZGdlLXZpbmUxIiwib3duZXIiOiI2NThkZDI5NmUzZjQzNDAwMzE1MTQwOTUifSwidGVuYW50Ijp7InBhc3N3b3JkaGFzaCI6dHJ1ZSwiX2lkIjoiUGxhbnQtVGVuYW50Iiwib3JnYW5pemF0aW9uIjoiTWVhc3VyaWZ5IG9yZyIsImFkZHJlc3MiOiJNZWFzdXJpZnkgU3RyZWV0LCBHZW5vdmEiLCJlbWFpbCI6ImluZm9AbWVhc3VyaWZ5Lm9yZyIsInBob25lIjoiKzM5MTAzMjE4NzkzODE3IiwiZGF0YWJhc2UiOiJQbGFudC1UZW5hbnQifSwiaWF0IjoxNzAzNzkzODAxLCJleHAiOjMzMjYxMzkzODAxfQ.oyHKERZanvmHalvWGUH-B606oOZXUkqiPO5CvLCflgU';

  List<dynamic> val = [0, 0, 0, 0];

  Future<void> fetchData() async {
    final response = await https.get(
      Uri.parse(
        'https://students.measurify.org/v1/measurements/mesuremets-vine1/timeserie?limit=1',
      ),
      headers: {
        'Authorization': 'DVC $authToken',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> docs = data['docs'];
      for (var doc in docs) {
        final List<dynamic> values = doc['values'];
        if (values.isNotEmpty) {
          for (int i = 0; i < 4; i++) {
            val[i] = values[i];
          }
        }
      }
      setState(() {}); // Aggiorna lo stato per riflettere i nuovi dati
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Umidità del suolo: ${val[0]} %',
            style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
                color: Colors.green[800]),
          ),
          SizedBox(height: 20),
          Text(
            "Umidità dell'aria: ${val[1].toStringAsFixed(2)} %",
            style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
                color: Colors.green[800]),
          ),
          SizedBox(height: 20),
          Text(
            'Temperatura: ${val[2].toStringAsFixed(2)} C°',
            style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
                color: Colors.green[800]),
          ),
          SizedBox(height: 20),
          Text(
            'Luminosità: ${val[3].toStringAsFixed(2)} Lux',
            style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
                color: Colors.green[800]),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: fetchData,
            child: Text(
              'Aggiorna',
              style: TextStyle(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class ChartPage extends StatefulWidget {
  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  List<_ChartData>? chartData1;
  List<_ChartData>? chartData2;
  List<_ChartData>? chartData3;
  List<_ChartData>? chartData4;


  final String authToken =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJkZXZpY2UiOnsiZmVhdHVyZXMiOlsibW9uaXRvcmluZyJdLCJ0aGluZ3MiOlsidmluZTEiXSwidmlzaWJpbGl0eSI6InB1YmxpYyIsInBlcmlvZCI6IjVzIiwiY3ljbGUiOiIxMG0iLCJyZXRyeVRpbWUiOiIxMHMiLCJfaWQiOiJlZGdlLXZpbmUxIiwib3duZXIiOiI2NThkZDI5NmUzZjQzNDAwMzE1MTQwOTUifSwidGVuYW50Ijp7InBhc3N3b3JkaGFzaCI6dHJ1ZSwiX2lkIjoiUGxhbnQtVGVuYW50Iiwib3JnYW5pemF0aW9uIjoiTWVhc3VyaWZ5IG9yZyIsImFkZHJlc3MiOiJNZWFzdXJpZnkgU3RyZWV0LCBHZW5vdmEiLCJlbWFpbCI6ImluZm9AbWVhc3VyaWZ5Lm9yZyIsInBob25lIjoiKzM5MTAzMjE4NzkzODE3IiwiZGF0YWJhc2UiOiJQbGFudC1UZW5hbnQifSwiaWF0IjoxNzAzNzkzODAxLCJleHAiOjMzMjYxMzkzODAxfQ.oyHKERZanvmHalvWGUH-B606oOZXUkqiPO5CvLCflgU';

  /* Future<void> fetchData1() async {
    final response = await https.get(
      Uri.parse(
        'https://students.measurify.org/v1/measurements/mesuremets-vine1/timeserie?limit=1',
      ),
      headers: {
        'Authorization': 'DVC $authToken',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> docs = data['docs'];
      for (var doc in docs) {
        final List<dynamic> values1 = doc['values'];
        String timestamp1 = doc['timestamp'];
        if (values1.isNotEmpty) {
          chartData1?.insert(0, _ChartData(timestamp1, values1[0]));
          chartData2?.insert(0, _ChartData(timestamp1, values1[1]));
          chartData3?.insert(0, _ChartData(timestamp1, values1[2]));
          chartData4?.insert(0, _ChartData(timestamp1, values1[3]));
          chartData1?.removeLast();
          chartData2?.removeLast();
          chartData3?.removeLast();
          chartData4?.removeLast();
        }
      }
      setState(() {}); // Aggiorna lo stato per riflettere i nuovi dati
    } else {
      throw Exception('Failed to load data');
    }
  }*/

  Future<void> fetchData20() async {
    final response = await https.get(
      Uri.parse(
        'https://students.measurify.org/v1/measurements/mesuremets-vine1/timeserie?limit=20',
      ),
      headers: {
        'Authorization': 'DVC $authToken',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> docs = data['docs'];
      for (var doc in docs) {
        List<dynamic> values = doc['values'];
        String timestamp = doc['timestamp'];
        if (chartData1!.length < 20) {
          chartData1?.insert(0, _ChartData(timestamp, values[0]));
          chartData2?.insert(0, _ChartData(timestamp, values[1]));
          chartData3?.insert(0, _ChartData(timestamp, values[2]));
          chartData4?.insert(0, _ChartData(timestamp, values[3]));
        }
        if (chartData1!.length >= 20) {
          chartData1?.removeLast();
          chartData2?.removeLast();
          chartData3?.removeLast();
          chartData4?.removeLast();
        }
      }

      setState(() {}); // Aggiorna lo stato per riflettere i nuovi dati
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  void initState() {
    chartData1 = <_ChartData>[
      _ChartData('2024-01-05T12:10:00', 0),
      _ChartData('2024-01-06T12:10:00', 0),
      _ChartData('2024-01-07T12:10:00', 0),
      _ChartData('2024-01-08T12:10:00', 0),
      _ChartData('2024-01-09T12:10:00', 0),
      _ChartData('2024-01-10T12:10:00', 0),
      _ChartData('2024-01-11T12:10:00', 0),
      _ChartData('2024-01-12T12:10:00', 0),
      _ChartData('2024-01-13T12:10:00', 0),
      _ChartData('2024-01-14T12:10:00', 0),
      _ChartData('2024-01-10T12:10:00', 0),
      _ChartData('2024-01-11T12:10:00', 0),
      _ChartData('2024-01-12T12:10:00', 0),
      _ChartData('2024-01-13T12:10:00', 0),
      _ChartData('2024-01-14T12:10:00', 0),
    ];
    chartData2 = <_ChartData>[
      _ChartData('2024-01-05T12:10:00', 0),
      _ChartData('2024-01-06T12:10:00', 0),
      _ChartData('2024-01-07T12:10:00', 0),
      _ChartData('2024-01-08T12:10:00', 0),
      _ChartData('2024-01-09T12:10:00', 0),
      _ChartData('2024-01-10T12:10:00', 0),
      _ChartData('2024-01-11T12:10:00', 0),
      _ChartData('2024-01-12T12:10:00', 0),
      _ChartData('2024-01-13T12:10:00', 0),
      _ChartData('2024-01-14T12:10:00', 0),
      _ChartData('2024-01-10T12:10:00', 0),
      _ChartData('2024-01-11T12:10:00', 0),
      _ChartData('2024-01-12T12:10:00', 0),
      _ChartData('2024-01-13T12:10:00', 0),
      _ChartData('2024-01-14T12:10:00', 0),
    ];
    chartData3 = <_ChartData>[
      _ChartData('2024-01-05T12:10:00', 0),
      _ChartData('2024-01-06T12:10:00', 0),
      _ChartData('2024-01-07T12:10:00', 0),
      _ChartData('2024-01-08T12:10:00', 0),
      _ChartData('2024-01-09T12:10:00', 0),
      _ChartData('2024-01-10T12:10:00', 0),
      _ChartData('2024-01-11T12:10:00', 0),
      _ChartData('2024-01-12T12:10:00', 0),
      _ChartData('2024-01-13T12:10:00', 0),
      _ChartData('2024-01-14T12:10:00', 0),
      _ChartData('2024-01-10T12:10:00', 0),
      _ChartData('2024-01-11T12:10:00', 0),
      _ChartData('2024-01-12T12:10:00', 0),
      _ChartData('2024-01-13T12:10:00', 0),
      _ChartData('2024-01-14T12:10:00', 0),
    ];
    chartData4 = <_ChartData>[
      _ChartData('2024-01-05T12:10:00', 0),
      _ChartData('2024-01-06T12:10:00', 0),
      _ChartData('2024-01-07T12:10:00', 0),
      _ChartData('2024-01-08T12:10:00', 0),
      _ChartData('2024-01-09T12:10:00', 0),
      _ChartData('2024-01-10T12:10:00', 0),
      _ChartData('2024-01-11T12:10:00', 0),
      _ChartData('2024-01-12T12:10:00', 0),
      _ChartData('2024-01-13T12:10:00', 0),
      _ChartData('2024-01-14T12:10:00', 0),
      _ChartData('2024-01-10T12:10:00', 0),
      _ChartData('2024-01-11T12:10:00', 0),
      _ChartData('2024-01-12T12:10:00', 0),
      _ChartData('2024-01-13T12:10:00', 0),
      _ChartData('2024-01-14T12:10:00', 0),
    ];
    fetchData20();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _buildLiveLineChart();
  }

  /// Returns the realtime Cartesian line chart.
  Container _buildLiveLineChart() {
    return Container(
        padding: EdgeInsets.all(1.0),
        child: SfCartesianChart(
            title: ChartTitle(
                text: 'Ultime 20 Misure', textStyle: TextStyle(fontSize: 20)),
            legend: Legend(
              iconHeight: 20,
              iconWidth: 20,
              isVisible: true,
              position: LegendPosition.bottom,
              textStyle: TextStyle(fontSize: 20),
              overflowMode: LegendItemOverflowMode.wrap,
              borderColor: Colors.green[400],
              backgroundColor: Colors.green[200],
              borderWidth: 2,
              padding: 10,
            ),
            plotAreaBorderWidth: 0,
            tooltipBehavior: TooltipBehavior(enable: true),
            axes: const <ChartAxis>[
              NumericAxis(
                  opposedPosition: true,
                  name: 'yAxis1',
                  majorGridLines: MajorGridLines(width: 0),
                 // minimum: 0,
                  //maximum: 1800,
                  interval: 20,
                  title: AxisTitle(text: 'Luminosità [Lux]'))
            ],
            primaryXAxis: DateTimeAxis(
              dateFormat: DateFormat('yyyy-MM-ddTHH:mm:ss'),
              labelRotation: -90,
              majorGridLines: MajorGridLines(width: 1),
              interval: 0.3,
            ),
            primaryYAxis: const NumericAxis(
                axisLine: AxisLine(width: 1),
                majorTickLines: MajorTickLines(size: 5)),
            series: <LineSeries<_ChartData, dynamic>>[
              LineSeries<_ChartData, dynamic>(
                dataSource: chartData1,
                name: 'Umidità del suolo [%]',
                color: Colors.green[600],
                xValueMapper: (_ChartData data, _) =>
                    DateTime.parse(data.formattedTimestamp),
                yValueMapper: (_ChartData data, _) => data.val,
                animationDuration: 0,
                markerSettings: const MarkerSettings(isVisible: true),
              ),
              LineSeries<_ChartData, dynamic>(
                  dataSource: chartData2,
                  name: "Umidità dell'aria [%]",
                  color: Colors.blue[600],
                  xValueMapper: (_ChartData data, _) =>
                      DateTime.parse(data.formattedTimestamp),
                  yValueMapper: (_ChartData data, _) => data.val,
                  animationDuration: 0,
                  markerSettings: const MarkerSettings(isVisible: true)),
              LineSeries<_ChartData, dynamic>(
                  dataSource: chartData3,
                  name: "Temperatura [C°]",
                  color: Colors.red[600],
                  xValueMapper: (_ChartData data, _) =>
                      DateTime.parse(data.formattedTimestamp),
                  yValueMapper: (_ChartData data, _) => data.val,
                  animationDuration: 0,
                  markerSettings: const MarkerSettings(isVisible: true)),
              LineSeries<_ChartData, dynamic>(
                  dataSource: chartData4,
                  name: "Luminosità [Lux]",
                  color: Colors.yellow[600],
                  yAxisName: 'yAxis1',
                  xValueMapper: (_ChartData data, _) =>
                      DateTime.parse(data.formattedTimestamp),
                  yValueMapper: (_ChartData data, _) => data.val,
                  animationDuration: 0,
                  markerSettings: const MarkerSettings(isVisible: true)),
            ]));
  }

  @override
  void dispose() {
    chartData1!.clear();
    chartData2!.clear();
    chartData3!.clear();
    chartData4!.clear();
    super.dispose();
  }
}

/// Private class for storing the chart series data points.
class _ChartData {
  _ChartData(this.timestamp, this.val);
  final dynamic val;
  final String timestamp;

  String get formattedTimestamp {
    DateTime dateTime = DateTime.parse(timestamp);
    return DateFormat('yyyy-MM-ddTHH:mm:ss').format(dateTime);
  }
}
