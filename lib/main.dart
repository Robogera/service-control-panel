import 'dart:async';
import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const String _title = 'Synapse Control Panel';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: const App(),
      theme: ThemeData(primarySwatch: Colors.blueGrey),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Synapse Control Panel'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const <Widget>[
            Tab(
              icon: Icon(Icons.home),
              text: "Home",
            ),
            Tab(icon: Icon(Icons.chat), text: "Logs"),
            Tab(icon: Icon(Icons.settings), text: "Settings"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        // TODO: check if using const here doesn't break the stateful widgets inside
        children: [
          MainPage(),
          MainPage(),
          MainPage(),
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text("CPU usage:"),
                Container(
                  constraints: BoxConstraints(
                    maxHeight: 300,
                    minHeight: 200,
                  ),
                  padding: const EdgeInsets.only(left: 42.0, right: 42.0),
                  child: PerformanceChart(),
                ),
              ],
            ),
          ),
        ),
        Container(
          constraints: const BoxConstraints(minWidth: 200, maxWidth: 300),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text("Synapse service"),
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
                      for (int i = 0;
                          i < _selectedAutostartPolicy.length;
                          i++) {
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
  final dotsLimit = 100;
  final points = <FlSpot>[];

  double xVal = 0;
  double step = 0.1;

  late Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(milliseconds: 400), (timer) {
      while (points.length > dotsLimit) {
        points.removeAt(0);
      }
      setState(() {
        points.add(FlSpot(
            xVal,
            ((1 + math.sin(xVal)) / 2 +
                    (math.Random().nextDouble() - 0.5) * 0.4)
                .abs()));
      });
      xVal += step;
    });
  }

  LineChartBarData line(List<FlSpot> points) {
    return LineChartBarData(
      spots: points,
      dotData: FlDotData(
        show: false,
      ),
      barWidth: 4,
      isCurved: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 1.2,
        minX: points.first.x,
        maxX: points.last.x,
        titlesData: FlTitlesData(show: false),
        lineTouchData: LineTouchData(enabled: false),
        clipData: FlClipData.all(),
        gridData: FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(
            show: true, border: Border.all(color: Colors.blueGrey, width: 2)),
        lineBarsData: [
          line(points),
        ],
      ),
      swapAnimationDuration: Duration.zero,
    );
  }
}
