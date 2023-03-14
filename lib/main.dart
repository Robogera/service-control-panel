import 'package:flutter/material.dart';

void main() => runApp(const ControlPanel());

class ControlPanel extends StatelessWidget {
  const ControlPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPage = 0;

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            bottomNavigationBar: NavigationBar(
                onDestinationSelected: (int index) {
                    setState(() {
                        currentPage = index;
                    });
                },
                selectedIndex: currentPage,
                destinations: const <Widget>[
                    NavigationDestination(
                        icon: Icon(Icons.home),
                        label: 'Main',
                ),
            ],
        ));
    }
}
