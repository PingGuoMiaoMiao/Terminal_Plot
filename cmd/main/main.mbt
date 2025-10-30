///|
/// 主入口函数
fn main {
  let args = @sys.get_cli_args()

  // 如果没有参数，显示默认示例
  if args.length() <= 1 {
    show_default_examples()
    return
  }

  // 解析命令行参数
  match @lib.parse_args(args) {
    Ok(config) => {
      if config.show_help {
        @lib.print_help()
        return
      }

      // 检查是否有表达式
      if config.expressions.length() == 0 {
        @prelude.println("错误：未指定函数表达式")
        @prelude.println("使用 --help 查看帮助")
        return
      }

      // 执行绘图
      execute_plot(config)
    }
    Err(msg) => {
      @prelude.println("参数错误: " + msg)
      @prelude.println("使用 --help 查看帮助")
    }
  }
}

///|
/// 显示默认示例
fn show_default_examples() -> Unit {
  @prelude.println("=== Terminal_Plot - 终端函数绘图工具 ===")
  @prelude.println("")
  @prelude.println("提示: 使用命令行参数绘制自定义函数")
  @prelude.println("      moon run cmd/main -- \"sin(x)\" --range 0,6.28")
  @prelude.println("")
  @prelude.println("使用 --help 查看完整帮助")
  @prelude.println("")
  @prelude.println("=== 默认示例 ===")
  @prelude.println("")
  @prelude.println("【示例 1】sin(x) 和 cos(x) 对比 [0 到 2π]:")
  @lib.plot_multiple_expressions(["sin(x)", "cos(x)"], 0.0, 6.28, 100, 30, true)
  @prelude.println("")
  @prelude.println("【示例 2】多项式函数 x^2, x^3 [-2 到 2]:")
  @lib.plot_multiple_expressions(["x^2", "x^3"], -2.0, 2.0, 100, 30, true)
  @prelude.println("")
  @prelude.println("【示例 3】复合函数 sin(x) + x^2 [-3 到 3]:")
  @lib.plot_expression("sin(x)+x^2", -3.0, 3.0, 100, 30)
}

///|
/// 执行绘图
fn execute_plot(config : @lib.CliConfig) -> Unit {
  @prelude.println("=== 绘图配置 ===")
  @prelude.println("函数数量: " + config.expressions.length().to_string())
  @prelude.println(
    "x 范围: [" +
    config.x_min.to_string() +
    ", " +
    config.x_max.to_string() +
    "]",
  )
  @prelude.println(
    "画布大小: " +
    config.width.to_string() +
    " × " +
    config.height.to_string(),
  )
  let color_status = if config.use_color { "是" } else { "否" }
  @prelude.println("彩色输出: " + color_status)
  @prelude.println("")

  // 打印要绘制的函数
  @prelude.println("绘制函数:")
  for i = 0; i < config.expressions.length(); i = i + 1 {
    @prelude.println("  " + (i + 1).to_string() + ". " + config.expressions[i])
  }
  @prelude.println("")

  // 如果只有一个函数，使用单函数绘制
  if config.expressions.length() == 1 {
    let expr = config.expressions[0]

    // 验证表达式
    match @lib.evaluate_expression(expr, 0.0) {
      Some(_) =>
        @lib.plot_expression(
          expr,
          config.x_min,
          config.x_max,
          config.width,
          config.height,
        )
      None => {
        @prelude.println("✗ 错误：无法解析表达式 \"" + expr + "\"")
        @prelude.println("")
        print_supported_functions()
      }
    }
  } else {
    // 多函数绘制
    @lib.plot_multiple_expressions(
      config.expressions,
      config.x_min,
      config.x_max,
      config.width,
      config.height,
      config.use_color,
    )
  }

  // 如果需要导出
  if config.export_file != "" {
    @prelude.println("")
    @prelude.println("注意：导出功能正在开发中")
    @prelude.println("计划导出到: " + config.export_file)
  }
}

///|
/// 打印支持的函数列表
fn print_supported_functions() -> Unit {
  @prelude.println("支持的函数和运算符:")
  @prelude.println("  三角函数: sin(x), cos(x), tan(x), atan(x)")
  @prelude.println("  指数对数: exp(x), log(x)")
  @prelude.println("  其他函数: sqrt(x), abs(x)")
  @prelude.println("  幂运算: x^2, x^3, x^4")
  @prelude.println("  四则运算: +, -, *, /")
  @prelude.println("")
  @prelude.println("示例:")
  @prelude.println("  sin(x)+x^2")
  @prelude.println("  exp(-x^2)")
  @prelude.println("  sqrt(x^2+1)")
  @prelude.println("  x^3-x^2+x")
}

///|
/// 使用递归下降解析器绘图
fn plot_with_recursive_parser(
  expr : String,
  x_min : Double,
  x_max : Double,
  width : Int,
  height : Int,
) -> Unit {
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
        x_min,
        x_max,
        y_min: 0.0,
        y_max: 0.0, // 0表示自动计算
        width,
        height,
        show_axes: true,
        symbol: "·",
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

///|
/// 初始化画布数据
fn init_canvas_data(width : Int, height : Int) -> Array[Array[String]] {
  // 创建二维数组，每行都是独立的新数组
  let rows = Array::make(height, Array::make(0, ""))
  for i = 0; i < height; i = i + 1 {
    let row = Array::make(width, " ")
    rows[i] = row
  }
  rows
}

///|
/// 使用解析器采样函数
fn sample_with_parser(
  ast : @parser.ExprNode,
  x_min : Double,
  x_max : Double,
  num_samples : Int,
) -> Array[(Double, Double)] {
  let samples = Array::make(num_samples, (0.0, 0.0))
  let step = (x_max - x_min) / (num_samples - 1).to_double()
  for i = 0; i < num_samples; i = i + 1 {
    let x = x_min + i.to_double() * step
    let y = @parser.evaluate_ast(ast, x)
    samples[i] = (x, y)
  }
  samples
}

///|
/// 绘制采样点
fn plot_samples(
  canvas : @lib.Canvas,
  samples : Array[(Double, Double)],
  config : @lib.PlotConfig,
) -> @lib.Canvas {
  let mut current_canvas = canvas
  let normalized = @lib.normalize_coordinates(samples, config)
  for i = 0; i < normalized.length(); i = i + 1 {
    match normalized[i] {
      (row, col) =>
        current_canvas = @lib.plot_point(current_canvas, row, col, "·")
    }
  }
  current_canvas
}
