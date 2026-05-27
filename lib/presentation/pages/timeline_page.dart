
import 'package:flutter/material.dart';
import 'package:software_for_nature/presentation/widgets/layout.dart';

class TimeLinePage extends StatefulWidget{

  const TimeLinePage({super.key});

  State<TimeLinePage> createState() => _TimeLineState();

}

class _TimeLineState extends State<TimeLinePage>{

  @override
  Widget build(BuildContext context) {
    return Layout(
      child: Center(
        child: Text('Dit is de TimeLine')
      )
    );
  }
}