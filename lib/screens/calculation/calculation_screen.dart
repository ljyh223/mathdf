import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mathdf/models/calculation_type.dart';
import 'package:mathdf/providers/calculation_provider.dart';
import 'package:mathdf/widgets/input_form.dart';
import 'package:mathdf/widgets/result_display.dart';

class CalculationScreen extends StatelessWidget {
  const CalculationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<CalculationProvider>(
          builder: (context, provider, child) {
            return Text('${provider.selectedType.displayName} 计算');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              context.read<CalculationProvider>().clearAll();
            },
          ),
        ],
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            InputForm(),
            SizedBox(height: 16),
            Expanded(child: ResultDisplay()),
          ],
        ),
      ),
    );
  }
}
