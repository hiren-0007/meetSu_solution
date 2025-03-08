import 'package:flutter/material.dart';
import 'package:meetsu_solutions/utils/widgets/connectivity_widget.dart';

class QuizResultScreen extends StatelessWidget {
  const QuizResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ConnectivityWidget(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Quiz Result'),
        ),
        body: Center(
          child: Text(
            'No Data Found',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
