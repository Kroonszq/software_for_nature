import 'package:flutter/material.dart';
import 'package:software_for_nature/presentation/widgets/navigation.dart';

@immutable
class Layout extends StatelessWidget {

  final Widget child;
  final String? title;

  const Layout({super.key, required this.child, this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Navigation(),  
      body: child,
    );
  }
}