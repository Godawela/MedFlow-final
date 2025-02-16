import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:med/routes/router.dart';
import 'package:med/widgets/buildActionButton.dart';

class ActionButtons extends StatelessWidget {
  const ActionButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildActionButton('Machines', () {
          AutoRouter.of(context).push(MachineRoute());
        }),
        const SizedBox(height: 20),
        buildActionButton('Symptom', () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => const SymptomPage()),
          // );
        }),
      ],
    );
  }
}
