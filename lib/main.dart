import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const String _title = 'Synapse Control Panel';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: App(),
      theme: ThemeData(primarySwatch: Colors.green),
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
            Tab(icon: Icon(Icons.pending), text: "Logs"),
            Tab(icon: Icon(Icons.settings), text: "Settings"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
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

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(children: [
        Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(color: Colors.blue),
            )),
        Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(color: Colors.purple),
            )),
      ]),
    );
  }
}
