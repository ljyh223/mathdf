import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:mathdf/widgets/latex_display.dart';

void main() {
  group('LatexDisplay', () {
    testWidgets('should render simple LaTeX expression', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: LatexDisplay(latex: r'x^2')),
        ),
      );

      await tester.pumpAndSettle();

      // 验证widget被创建
      expect(find.byType(LatexDisplay), findsOneWidget);
      expect(find.byType(Math), findsOneWidget);
    });

    testWidgets('should render integral expression', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LatexDisplay(
              latex: r'\int{\sin\left(x\right)}{\;\mathrm{d}x}',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(LatexDisplay), findsOneWidget);
      expect(find.byType(Math), findsOneWidget);
    });

    testWidgets('should render fraction expression', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: LatexDisplay(latex: r'\dfrac{x^2}{2}')),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(LatexDisplay), findsOneWidget);
      expect(find.byType(Math), findsOneWidget);
    });

    testWidgets('should render result from API response', (tester) async {
      // 模拟API返回的LaTeX (已处理占位符)
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: LatexDisplay(latex: r'-\cos\left(x\right)')),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(LatexDisplay), findsOneWidget);
      expect(find.byType(Math), findsOneWidget);
    });

    testWidgets('should render complex integral result', (tester) async {
      // sin(x)*cos(x) 积分结果
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LatexDisplay(latex: r'\dfrac{\sin^{2}\left(x\right)}{2}'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(LatexDisplay), findsOneWidget);
      expect(find.byType(Math), findsOneWidget);
    });

    testWidgets('should handle empty string', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: LatexDisplay(latex: '')),
        ),
      );

      await tester.pumpAndSettle();

      // 空字符串应该返回SizedBox.shrink
      expect(find.byType(LatexDisplay), findsOneWidget);
      expect(find.byType(Math), findsNothing);
    });

    testWidgets('should fallback to text on invalid LaTeX', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: LatexDisplay(latex: r'\invalid{syntax')),
        ),
      );

      await tester.pumpAndSettle();

      // 应该回退到文本显示
      expect(find.byType(LatexDisplay), findsOneWidget);
      expect(find.byType(SelectableText), findsOneWidget);
    });
  });

  group('LatexText', () {
    testWidgets('should render using LatexDisplay', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: LatexText(latex: r'x + y = z')),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(LatexText), findsOneWidget);
      expect(find.byType(LatexDisplay), findsOneWidget);
    });
  });
}
