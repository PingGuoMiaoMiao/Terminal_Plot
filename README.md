# Terminal_Plot

在终端中绘制数学函数的字符图形工具。

## 🚀 快速开始

### 安装要求
- [MoonBit](https://www.moonbitlang.com/) 编译器

### 运行默认示例
```bash
moon run cmd/main
```

会显示 3 个彩色示例：
- sin(x) 和 cos(x) 对比
- 多项式 x², x³
- 复合函数 sin(x) + x²

## 📖 基本用法

### 绘制单个函数
```bash
moon run cmd/main "sin(x)"
moon run cmd/main "x^2"
moon run cmd/main "exp(-x^2)"
```

### 绘制多个函数（彩色）

✨ **支持多函数同时绘制，用不同颜色和符号区分！**

```bash
# 同时绘制多个函数
moon run cmd/main "sin(x)" "cos(x)"
moon run cmd/main "x" "x^2" "x^3"

# 带参数的多函数绘制
moon run cmd/main -- --range -3,3 "sin(x)" "cos(x)"
```

**特性：**
- 🎨 每个函数用不同颜色显示
- 🔣 每个函数用不同符号标识（·, ○, ×, □, △, ◇）
- 📊 自动生成图例说明
- 🎯 智能采样避免完全覆盖

### 自定义参数（需要使用 `--` 分隔符）
```bash
# 设置 x 轴范围
moon run cmd/main -- "sin(x)" --range 0,6.28

# 设置画布大小
moon run cmd/main -- "x^2" --width 120 --height 60

# 组合使用
moon run cmd/main -- "sin(x)" "cos(x)" --range -5,5 --width 150

# 禁用彩色
moon run cmd/main -- "sin(x)" --no-color
```

> 💡 **提示**: 使用参数时需要在命令后加 `--` 来分隔 moon 的参数和程序参数。

## 🎨 支持的函数

### 基本函数
- **三角函数**: `sin(x)`, `cos(x)`, `tan(x)`, `atan(x)`
- **指数对数**: `exp(x)`, `log(x)`
- **其他**: `sqrt(x)`, `abs(x)`

### 运算符
`+` `-` `*` `/` `^` (加减乘除幂)

### 复合表达式示例
```
sin(x)+x^2          正弦加二次
exp(-x^2)           高斯函数
sqrt(x^2+1)         根式
x^3-x^2+x           多项式
sin(x)*cos(x)       函数乘积
```

## ⚙️ 命令行参数

```bash
--range <x_min,x_max>  # x 轴范围 (默认: -10,10)
                       # 支持: -5,5 | -10,10 | 0,10 | 0,6.28 | -3,3

--width <n>            # 画布宽度 (默认: 100)
--height <n>           # 画布高度 (默认: 40)

--color                # 启用彩色 (默认)
--no-color             # 禁用彩色

--help, -h             # 显示帮助
```

## 📊 示例输出

### 单函数
```
                    |                                              
                  · |                                              
                ··  |                                              
              ··    |                                           ·· 
            ··      |                                         ··   
          ··        |                                       ··     
        ··          |                                     ··       
      ··            |                                   ··         
    ··              |                                 ··           
  ··                |                               ··             
·                   |                             ··               
--------------------+---------------------------------------------·
                    |            ··                                
```

### 多函数（彩色）
不同函数自动使用不同颜色和符号，并显示图例。

## 🛠️ 开发

```bash
# 构建
moon build

# 格式化
moon fmt

# 更新接口
moon info

# 测试
moon test
```

## 📂 项目结构

```
Terminal_Plot/
├── cmd/
│   ├── lib/              # 核心绘图库
│   │   ├── Canvas.mbt    # 字符画布
│   │   ├── Color.mbt     # 彩色输出
│   │   ├── MultiPlot.mbt # 多函数绘制
│   │   ├── CliParser.mbt # 参数解析
│   │   └── ...
│   ├── expression_parser/ # 表达式解析
│   └── main/             # 程序入口
└── moon.mod.json
```

## 💡 常见问题

**Q: 如何绘制多个函数？**  
A: 直接在命令行提供多个表达式：
```bash
moon run cmd/main "sin(x)" "cos(x)" "x^2"
```

**Q: 支持哪些数学函数？**  
A: 三角函数、指数对数、平方根、绝对值，以及它们的组合。

**Q: 如何改变绘图范围？**  
A: 使用 `--range` 参数（注意需要 `--` 分隔符）：
```bash
moon run cmd/main -- "sin(x)" --range 0,6.28
```

**Q: 如何导出图形？**  
A: 使用重定向：
```bash
moon run cmd/main "sin(x)" > output.txt
```

## ⭐ 特性

- ✅ 任意数学函数
- ✅ 多函数同时绘制
- ✅ 彩色终端输出
- ✅ 自动坐标轴
- ✅ 灵活参数控制
- ✅ 模块化设计

## 📝 许可证

Apache-2.0 License

---

**快速开始**: `moon run cmd/main "sin(x)"`
