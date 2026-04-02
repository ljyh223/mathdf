import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mathdf/models/calculation_type.dart';

class HistoryProvider with ChangeNotifier {
  static const String _historyKey = 'calculation_history';

  List<HistoryItem> _history = [];

  HistoryProvider() {
    _loadHistory();
  }

  List<HistoryItem> get history => _history;

  /// 获取按类型分组的历史记录
  Map<CalculationType, List<HistoryItem>> get historyByType {
    final map = <CalculationType, List<HistoryItem>>{};
    for (final item in _history) {
      map.putIfAbsent(item.type, () => []);
      map[item.type]!.add(item);
    }
    return map;
  }

  /// 获取最近的历史记录
  List<HistoryItem> getRecentHistory({int limit = 10}) {
    final sorted = List<HistoryItem>.from(_history);
    sorted.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sorted.take(limit).toList();
  }

  /// 加载历史记录
  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList(_historyKey) ?? [];

      _history = historyJson
          .map((json) => HistoryItem.fromJson(jsonDecode(json)))
          .toList();

      notifyListeners();
    } catch (e) {
      print('加载历史记录失败: $e');
    }
  }

  /// 保存历史记录
  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = _history
          .map((item) => jsonEncode(item.toJson()))
          .toList();

      await prefs.setStringList(_historyKey, historyJson);
    } catch (e) {
      print('保存历史记录失败: $e');
    }
  }

  /// 添加历史记录
  Future<void> addHistory({
    required CalculationType type,
    required String expression,
    required String result,
    String? variable,
    String? lowerLimit,
    String? upperLimit,
  }) async {
    final item = HistoryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      expression: expression,
      result: result,
      variable: variable,
      lowerLimit: lowerLimit,
      upperLimit: upperLimit,
      timestamp: DateTime.now(),
    );

    _history.insert(0, item);

    // 限制历史记录数量
    if (_history.length > 100) {
      _history = _history.take(100).toList();
    }

    await _saveHistory();
    notifyListeners();
  }

  /// 删除历史记录
  Future<void> removeHistory(String id) async {
    _history.removeWhere((item) => item.id == id);
    await _saveHistory();
    notifyListeners();
  }

  /// 清空历史记录
  Future<void> clearHistory() async {
    _history.clear();
    await _saveHistory();
    notifyListeners();
  }

  /// 搜索历史记录
  List<HistoryItem> searchHistory(String query) {
    if (query.isEmpty) return _history;

    return _history.where((item) {
      return item.expression.toLowerCase().contains(query.toLowerCase()) ||
          item.result.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }
}

class HistoryItem {
  final String id;
  final CalculationType type;
  final String expression;
  final String result;
  final String? variable;
  final String? lowerLimit;
  final String? upperLimit;
  final DateTime timestamp;

  HistoryItem({
    required this.id,
    required this.type,
    required this.expression,
    required this.result,
    this.variable,
    this.lowerLimit,
    this.upperLimit,
    required this.timestamp,
  });

  /// 从JSON创建
  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id'] as String,
      type: CalculationType.values[json['type'] as int],
      expression: json['expression'] as String,
      result: json['result'] as String,
      variable: json['variable'] as String?,
      lowerLimit: json['lowerLimit'] as String?,
      upperLimit: json['upperLimit'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.index,
      'expression': expression,
      'result': result,
      'variable': variable,
      'lowerLimit': lowerLimit,
      'upperLimit': upperLimit,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// 创建副本
  HistoryItem copyWith({
    String? id,
    CalculationType? type,
    String? expression,
    String? result,
    String? variable,
    String? lowerLimit,
    String? upperLimit,
    DateTime? timestamp,
  }) {
    return HistoryItem(
      id: id ?? this.id,
      type: type ?? this.type,
      expression: expression ?? this.expression,
      result: result ?? this.result,
      variable: variable ?? this.variable,
      lowerLimit: lowerLimit ?? this.lowerLimit,
      upperLimit: upperLimit ?? this.upperLimit,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() {
    return 'HistoryItem(id: $id, type: ${type.displayName}, expression: $expression, result: $result)';
  }
}
