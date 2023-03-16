import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const String _title = 'Control Panel';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: const App(),
      theme: ThemeData(primarySwatch: Colors.indigo),
    );
  }
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

/// AnimationControllers can be created with `vsync: this` because of TickerProviderStateMixin.
class _AppState extends State<App> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  Widget tabLabel(String name, IconData iconData) {
    return Row(
      children: <Widget>[
        Icon(
          iconData,
          size: 24.0,
        ),
        const SizedBox(width: 8.0),
        Text(
          name,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w200,
            fontSize: 20.0,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Control Panel'),
        bottom: TabBar(
          controller: _tabController,
          tabs: <Widget>[
            Tab(
              child: tabLabel('home', Icons.home),
            ),
            Tab(
              child: tabLabel('logs', Icons.folder_shared),
            ),
            Tab(
              child: tabLabel('settings', Icons.settings),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        // TODO: check if using const here doesn't break the stateful widgets inside
        children: const [
          MainPage(),
          BlankPage(),
          BlankPage(),
        ],
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

const List<Widget> powerActions = [
  Text("run"),
  Text("stop"),
];

const List<Widget> autostartPolicies = [
  Text("enabled"),
  Text("disabled"),
];

class _MainPageState extends State<MainPage>
    with AutomaticKeepAliveClientMixin<MainPage> {
  // TODO: move the initialization to initState() to grab the actuale state from the backend
  final List<bool> _selectedPowerAction = <bool>[false, true];
  final List<bool> _selectedAutostartPolicy = <bool>[false, true];

  @override
  bool get wantKeepAlive => true;

  //override
  // void initState() {
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Row(
      children: [
        Expanded(
          child: ListView(
            children: [
              const SizedBox(height: 24.0),
              const Padding(
                padding: EdgeInsets.only(left: 16.0),
                child: Text(
                  'Performance:',
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 24.0,
                  ),
                ),
              ),
              const SizedBox(height: 24.0),
              Container(
                constraints: const BoxConstraints(
                  maxHeight: 300,
                  minHeight: 200,
                ),
                padding: const EdgeInsets.only(left: 42.0, right: 42.0),
                child: const PerformanceChart(),
              ),
            ],
          ),
        ),
        Container(
          constraints: const BoxConstraints(minWidth: 200, maxWidth: 300),
          child: ListView(
            children: [
              const Text("Service"),
              ToggleButtons(
                onPressed: (int indexPressed) {
                  setState(() {
                    for (int i = 0; i < _selectedPowerAction.length; i++) {
                      _selectedPowerAction[i] = i == indexPressed;
                    }
                  });
                },
                isSelected: _selectedPowerAction,
                selectedColor: Colors.white,
                fillColor: Colors.blueGrey[600],
                children: powerActions,
              ),
              const Text("Start on server boot"),
              ToggleButtons(
                onPressed: (int indexPressed) {
                  setState(() {
                    for (int i = 0; i < _selectedAutostartPolicy.length; i++) {
                      _selectedAutostartPolicy[i] = i == indexPressed;
                    }
                  });
                },
                isSelected: _selectedAutostartPolicy,
                selectedColor: Colors.white,
                fillColor: Colors.blueGrey[600],
                children: autostartPolicies,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class PerformanceChart extends StatefulWidget {
  const PerformanceChart({super.key});

  final color = Colors.red;

  @override
  State<PerformanceChart> createState() => _PerformanceChartState();
}

class _PerformanceChartState extends State<PerformanceChart> {
  final maxSpots = 1000;
  final pointsCPU = <FlSpot>[];
  final pointsRAM = <FlSpot>[];

  int xVal = 0;

  late Timer timer;

  double randomPercent(double x) {
    return (0.5 +
            0.4 * math.sin(x / 100000 + 0.4 * math.Random().nextDouble())) *
        100;
  }

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      while (pointsCPU.length > maxSpots) {
        pointsCPU.removeAt(0);
      }
      while (pointsRAM.length > maxSpots) {
        pointsRAM.removeAt(0);
      }
      xVal = DateTime.now().toUtc().millisecondsSinceEpoch;
      setState(() {
        pointsCPU.add(
            FlSpot(xVal.roundToDouble(), 100 * math.Random().nextDouble()));
        pointsRAM.add(
          FlSpot(
            xVal.roundToDouble(),
            randomPercent(xVal / 1000),
          ),
        );
      });
    });
  }

  LineChartBarData line(List<FlSpot> points, bool showUnder, Color color) {
    return LineChartBarData(
      spots: points,
      dotData: FlDotData(
        show: false,
      ),
      barWidth: 3,
      isCurved: true,
      color: color,
      belowBarData: BarAreaData(
        show: showUnder,
        color: color.withAlpha(128),
      ),
    );
  }

  Widget timeTickGenerator(double tick, TitleMeta meta) {
    if ((meta.max - tick).abs() < 2 || (meta.min - tick).abs() < 2) {
      return const Text("");
    }
    var convertedTime = DateTime.fromMillisecondsSinceEpoch(tick.toInt());
    return labelText(
      DateFormat('HH:mm:ss').format(convertedTime),
      10.0,
    );
  }

  Widget percentTickGenerator(double tick, TitleMeta meta) {
    final str = tick.toString();
    return labelText(
      "$str%",
      10.0,
    );
  }

  Widget labelText(String text, double size) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: size,
        fontStyle: FontStyle.italic,
        color: Colors.grey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 100,
        minX: pointsCPU.last.x - maxSpots * 500,
        maxX: pointsCPU.last.x,
        titlesData: FlTitlesData(
          show: true,
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 20.0,
              reservedSize: 32.0,
              getTitlesWidget: percentTickGenerator,
            ),
          ),
          rightTitles: AxisTitles(axisNameWidget: labelText("load, %", 16.0)),
          topTitles:
              AxisTitles(axisNameWidget: labelText("time, hh:mm:ss", 16.0)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 60000,
              getTitlesWidget: timeTickGenerator,
            ),
          ),
        ),
        lineTouchData: LineTouchData(enabled: false),
        clipData: FlClipData.all(),
        gridData: FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: Colors.indigo,
            width: 2,
          ),
        ),
        lineBarsData: [
          line(pointsRAM, true, Colors.green),
          line(pointsCPU, false, Colors.red),
        ],
      ),
      swapAnimationDuration: Duration.zero,
    );
  }
}

class BlankPage extends StatefulWidget {
  const BlankPage({super.key});
  @override
  State<BlankPage> createState() => _BlankPageState();
}

class _BlankPageState extends State<BlankPage> {
  @override
  Widget build(BuildContext context) {
    return const Text('Coming soon!!!');
  }
}
