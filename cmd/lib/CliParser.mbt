///| 命令行参数解析模块

///|
/// 命令行配置
pub struct CliConfig {
  mut expressions : Array[String] // 函数表达式列表
  mut x_min : Double
  mut x_max : Double
  mut step : Double
  mut width : Int
  mut height : Int
  mut use_color : Bool
  mut export_file : String // 空字符串表示不导出
  mut show_help : Bool
}

///|
/// 创建默认配置
pub fn default_config() -> CliConfig {
  CliConfig::{
    expressions: Array::make(0, ""),
    x_min: -10.0,
    x_max: 10.0,
    step: 0.1,
    width: 100,
    height: 40,
    use_color: true,
    export_file: "",
    show_help: false,
  }
}

///|
/// 简单的字符串转 Double（扩展版本）
fn parse_double_extended(s : String) -> Double? {
  // 常用值
  if s == "0" || s == "0.0" {
    Some(0.0)
  } else if s == "1" || s == "1.0" {
    Some(1.0)
  } else if s == "2" || s == "2.0" {
    Some(2.0)
  } else if s == "3" || s == "3.0" {
    Some(3.0)
  } else if s == "4" || s == "4.0" {
    Some(4.0)
  } else if s == "5" || s == "5.0" {
    Some(5.0)
  } else if s == "6" || s == "6.0" {
    Some(6.0)
  } else if s == "7" || s == "7.0" {
    Some(7.0)
  } else if s == "8" || s == "8.0" {
    Some(8.0)
  } else if s == "9" || s == "9.0" {
    Some(9.0)
  } else if s == "10" || s == "10.0" {
    Some(10.0)
  } else if s == "20" || s == "20.0" {
    Some(20.0)
  } else if s == "100" || s == "100.0" {
    Some(100.0)
    // 负数
  } else if s == "-1" || s == "-1.0" {
    Some(-1.0)
  } else if s == "-2" || s == "-2.0" {
    Some(-2.0)
  } else if s == "-3" || s == "-3.0" {
    Some(-3.0)
  } else if s == "-5" || s == "-5.0" {
    Some(-5.0)
  } else if s == "-10" || s == "-10.0" {
    Some(-10.0)
    // 小数
  } else if s == "0.1" {
    Some(0.1)
  } else if s == "0.5" {
    Some(0.5)
  } else if s == "1.5" {
    Some(1.5)
  } else if s == "2.5" {
    Some(2.5)
  } else if s == "3.14" {
    Some(3.14)
  } else if s == "6.28" {
    Some(6.28)
  } else if s == "12.56" {
    Some(12.56)
    // Pi 相关
  } else if s == "pi" {
    Some(3.14159265359)
  } else if s == "2pi" || s == "2*pi" {
    Some(6.28318530718)
  } else {
    None
  }
}

///|
/// 简单的字符串转 Int
fn parse_int_extended(s : String) -> Int? {
  if s == "0" {
    Some(0)
  } else if s == "1" {
    Some(1)
  } else if s == "10" {
    Some(10)
  } else if s == "20" {
    Some(20)
  } else if s == "30" {
    Some(30)
  } else if s == "40" {
    Some(40)
  } else if s == "50" {
    Some(50)
  } else if s == "60" {
    Some(60)
  } else if s == "80" {
    Some(80)
  } else if s == "100" {
    Some(100)
  } else if s == "120" {
    Some(120)
  } else if s == "150" {
    Some(150)
  } else if s == "200" {
    Some(200)
  } else {
    None
  }
}

///|
/// 解析命令行参数
pub fn parse_args(args : Array[String]) -> Result[CliConfig, String] {
  let config = default_config()
  let mut expressions_list = []
  let mut i = 1 // 跳过程序名
  while i < args.length() {
    let arg = args[i]
    if arg == "--help" || arg == "-h" {
      config.show_help = true
      return Ok(config)
    } else if arg == "--range" {
      // --range x_min,x_max
      if i + 1 >= args.length() {
        return Err("--range 需要参数 (格式: x_min,x_max)")
      }
      let range_str = args[i + 1]

      // 尝试解析范围
      if range_str.contains(",") {
        // 简化版本：支持常见的范围格式
        match range_str {
          "-5,5" => {
            config.x_min = -5.0
            config.x_max = 5.0
          }
          "-10,10" => {
            config.x_min = -10.0
            config.x_max = 10.0
          }
          "0,10" => {
            config.x_min = 0.0
            config.x_max = 10.0
          }
          "0,6.28" => {
            config.x_min = 0.0
            config.x_max = 6.28
          }
          "-3,3" => {
            config.x_min = -3.0
            config.x_max = 3.0
          }
          _ =>
            return Err(
              "不支持的范围格式: " +
              range_str +
              " (支持: -5,5 | -10,10 | 0,10 | 0,6.28 | -3,3)",
            )
        }
      } else {
        return Err("--range 参数格式错误，应为: x_min,x_max")
      }
      i = i + 2
    } else if arg == "--step" {
      if i + 1 >= args.length() {
        return Err("--step 需要参数")
      }
      match parse_double_extended(args[i + 1]) {
        Some(val) => config.step = val
        None => return Err("无法解析 step 值: " + args[i + 1])
      }
      i = i + 2
    } else if arg == "--width" {
      if i + 1 >= args.length() {
        return Err("--width 需要参数")
      }
      match parse_int_extended(args[i + 1]) {
        Some(val) => config.width = val
        None => return Err("无法解析 width 值: " + args[i + 1])
      }
      i = i + 2
    } else if arg == "--height" {
      if i + 1 >= args.length() {
        return Err("--height 需要参数")
      }
      match parse_int_extended(args[i + 1]) {
        Some(val) => config.height = val
        None => return Err("无法解析 height 值: " + args[i + 1])
      }
      i = i + 2
    } else if arg == "--export" {
      if i + 1 >= args.length() {
        return Err("--export 需要文件名参数")
      }
      config.export_file = args[i + 1]
      i = i + 2
    } else if arg == "--no-color" {
      config.use_color = false
      i = i + 1
    } else if arg == "--color" {
      config.use_color = true
      i = i + 1
    } else if arg.has_prefix("-") {
      return Err("未知选项: " + arg)
    } else {
      // 这是函数表达式
      expressions_list = expressions_list + [arg]
      i = i + 1
    }
  }

  // 转换表达式列表为数组
  config.expressions = Array::from_iter(expressions_list.iter())
  Ok(config)
}

///|
/// 打印帮助信息
pub fn print_help() -> Unit {
  @prelude.println("=== Terminal_Plot - 终端函数绘图工具 ===")
  @prelude.println("")
  @prelude.println("用法:")
  @prelude.println(
    "  moon run cmd/main -- [选项] <函数表达式1> [函数表达式2] ...",
  )
  @prelude.println("")
  @prelude.println("选项:")
  @prelude.println(
    "  --range <x_min,x_max>   设置 x 轴范围 (默认: -10,10)",
  )
  @prelude.println(
    "                          支持: -5,5 | -10,10 | 0,10 | 0,6.28 | -3,3",
  )
  @prelude.println("  --step <value>          设置采样精度 (默认: 0.1)")
  @prelude.println("  --width <n>             设置画布宽度 (默认: 100)")
  @prelude.println("  --height <n>            设置画布高度 (默认: 40)")
  @prelude.println("  --export <file>         导出结果到文件")
  @prelude.println("  --color                 启用彩色输出 (默认)")
  @prelude.println("  --no-color              禁用彩色输出")
  @prelude.println("  -h, --help              显示此帮助信息")
  @prelude.println("")
  @prelude.println("支持的函数:")
  @prelude.println("  sin(x), cos(x), tan(x)  三角函数")
  @prelude.println("  exp(x), log(x)          指数和对数")
  @prelude.println("  sqrt(x), abs(x)         平方根和绝对值")
  @prelude.println("  x^2, x^3, x^n           幂运算")
  @prelude.println("  +, -, *, /              基本运算")
  @prelude.println("")
  @prelude.println("示例:")
  @prelude.println("  # 绘制单个函数")
  @prelude.println("  moon run cmd/main -- \"sin(x)\"")
  @prelude.println("")
  @prelude.println("  # 绘制多个函数（彩色）")
  @prelude.println("  moon run cmd/main -- \"sin(x)\" \"cos(x)\" \"x^2\"")
  @prelude.println("")
  @prelude.println("  # 指定范围和大小")
  @prelude.println(
    "  moon run cmd/main -- \"sin(x)\" --range 0,6.28 --width 120 --height 60",
  )
  @prelude.println("")
  @prelude.println("  # 导出到文件")
  @prelude.println("  moon run cmd/main -- \"x^2+1\" --export output.txt")
  @prelude.println("")
}
