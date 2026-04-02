# MathDF Flutter 应用技术设计文档

## 项目概述
通过API接入mathdf.com数学题目解题服务，使用LaTeX渲染结果的Flutter应用。

## 1. 技术栈

### 1.1 核心架构
- **架构模式**: MVVM (Model-View-ViewModel)
- **状态管理**: Provider + ChangeNotifier
- **依赖注入**: 手动注入 + Provider

### 1.2 核心依赖包
```yaml
dependencies:
  flutter:
    sdk: flutter
  # 状态管理
  provider: ^6.1.1
  # HTTP客户端
  dio: ^5.4.0
  # LaTeX渲染
  flutter_tex: ^4.0.5
  # 路由管理
  go_router: ^13.0.0
  # 本地存储（历史记录）
  shared_preferences: ^2.2.2
  # 代码生成
  json_annotation: ^4.8.1
  freezed_annotation: ^2.4.1
  # 工具
  uuid: ^4.2.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  # 代码生成工具
  build_runner: ^2.4.7
  json_serializable: ^6.7.1
  freezed: ^2.4.5
```

### 1.3 项目结构
```
lib/
├── main.dart
├── app.dart
├── config/
│   ├── routes.dart              # 路由配置
│   └── theme.dart               # 主题配置
├── constants/
│   ├── api_constants.dart       # API端点、token等
│   └── app_constants.dart       # 应用常量
├── models/
│   ├── calculation_type.dart    # 计算类型枚举
│   ├── calculation_request.dart # 请求模型
│   └── calculation_result.dart  # 结果模型
├── services/
│   ├── api_service.dart         # 核心API服务
│   ├── encryption_service.dart  # 加密服务
│   └── math_service.dart        # 数学计算服务
├── providers/
│   ├── calculation_provider.dart # 计算状态管理
│   ├── theme_provider.dart      # 主题状态
│   └── history_provider.dart    # 历史记录
├── screens/
│   ├── home/
│   │   ├── home_screen.dart     # 主页
│   │   └── home_viewmodel.dart  # 主页ViewModel
│   ├── calculation/
│   │   ├── calculation_screen.dart # 计算页面
│   │   └── calculation_viewmodel.dart # 计算ViewModel
│   └── history/
│       ├── history_screen.dart  # 历史记录页面
│       └── history_viewmodel.dart # 历史ViewModel
└── widgets/
    ├── input_form.dart          # 输入表单
    ├── result_display.dart      # 结果展示
    ├── calculation_type_selector.dart # 计算类型选择器
    └── latex_display.dart       # LaTeX显示组件
```

## 2. API设计

### 2.1 支持的计算类型
- **积分 (Integrals)**: `/int/calculate.php`
- **方程 (Equations)**: `/equ/calculate.php`
- **极限 (Limits)**: `/lim/calculate.php`
- **导数 (Derivatives)**: `/dif/calculate.php`
- **微分方程 (Differential Equations)**: `/ode/calculate.php`
- **复数 (Complex Numbers)**: `/com/calculate.php`
- **基础计算器 (Basic Calculator)**: `/calc/calculate.php`
- **矩阵 (Matrices)**: `/mat/calculate.php`

### 2.2 请求格式
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

### 2.3 响应格式分析
API返回一个数组，包含计算结果和步骤信息：

```json
[
  [-2,"\\int{\\003\\left(x\\right)\\,\\002\\left(x\\right)}{\\;\\mathrm{d}x}","\\dfrac{\\002^{2}\\left(x\\right)}{2}","sin(x)^2/2",""],
  [-10,2,3,27],
  [-1,["\\int{\\003\\left(x\\right)\\,\\002\\left(x\\right)}{\\;\\mathrm{d}x}"],"0",1],
  [5,[7,"x","\\003\\left(x\\right)\\,\\002\\left(x\\right)","\\002\\left(x\\right)","\\002\\left(x\\right)"],["u=\\002\\left(x\\right)","","\\mathrm{d}u=\\003\\left(x\\right)\\,\\mathrm{d}x",""],"1","\\int{u}{\\;\\mathrm{d}u}","1"],
  [0,[1,"u","1"],"1","\\dfrac{{u}^{2}}{2}",""],
  [11,["u=\\002\\left(x\\right)",""],"\\dfrac{\\002^{2}\\left(x\\right)}{2}","1"]
]
```

**响应结构分析：**
1. **第一个数组**: 最终结果
   - `-2`: 状态码/类型标识
   - `\\int{\\003\\left(x\\right)\\,\\002\\left(x\\right)}{\\;\\mathrm{d}x}`: 原始表达式（LaTeX）
   - `\\dfrac{\\002^{2}\\left(x\\right)}{2}`: 结果表达式（LaTeX）
   - `sin(x)^2/2`: 结果表达式（普通文本）
   - 最后一个元素: 可能是额外信息

2. **第二个数组**: 元数据
   - `-10,2,3,27`: 可能表示步骤数量、类型等信息

3. **后续数组**: 计算步骤
   - 每个步骤包含：步骤类型、输入、操作、输出等

### 2.4 加密机制
```python
def encrypt(a, b):
    g = b''
    for l in range(len(a)):
        g += bytes([ord(a[l]) ^ ord(b[l % len(b)])])
    return g
```
- 使用XOR加密
- 密钥为 `token + 'a'`
- 最终请求体为base64编码的加密数据

## 3. 数据模型

### 3.1 计算类型枚举
```dart
enum CalculationType {
  integral,      // 积分
  equation,      // 方程
  limit,         // 极限
  derivative,    // 导数
  ode,           // 微分方程
  complex,       // 复数
  calculator,    // 基础计算
  matrix,        // 矩阵
}
```

### 3.2 请求模型
```dart
class CalculationRequest {
  final String expr;
  final String arg;
  final String params;
  final String def;
  final String bottom;
  final String top;
  final String token;
  final String lang;
}
```

### 3.3 结果模型
```dart
class CalculationResult {
  final String originalExpr;    // 原始表达式
  final String resultLatex;     // 结果LaTeX
  final String resultText;      // 结果文本
  final List<CalculationStep> steps; // 计算步骤
  final CalculationMetadata metadata; // 元数据
}

class CalculationStep {
  final int type;
  final List<String> input;
  final List<String> operations;
  final String output;
}

class CalculationMetadata {
  final int stepCount;
  final int complexity;
  final int time;
}
```

## 4. UI设计

### 4.1 设计系统
- **设计系统**: Material Design 3
- **主题**: 支持深色/浅色主题切换
- **响应式布局**: 支持全平台（Android、iOS、Web、桌面）

### 4.2 页面流程
1. **主页**: 选择计算类型
2. **计算页面**: 输入表达式，显示结果
3. **历史记录页面**: 查看历史计算

### 4.3 组件设计
- **输入表单**: 支持不同计算类型的输入字段
- **结果展示**: 使用flutter_tex渲染LaTeX结果
- **步骤展示**: 显示详细的计算步骤
- **历史列表**: 显示历史记录

## 5. 状态管理

### 5.1 Provider设计
- **CalculationProvider**: 管理计算状态、结果、错误
- **ThemeProvider**: 管理主题状态
- **HistoryProvider**: 管理历史记录

### 5.2 状态流
1. 用户输入 → 更新Provider状态
2. 状态变更 → 触发UI更新
3. API调用 → 更新结果状态
4. 错误处理 → 更新错误状态

## 6. 实现计划

### 6.1 第一阶段：基础架构
1. 创建Flutter项目
2. 配置依赖
3. 设置项目结构
4. 实现基础模型类

### 6.2 第二阶段：核心服务
1. 实现加密服务
2. 实现API服务
3. 实现计算服务

### 6.3 第三阶段：状态管理
1. 实现Provider
2. 集成状态管理
3. 实现数据绑定

### 6.4 第四阶段：UI实现
1. 实现主页
2. 实现计算页面
3. 实现结果展示
4. 实现历史记录

### 6.5 第五阶段：优化和测试
1. 错误处理
2. 性能优化
3. 测试
4. 打包发布

## 7. 关键功能

### 7.1 计算类型选择
- 支持所有mathdf.com计算类型
- 动态表单生成
- 输入验证

### 7.2 结果展示
- LaTeX渲染
- 步骤显示
- 复制功能

### 7.3 历史记录
- 本地存储
- 搜索功能
- 删除功能

### 7.4 主题切换
- 深色/浅色模式
- 系统主题跟随
- 自定义主题

## 8. 错误处理

### 8.1 网络错误
- 超时处理
- 重试机制
- 离线提示

### 8.2 API错误
- 错误解析
- 用户友好提示
- 日志记录

### 8.3 输入错误
- 实时验证
- 错误提示
- 建议修正

## 9. 性能优化

### 9.1 网络优化
- 请求缓存
- 连接池
- 压缩传输

### 9.2 渲染优化
- 懒加载
- 虚拟列表
- 图片缓存

### 9.3 内存优化
- 对象复用
- 及时释放
- 内存监控

## 10. 安全考虑

### 10.1 数据安全
- 本地加密存储
- 敏感信息保护
- 安全传输

### 10.2 API安全
- Token管理
- 请求签名
- 防重放攻击

## 11. 测试策略

### 11.1 单元测试
- 模型测试
- 服务测试
- 工具类测试

### 11.2 集成测试
- API集成测试
- 状态管理测试
- UI组件测试

### 11.3 端到端测试
- 用户流程测试
- 性能测试
- 兼容性测试

## 12. 部署和发布

### 12.1 构建配置
- 开发环境
- 测试环境
- 生产环境

### 12.2 发布流程
- 版本管理
- 自动化构建
- 应用商店发布

### 12.3 监控和维护
- 崩溃监控
- 性能监控
- 用户反馈
