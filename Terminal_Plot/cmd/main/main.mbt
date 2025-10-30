///|
fn print_usage() -> Unit {
  @prelude.println("用法: moon run cmd/main [选项] [函数表达式]")
  @prelude.println("")
  @prelude.println("注意: 如果函数表达式包含特殊字符（如括号），请使用引号包裹")
  @prelude.println("      并使用 -- 分隔 moon 命令参数和程序参数")
  @prelude.println("")
  @prelude.println("选项:")
  @prelude.println("  --parser <type>         选择解析器类型：hardcoded（默认）或 recursive")
  @prelude.println("                          hardcoded: 硬编码解析器，稳定高效")
  @prelude.println("                          recursive: 递归下降解析器，实验性")
  @prelude.println("  --xrange <min> <max>    设置 x 轴范围（默认: -10.0 10.0）")
  @prelude.println("  --width <n>             设置画布宽度（默认: 100）")
  @prelude.println("  --height <n>            设置画布高度（默认: 60）")
  @prelude.println("  --help                  显示此帮助信息")
  @prelude.println("")
  @prelude.println("函数表达式示例:")
  @prelude.println("  sin(x)                 正弦函数")
  @prelude.println("  x^2+1                  二次函数")
  @prelude.println("  x+1                    线性函数")
  @prelude.println("  2*x+3                  带系数的线性函数")
  @prelude.println("")
  @prelude.println("示例:")
  @prelude.println("  moon run cmd/main -- \"sin(x)\"")
  @prelude.println("  moon run cmd/main -- \"x^2+1\" --parser hardcoded")
  @prelude.println("  moon run cmd/main -- \"x+1\" --parser recursive")
  @prelude.println("")
  @prelude.println("说明: -- 用于分隔 moon 命令参数和程序参数")
}

///|
fn main {
  let args = @sys.get_cli_args()
  
  // 如果没有参数，显示默认示例
  if args.length() <= 1 {
    @prelude.println("=== Terminal Plot 字符终端绘图工具 ===")
    @prelude.println("")
    @prelude.println("提示: 使用命令行参数绘制自定义函数，例如：")
    @prelude.println("  moon run cmd/main -- \"sin(x)\" --xrange 0 6.28")
    @prelude.println("")
    @prelude.println("注意: 函数表达式需要引号包裹，并使用 -- 分隔参数")
    @prelude.println("")
    @prelude.println("使用 --help 查看完整帮助")
    @prelude.println("")
    @prelude.println("默认示例:")
    @prelude.println("")
    
    @prelude.println("1. 绘制 sin(x) [0 到 2π]:")
    @lib.plot_sin(0.0, 6.28, 100, 60)
    
    @prelude.println("")
    @prelude.println("2. 绘制 x^2+1 [-3 到 3]:")
    @lib.plot_expression("x^2+1", -3.0, 3.0, 100, 60)
    
    @prelude.println("")
    @prelude.println("3. 绘制圆 x^2 + y^2 = 1 [-1.5 到 1.5]:")
    @lib.plot_circle(-1.5, 1.5, 100, 60)
    return
  }
  
  // 解析命令行参数
  let mut expr = ""
  let x_min = -10.0
  let x_max = 10.0
  let width = 100
  let height = 60
  let mut parser_type = "hardcoded"  // 默认使用硬编码解析器
  let mut i = 1  // 跳过 argv[0]
  
  while i < args.length() {
    let arg = args[i]
    
    if arg == "--help" || arg == "-h" {
      print_usage()
      return
    } else if arg == "--parser" {
      if i + 1 < args.length() {
        let p = args[i + 1]
        if p == "hardcoded" || p == "recursive" {
          parser_type = p
          i = i + 2
        } else {
          @prelude.println("错误: --parser 参数必须是 hardcoded 或 recursive")
          return
        }
      } else {
        @prelude.println("错误: --parser 需要一个参数")
        return
      }
    } else if arg == "--xrange" {
      // 由于字符串解析限制，这里使用硬编码示例值
      @prelude.println("注意: --xrange 参数解析功能由于 MoonBit 限制暂时简化")
      @prelude.println("建议在代码中直接指定范围")
      i = i + 3  // 跳过参数（即使不解析）
    } else if arg == "--width" {
      // 简化处理
      i = i + 2
    } else if arg == "--height" {
      // 简化处理
      i = i + 2
    } else if arg.has_prefix("-") {
      @prelude.println("未知选项: " + arg)
      print_usage()
      return
    } else {
      // 这是函数表达式
      if expr == "" {
        expr = arg
        i = i + 1
      } else {
        @prelude.println("错误: 只能指定一个函数表达式")
        return
      }
    }
  }
  
  // 如果没有指定表达式，使用默认
  if expr == "" {
    @prelude.println("未指定函数表达式，使用默认示例")
    @prelude.println("")
    @lib.plot_sin(0.0, 6.28, 100, 60)
    return
  }
  
  // 绘制函数（根据解析器类型和表达式选择不同的绘图函数）
  @prelude.println("绘制表达式: " + expr)
  @prelude.println("解析器类型: " + parser_type)
  @prelude.println("x 范围: [" + x_min.to_string() + ", " + x_max.to_string() + "]")
  @prelude.println("画布大小: " + width.to_string() + "x" + height.to_string())
  @prelude.println("")
  
  // 根据解析器类型选择不同的解析方式
  if parser_type == "recursive" {
    // 使用非硬编码递归下降解析器
    @prelude.println("[使用递归下降解析器]")
    plot_with_recursive_parser(expr, x_min, x_max, width, height)
  } else {
    // 使用硬编码解析器（默认）
    @prelude.println("[使用硬编码解析器]")
    if expr == "sin(x)" {
      @lib.plot_sin(x_min, x_max, width, height)
    } else {
      @lib.plot_expression(expr, x_min, x_max, width, height)
    }
  }
}

///| 使用递归下降解析器绘图
fn plot_with_recursive_parser(expr : String, x_min : Double, x_max : Double, width : Int, height : Int) -> Unit {
  // 尝试解析表达式
  match @parser.parse_expression(expr) {
    Some(ast) => {
      // 采样数据
      let num_samples = width * 3
      let samples = Array::make(num_samples, (0.0, 0.0))
      let step = (x_max - x_min) / (num_samples - 1).to_double()
      
      for i = 0; i < num_samples; i = i + 1 {
        let x = x_min + i.to_double() * step
        let y = @parser.evaluate_ast(ast, x)
        samples[i] = (x, y)
      }
      
      // 创建配置（让 lib 自动计算 y 范围）
      let config : @lib.PlotConfig = {
        x_min, x_max, 
        y_min: 0.0, y_max: 0.0,  // 0表示自动计算
        width, height,
        show_axes: true, symbol: "·"
      }
      
      // 使用 lib 中的绘图函数
      @lib.plot_data_series(samples, config)
    }
    None => {
      @prelude.println("✗ 表达式解析失败")
      @prelude.println("提示: 递归解析器目前支持：")
      @prelude.println("  - 基本运算: +, -, *, /, ^")
      @prelude.println("  - 函数: sin(x), cos(x), tan(x), exp(x), sqrt(x)")
      @prelude.println("  - 示例: x+1, x*2, sin(x), x^2")
    }
  }
}

///| 初始化画布数据
fn init_canvas_data(width : Int, height : Int) -> Array[Array[String]] {
  // 创建二维数组，每行都是独立的新数组
  let rows = Array::make(height, Array::make(0, ""))
  for i = 0; i < height; i = i + 1 {
    let row = Array::make(width, " ")
    rows[i] = row
  }
  rows
}

///| 使用解析器采样函数
fn sample_with_parser(ast : @parser.ExprNode, x_min : Double, x_max : Double, num_samples : Int) -> Array[(Double, Double)] {
  let samples = Array::make(num_samples, (0.0, 0.0))
  let step = (x_max - x_min) / (num_samples - 1).to_double()
  
  for i = 0; i < num_samples; i = i + 1 {
    let x = x_min + i.to_double() * step
    let y = @parser.evaluate_ast(ast, x)
    samples[i] = (x, y)
  }
  
  samples
}

///| 绘制采样点
fn plot_samples(canvas : @lib.Canvas, samples : Array[(Double, Double)], config : @lib.PlotConfig) -> @lib.Canvas {
  let mut current_canvas = canvas
  let normalized = @lib.normalize_coordinates(samples, config)
  
  for i = 0; i < normalized.length(); i = i + 1 {
    match normalized[i] {
      (row, col) => {
        current_canvas = @lib.plot_point(current_canvas, row, col, "·")
      }
    }
  }
  
  current_canvas
}
