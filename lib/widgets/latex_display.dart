import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class LatexDisplay extends StatelessWidget {
  final String latex;
  final double fontSize;
  final FontWeight fontWeight;
  final Color? color;
  final TextAlign textAlign;

  const LatexDisplay({
    super.key,
    required this.latex,
    this.fontSize = 18,
    this.fontWeight = FontWeight.normal,
    this.color,
    this.textAlign = TextAlign.left,
  });

  @override
  Widget build(BuildContext context) {
    if (latex.isEmpty) {
      return const SizedBox.shrink();
    }

    // 处理LaTeX字符串
    String processedLatex = _processLatex(latex);

    // 尝试渲染LaTeX
    try {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Math.tex(
          processedLatex,
          textStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: color ?? Theme.of(context).textTheme.bodyLarge?.color,
          ),
          mathStyle: MathStyle.display,
          onErrorFallback: (error) {
            // 如果LaTeX解析失败，尝试简化的版本
            return _buildFallback(context, processedLatex, error);
          },
        ),
      );
    } catch (e) {
      return _buildFallback(context, processedLatex, e);
    }
  }

  Widget _buildFallback(BuildContext context, String latex, dynamic error) {
    // 尝试进一步简化LaTeX
    String simplified = _simplifyLatex(latex);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 尝试渲染简化版本
          Math.tex(
            simplified,
            textStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: color ?? Theme.of(context).textTheme.bodyLarge?.color,
            ),
            mathStyle: MathStyle.display,
            onErrorFallback: (_) {
              // 如果还是失败，显示纯文本
              return SelectableText(
                _latexToPlainText(latex),
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: fontWeight,
                  color: color ?? Theme.of(context).textTheme.bodyLarge?.color,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// 处理LaTeX字符串
  String _processLatex(String input) {
    String result = input;

    // 移除可能的$符号
    result = result.replaceAll('\$', '');
    result = result.replaceAll(r'$$', '');

    // 修复一些常见的LaTeX问题
    result = result.replaceAll(r'\left(', r'\left(');
    result = result.replaceAll(r'\right)', r'\right)');
    result = result.replaceAll(r'\left{', r'\left\{');
    result = result.replaceAll(r'\right}', r'\right\}');

    // 确保\mathrm等命令格式正确
    result = result.replaceAll(r'\mathrm{d}x', r'\mathrm{d}x');

    return result;
  }

  /// 简化LaTeX表达式
  String _simplifyLatex(String input) {
    String result = input;

    // 移除复杂的命令
    result = result.replaceAll(RegExp(r'\\htmlClass\{[^}]*\}\{'), '');
    result = result.replaceAll(RegExp(r'\\htmlId\{[^}]*\}\{'), '');

    // 简化一些命令
    result = result.replaceAll(r'\dfrac', r'\frac');
    result = result.replaceAll(r'\;', ' ');

    return result;
  }

  /// 将LaTeX转换为纯文本（最后的回退）
  String _latexToPlainText(String latex) {
    String result = latex;

    // 替换常见的LaTeX命令为Unicode
    result = result.replaceAll(r'\int', '∫');
    result = result.replaceAll(r'\mathrm{d}', 'd');
    result = result.replaceAll(r'\sin', 'sin');
    result = result.replaceAll(r'\cos', 'cos');
    result = result.replaceAll(r'\tan', 'tan');
    result = result.replaceAll(r'\ln', 'ln');
    result = result.replaceAll(r'\log', 'log');
    result = result.replaceAll(r'\sqrt', '√');
    result = result.replaceAll(r'\infty', '∞');
    result = result.replaceAll(r'\pi', 'π');
    result = result.replaceAll(r'\alpha', 'α');
    result = result.replaceAll(r'\beta', 'β');
    result = result.replaceAll(r'\gamma', 'γ');
    result = result.replaceAll(r'\delta', 'δ');
    result = result.replaceAll(r'\theta', 'θ');
    result = result.replaceAll(r'\lambda', 'λ');
    result = result.replaceAll(r'\mu', 'μ');
    result = result.replaceAll(r'\sigma', 'σ');

    // 移除\left和\right
    result = result.replaceAll(r'\left', '');
    result = result.replaceAll(r'\right', '');

    // 简化分数
    result = result.replaceAllMapped(
      RegExp(r'\\frac\{([^}]*)\}\{([^}]*)\}'),
      (match) => '(${match.group(1)}/${match.group(2)})',
    );

    // 移除花括号
    result = result.replaceAll('{', '');
    result = result.replaceAll('}', '');

    // 清理空格
    result = result.replaceAll(RegExp(r'\s+'), ' ').trim();

    return result;
  }
}

/// 简单的LaTeX文本显示（用于短文本）
class LatexText extends StatelessWidget {
  final String latex;
  final double fontSize;
  final FontWeight fontWeight;
  final Color? color;

  const LatexText({
    super.key,
    required this.latex,
    this.fontSize = 16,
    this.fontWeight = FontWeight.normal,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (latex.isEmpty) {
      return const SizedBox.shrink();
    }

    return LatexDisplay(
      latex: latex,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }
}
