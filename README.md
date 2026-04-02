# MathDF - 数学计算器 Flutter 应用

通过 API 接入 [mathdf.com](https://mathdf.com) 数学题目解题服务，使用 LaTeX 渲染结果的 Flutter 应用。
## 介绍(周末玩具)
这个项目大概只是一个玩具，用ai花了一天时间研究了一下，感觉还是有点没用了。跟ai大人比，大概没有任何用武之地吧。

不过，还是实现了些关键的功能，比如自动获取mathdf中的session 和加密参数用的token以及没有什么特别作用的ocr识别功能，识别速度慢不说，然后只只在linux 平台上进行了测试，Android windows都没有测试过。并且识别的话，精确率对于和非一点的那根本不行，识别出来的也不能直接使用(哈哈哈),因为mathdf的接口只要函数本地而不是完整的latxt，额，所以就只能这样了。
仅仅测试了积分、极限、微分、求导，方程，矩阵没有做

然后呢，模型与代码参考来自[RapidLaTeXOCR](https://github.com/RapidAI/RapidLaTeXOCR)
## 功能特性

### 已实现
- ✅ **积分计算** - 支持不定积分和定积分
- ✅ **LaTeX 渲染** - 使用 flutter_math_fork 渲染数学公式
- ✅ **步骤展示** - 显示详细的计算步骤
- ✅ **深色/浅色主题** - 支持主题切换
- ✅ **历史记录** - 本地保存计算历史
- ✅ **全平台支持** - Android、iOS、Web、Linux、macOS、Windows

### 计划中
- ⬜ 导数计算
- ⬜ 方程求解
- ⬜ 极限计算
- ⬜ 矩阵运算
- ⬜ 离线 OCR 识别
- ⬜ 拍照搜题
- ⬜ 手写输入

## 技术栈

| 组件 | 技术选型 |
|------|----------|
| 框架 | Flutter 3.x |
| 状态管理 | Provider |
| HTTP 客户端 | Dio |
| LaTeX 渲染 | flutter_math_fork |
| 本地存储 | SharedPreferences |
| 路由管理 | GoRouter |

## 项目结构

```
lib/
├── main.dart                      # 应用入口
├── app.dart                       # 应用配置
├── config/
│   └── theme.dart                 # 主题配置
├── constants/
│   └── api_constants.dart         # API 常量
├── models/
│   ├── calculation_type.dart      # 计算类型枚举
│   ├── calculation_request.dart   # 请求模型
│   ├── calculation_result.dart    # 结果模型
│   └── calculation_step.dart      # 步骤模型
├── services/
│   ├── api_service.dart           # API 服务
│   └── encryption_service.dart    # 加密服务
├── providers/
│   ├── calculation_provider.dart  # 计算状态
│   ├── theme_provider.dart        # 主题状态
│   └── history_provider.dart      # 历史记录
├── screens/
│   ├── home/
│   │   └── home_screen.dart       # 主页
│   └── calculation/
│       └── calculation_screen.dart # 计算页面
└── widgets/
    ├── input_form.dart            # 输入表单
    ├── result_display.dart        # 结果展示
    └── latex_display.dart         # LaTeX 显示
```

## 快速开始

### 环境要求
- Flutter SDK >= 3.11.0
- Dart SDK >= 3.11.0

### 安装依赖
```bash
flutter pub get
```

### 运行应用
```bash
# Android
flutter run -d android

# iOS
flutter run -d ios

# Web
flutter run -d chrome

# Linux
flutter run -d linux

# macOS
flutter run -d macos

# Windows
flutter run -d windows
```

### 运行测试
```bash
# 运行所有测试
flutter test

# 运行特定测试
flutter test test/services/api_service_test.dart
```

## API 说明

### 请求格式
```json
{
  "expr": "sin(x)*cos(x)",
  "arg": "x",
  "params": "expandtable=false",
  "def": "0",
  "bottom": "",
  "top": "",
  "token": "98ae9979efca566d",
  "lang": "en"
}
```

### 响应格式
```json
[
  [-2, "\\int{\\sin(x)}{dx}", "-\\cos(x)", "-cos(x)", ""],
  [-10, 2, 3, 27],
  [-1, ["\\int{\\sin(x)}{dx}"], "0", 1],
  [0, [0], "1", "-\\cos(x)", ""]
]
```

### 占位符说明
API 返回的 LaTeX 中使用占位符，需要替换：
| 占位符 | 替换为 |
|--------|--------|
| `\002` | `\sin` |
| `\003` | `\cos` |
| `\004` | `\tan` |
| `\005` | `\cot` |
| `\006` | `\sec` |
| `\007` | `\csc` |
| `\016` | `\ln` |
| `\017` | `\log` |
| `\020` | `\exp` |
| `\021` | `\sqrt` |



## 许可证

本项目仅供学习交流使用，请勿用于商业用途。

## 致谢

- [mathdf.com](https://mathdf.com) - 提供数学计算 API
- [flutter_math_fork](https://pub.dev/packages/flutter_math_fork) - LaTeX 渲染
- [Dio](https://pub.dev/packages/dio) - HTTP 客户端
- [Provider](https://pub.dev/packages/provider) - 状态管理
