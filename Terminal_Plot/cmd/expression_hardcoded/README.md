# Expression Hardcoded

## 硬编码表达式解析器

这是 **硬编码版本** 的表达式解析器，使用模式匹配方式解析数学表达式。

### 特点

- ✅ 使用模式匹配，性能好
- ✅ 支持常见的数学表达式
- ✅ 易于维护和扩展
- ⚠️ 每个新表达式需要手动添加模式匹配

### 支持的表达式

**基本函数：**
- `sin(x)`, `cos(x)`, `tan(x)`, `atan(x)`
- `exp(x)`, `log(x)`, `sqrt(x)`, `abs(x)`

**运算符：**
- `+`, `-`, `*`, `/`, `^`

**复合表达式：**
- `sin(x) + x^2`
- `exp(-x^2)`
- `x^2 + cos(x) * 2`
- `sqrt(x^2+1)`
- 等等...

### 使用方式

```moonbit
use expression_hardcoded : { evaluate_expression }

fn main {
  match evaluate_expression("sin(x)", 1.57) {
    Some(result) => @prelude.println(result.to_string())
    None => @prelude.println("解析失败")
  }
}
```

### 优势

- 简单直观
- 编译时检查
- 性能优秀
- 易于调试

### 劣势

- 不支持动态表达式
- 需要手动添加新模式
- 不适合复杂表达式
