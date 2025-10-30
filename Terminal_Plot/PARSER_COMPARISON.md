# Terminal Plot 解析器对比

本项目提供两种数学表达式解析器，可在终端绘图时选择使用。

## 使用方式

### 选择解析器类型

```bash
# 使用硬编码解析器（默认，推荐）
moon run cmd/main -- "sin(x)" --parser hardcoded

# 使用递归下降解析器（实验性）
moon run cmd/main -- "x+1" --parser recursive

# 不指定 --parser 时默认使用硬编码解析器
moon run cmd/main -- "x^2+1"
```

## 两种解析器对比

### 1. 硬编码解析器（Hardcoded Parser）

**位置**: `cmd/expression_hardcoded/Expression.mbt`

**特点**:
- ✅ **稳定可靠**：经过充分测试，生产环境推荐使用
- ✅ **功能完整**：支持所有常用数学函数和表达式
- ✅ **性能优秀**：直接模式匹配，执行效率高
- ✅ **错误提示友好**：针对常见错误有详细提示

**支持的表达式**:
- 基本运算: `+`, `-`, `*`, `/`, `^`
- 三角函数: `sin(x)`, `cos(x)`, `tan(x)`
- 指数对数: `exp(x)`, `log(x)` (自然对数)
- 其他函数: `sqrt(x)`, `abs(x)`
- 复杂表达式: `x^2+2*x+1`, `sin(x)+cos(x)`, `exp(-x^2)`
- 隐式方程: `x^2+y^2=1` (圆), `y^2+x^2=1.0`

**示例**:
```bash
moon run cmd/main -- "sin(x)" --parser hardcoded
moon run cmd/main -- "x^2+1"
moon run cmd/main -- "exp(-x^2)"
```

### 2. 递归下降解析器（Recursive Descent Parser）

**位置**: `cmd/expression_parser/Parser.mbt`

**特点**:
- 🔬 **实验性**：非硬编码，使用递归下降算法
- ⚠️ **功能受限**：由于 MoonBit 字符串处理限制，支持的表达式有限
- 📚 **教学价值**：展示解析器实现原理（AST、运算符优先级）
- 🚧 **开发中**：可能有未发现的 bug

**支持的表达式**:
- 基本运算: `+`, `-`, `*`, `/`, `^`
- 变量: `x`
- 常见数字: `0`, `1`, `2`, ..., `10`, `0.5`, `1.5`, `3.14`, etc.
- 函数调用: `sin(x)`, `cos(x)`, `tan(x)`, `exp(x)`, `sqrt(x)`
- 简单组合: `x+1`, `x*2`, `x^2`

**限制**:
- ❌ 不支持复杂嵌套表达式
- ❌ 不支持隐式方程
- ❌ 数字解析受限（只支持预定义的常见数字）
- ❌ `sin(x)` 等函数调用解析可能失败

**示例**:
```bash
# ✅ 可以工作
moon run cmd/main -- "x+1" --parser recursive
moon run cmd/main -- "x*2" --parser recursive
moon run cmd/main -- "x^2" --parser recursive

# ❌ 可能失败
moon run cmd/main -- "sin(x)" --parser recursive
moon run cmd/main -- "x^2+2*x+1" --parser recursive
```

## 为什么有两种解析器？

### 硬编码解析器的优势
- 直接使用 MoonBit 的 `has_prefix`, `has_suffix` 等字符串方法
- 通过模式匹配精确识别表达式类型
- 不需要复杂的字符级别操作
- 更适合 MoonBit 当前的字符串 API

### 递归下降解析器的挑战
MoonBit 的字符串处理存在以下限制：
1. `s[i]` 返回 `String` 而非 `Char` 或 `Int`
2. 缺少独立的 `Char` 类型
3. 字符串切片操作 `s[start:end]` 返回 `Result` 类型，需要复杂的错误处理
4. 无法优雅地实现字符级别的递归下降解析

因此，递归下降解析器虽然在理论上更通用，但在 MoonBit 中实现时受到很大限制。

## 推荐使用

**生产环境**: 始终使用 **硬编码解析器**（默认）

**学习研究**: 可以尝试 **递归下降解析器**，了解其实现原理和限制

**绘图需求**: 
- 常用数学函数 → 硬编码解析器
- 简单线性表达式 → 两者皆可
- 复杂嵌套表达式 → 硬编码解析器
- 隐式方程（圆等）→ 硬编码解析器

## 查看帮助

```bash
moon run cmd/main -- --help
```

查看完整的命令行选项和示例。

