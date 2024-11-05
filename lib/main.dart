import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/extended_rules_screen.dart';
import 'providers/rules_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => RulesProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Four Souls Helper',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const ExtendedRulesScreen(),
    );
  }
}