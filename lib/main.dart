import 'package:flutter/material.dart';
import 'thirdpage.dart';

import 'firstpage.dart';
import 'secondpage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const Home(),
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        primaryColor: Colors.grey[600],
      ),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey[600],
          bottom: const TabBar(
            labelColor: Colors.white,
            tabs: [
              Tab(
                text: "Original \nimage",
              ),
              Tab(
                text: "Scan \nimage",
              ),
              Tab(
                text: "Draw \nimage",
              ),
            ],
          ),
          title: const Text(
            'Lay',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: const TabBarView(
          children: [
            Firstpage(),
            Secondpage(),
            Thirdpage(), // Assuming you have a widget named Thirdpage
          ],
        ),
      ),
    );
  }
}
