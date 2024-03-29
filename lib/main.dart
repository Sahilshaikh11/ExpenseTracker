import 'package:expense/database/expense_database.dart';
import 'package:expense/pages/home_page.dart';
import 'package:expense/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  // init db
  await ExpenseDatabase.initialize();
  runApp(
      ChangeNotifierProvider(create: (context) => ExpenseDatabase(),
        child: const MyApp(),
      )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
