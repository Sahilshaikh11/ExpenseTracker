import 'dart:async';

import 'package:expense/pages/home_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 5), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomePage(),));
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.grey.shade300,
        child: Center(
          child: Text("Expense Ease", style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w700,
              fontFamily: 'SplashFont',
              color: Colors.black
          ),),
        ),
      ),
    );
  }
}