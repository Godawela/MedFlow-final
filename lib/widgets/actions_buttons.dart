import 'package:flutter/material.dart';
import 'package:med/pages/user%20pages/machine.dart';
import 'package:med/pages/user%20pages/symptom.dart';
import 'package:med/widgets/buildActionButton.dart';

class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildActionButton('Machines', () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MachinePage()),
          );
        }),
        const SizedBox(height: 20),
        buildActionButton('Symptom', () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SymptomPage()),
          );
        }),
      ],
    );
  }
}
