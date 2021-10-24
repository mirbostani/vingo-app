import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class Timer extends StatefulWidget {
  const Timer({ Key? key }) : super(key: key);

  @override
  _TimerState createState() => _TimerState();
}

class _TimerState extends State<Timer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text("timer"),
    );
  }
}