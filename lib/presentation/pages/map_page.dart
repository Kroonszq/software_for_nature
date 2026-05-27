
import 'package:flutter/material.dart';
import 'package:software_for_nature/presentation/widgets/layout.dart';

class MapPage extends StatefulWidget{

  const MapPage({super.key});

  State<MapPage> createState() => _MapPageState();

}

class _MapPageState extends State<MapPage>{

  @override
  Widget build(BuildContext context) {
    return Layout(
      child: Center(
        child: Text('Dit is de MapPage')
      )
    );
  }
}