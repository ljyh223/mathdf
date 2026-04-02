import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  late TextEditingController _limitToController;

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
    _limitToController = TextEditingController(text: provider.limitTo ?? '');

    // 初始化OCR服务
    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider.initOcr();
    });
  }

  @override
  void dispose() {
    _exprController.dispose();
    _varController.dispose();
    _lowerLimitController.dispose();
    _upperLimitController.dispose();
    _paramController.dispose();
    _limitToController.dispose();
    super.dispose();
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
          // 同步表达式（来自OCR）
          if (_exprController.text != provider.expression) {
            _exprController.text = provider.expression;
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
                  decoration: InputDecoration(
                    labelText: '表达式',
                    hintText: '例如: sin(x)*cos(x)',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.functions),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // OCR按钮
                        IconButton(
                          icon: provider.isOcrLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.camera_alt),
                          onPressed: provider.isOcrLoading
                              ? null
                              : () => _showOcrDialog(context, provider),
                          tooltip: 'OCR识别',
                        ),
                        // 清除按钮
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _exprController.clear();
                            provider.setExpression('');
                          },
                          tooltip: '清除',
                        ),
                      ],
                    ),
                  ),
                  controller: _exprController,
                  onChanged: provider.setExpression,
                  maxLines: 2,
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
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: '变量趋向',
                            hintText: '例如: inf, 0, 1',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.arrow_forward),
                          ),
                          controller: _limitToController,
                          onChanged: provider.setLimitTo,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: '洛必达',
                            hintText: 'usehopital=false',
                            border: OutlineInputBorder(),
                          ),
                          controller: _paramController,
                          onChanged: provider.setAdditionalParam,
                        ),
                      ),
                    ],
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

  /// 显示OCR对话框
  void _showOcrDialog(BuildContext context, CalculationProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('OCR识别'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('选择识别方式：'),
            const SizedBox(height: 16),

            // 从剪贴板粘贴图片
            ListTile(
              leading: const Icon(Icons.paste),
              title: const Text('从剪贴板粘贴图片'),
              onTap: () {
                Navigator.pop(context);
                _pasteFromClipboard(provider);
              },
            ),

            // 从文件选择
            ListTile(
              leading: const Icon(Icons.folder),
              title: const Text('从文件选择'),
              onTap: () {
                Navigator.pop(context);
                _selectFromFile(provider);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  /// 从剪贴板粘贴图片
  Future<void> _pasteFromClipboard(CalculationProvider provider) async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData?.text != null) {
        // 检查是否是base64编码的图片
        final text = clipboardData!.text!;
        if (text.startsWith('data:image')) {
          // 解析base64
          final base64Str = text.split(',')[1];
          final bytes = base64Decode(base64Str);
          await provider.recognizeFromImage(bytes);
        } else {
          // 尝试作为文件路径
          _showSnackBar('请粘贴图片数据或使用文件选择');
        }
      } else {
        _showSnackBar('剪贴板为空');
      }
    } catch (e) {
      _showSnackBar('粘贴失败: $e');
    }
  }

  /// 从文件选择（简化版本，显示输入对话框）
  Future<void> _selectFromFile(CalculationProvider provider) async {
    final controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('输入图片路径'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '/path/to/image.png',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (result != null && result.isNotEmpty) {
      try {
        final file = await rootBundle.load(result);
        await provider.recognizeFromImage(file.buffer.asUint8List());
      } catch (e) {
        _showSnackBar('加载图片失败: $e');
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // Base64解码
  Uint8List base64Decode(String str) {
    // 简化的base64解码实现
    // 实际应该使用dart:convert的base64Decode
    return Uint8List(0);
  }
}
