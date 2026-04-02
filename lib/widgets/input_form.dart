import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mathdf/models/calculation_type.dart';
import 'package:mathdf/providers/calculation_provider.dart';

class InputForm extends StatefulWidget {
  const InputForm({super.key});

  @override
  State<InputForm> createState() => _InputFormState();
}

class _InputFormState extends State<InputForm> {
  late TextEditingController _exprController;
  late TextEditingController _varController;
  late TextEditingController _lowerLimitController;
  late TextEditingController _upperLimitController;
  late TextEditingController _paramController;

  @override
  void initState() {
    super.initState();
    final provider = context.read<CalculationProvider>();
    _exprController = TextEditingController(text: provider.expression);
    _varController = TextEditingController(text: provider.variable);
    _lowerLimitController = TextEditingController(text: provider.lowerLimit);
    _upperLimitController = TextEditingController(text: provider.upperLimit);
    _paramController = TextEditingController(
      text: provider.additionalParam ?? '',
    );
  }

  @override
  void dispose() {
    _exprController.dispose();
    _varController.dispose();
    _lowerLimitController.dispose();
    _upperLimitController.dispose();
    _paramController.dispose();
    super.dispose();
  }

  void _syncControllers() {
    final provider = context.read<CalculationProvider>();

    // 同步表达式
    if (_exprController.text != provider.expression) {
      final selection = _exprController.selection;
      _exprController.text = provider.expression;
      if (selection.isValid && selection.end <= provider.expression.length) {
        _exprController.selection = selection;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CalculationProvider>(
      builder: (context, provider, child) {
        // 类型变化时更新控制器
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_varController.text != provider.variable) {
            _varController.text = provider.variable;
          }
          if (_lowerLimitController.text != provider.lowerLimit) {
            _lowerLimitController.text = provider.lowerLimit;
          }
          if (_upperLimitController.text != provider.upperLimit) {
            _upperLimitController.text = provider.upperLimit;
          }
          final param = provider.additionalParam ?? '';
          if (_paramController.text != param) {
            _paramController.text = param;
          }
        });

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 计算类型选择
                _buildTypeSelector(context, provider),
                const SizedBox(height: 16),

                // 表达式输入
                TextField(
                  decoration: const InputDecoration(
                    labelText: '表达式',
                    hintText: '例如: sin(x)*cos(x)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.functions),
                  ),
                  controller: _exprController,
                  onChanged: provider.setExpression,
                ),
                const SizedBox(height: 16),

                // 变量输入
                if (provider.showVariableInput) ...[
                  TextField(
                    decoration: const InputDecoration(
                      labelText: '变量',
                      hintText: 'x',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.code),
                    ),
                    controller: _varController,
                    onChanged: provider.setVariable,
                  ),
                  const SizedBox(height: 16),
                ],

                // 积分上下限输入
                if (provider.showIntegralLimits) ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: '下限',
                            hintText: '例如: 0',
                            border: OutlineInputBorder(),
                          ),
                          controller: _lowerLimitController,
                          onChanged: provider.setLowerLimit,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: '上限',
                            hintText: '例如: π',
                            border: OutlineInputBorder(),
                          ),
                          controller: _upperLimitController,
                          onChanged: provider.setUpperLimit,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                // 极限点输入
                if (provider.showLimitPoint) ...[
                  TextField(
                    decoration: const InputDecoration(
                      labelText: '极限点',
                      hintText: '例如: 0, ∞',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.arrow_forward),
                    ),
                    controller: _paramController,
                    onChanged: provider.setAdditionalParam,
                  ),
                  const SizedBox(height: 16),
                ],

                // 计算按钮
                ElevatedButton.icon(
                  onPressed: provider.isLoading
                      ? null
                      : () => provider.calculate(),
                  icon: provider.isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.calculate),
                  label: Text(provider.isLoading ? '计算中...' : '计算'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),

                // 错误提示
                if (provider.error != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            provider.error!,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTypeSelector(
    BuildContext context,
    CalculationProvider provider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('计算类型', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: CalculationType.values.map((type) {
            final isSelected = provider.selectedType == type;
            return ChoiceChip(
              label: Text(type.displayName),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  provider.setType(type);
                }
              },
              avatar: Text(type.icon),
            );
          }).toList(),
        ),
      ],
    );
  }
}
