///| 终端彩色输出模块

///| 提供 ANSI 转义序列支持

///|
/// ANSI 颜色代码
pub enum AnsiColor {
  Black
  Red
  Green
  Yellow
  Blue
  Magenta
  Cyan
  White
  BrightRed
  BrightGreen
  BrightYellow
  BrightBlue
  BrightMagenta
  BrightCyan
  BrightWhite
  Reset
} derive(Eq)

///|
/// 获取 ANSI 颜色代码
pub fn color_code(color : AnsiColor) -> String {
  match color {
    Black => "\u{001b}[30m"
    Red => "\u{001b}[31m"
    Green => "\u{001b}[32m"
    Yellow => "\u{001b}[33m"
    Blue => "\u{001b}[34m"
    Magenta => "\u{001b}[35m"
    Cyan => "\u{001b}[36m"
    White => "\u{001b}[37m"
    BrightRed => "\u{001b}[91m"
    BrightGreen => "\u{001b}[92m"
    BrightYellow => "\u{001b}[93m"
    BrightBlue => "\u{001b}[94m"
    BrightMagenta => "\u{001b}[95m"
    BrightCyan => "\u{001b}[96m"
    BrightWhite => "\u{001b}[97m"
    Reset => "\u{001b}[0m"
  }
}

///|
/// 使用颜色包装文本
pub fn colorize(text : String, color : AnsiColor) -> String {
  color_code(color) + text + color_code(Reset)
}

///|
/// 彩色画布结构
pub struct ColorCanvas {
  width : Int
  height : Int
  data : Array[Array[String]] // 存储字符
  colors : Array[Array[AnsiColor]] // 存储颜色信息
}

///|
/// 初始化彩色画布
pub fn init_color_canvas(width : Int, height : Int) -> ColorCanvas {
  let rows = Array::make(height, Array::make(0, ""))
  let color_rows = Array::make(height, Array::make(0, Reset))
  for i = 0; i < height; i = i + 1 {
    rows[i] = Array::make(width, " ")
    color_rows[i] = Array::make(width, Reset)
  }
  ColorCanvas::{ width, height, data: rows, colors: color_rows }
}

///|
/// 在彩色画布上绘制一个点
pub fn plot_color_point(
  canvas : ColorCanvas,
  row : Int,
  col : Int,
  symbol : String,
  color : AnsiColor,
) -> ColorCanvas {
  if row >= 0 && row < canvas.height && col >= 0 && col < canvas.width {
    let new_data = Array::make(canvas.height, Array::make(canvas.width, " "))
    let new_colors = Array::make(
      canvas.height,
      Array::make(canvas.width, Reset),
    )

    // 复制原有数据
    for i = 0; i < canvas.height; i = i + 1 {
      for j = 0; j < canvas.width; j = j + 1 {
        new_data[i][j] = canvas.data[i][j]
        new_colors[i][j] = canvas.colors[i][j]
      }
    }

    // 直接覆盖（通过颜色和符号区分不同函数）
    new_data[row][col] = symbol
    new_colors[row][col] = color
    ColorCanvas::{
      width: canvas.width,
      height: canvas.height,
      data: new_data,
      colors: new_colors,
    }
  } else {
    canvas
  }
}

///|
/// 输出彩色画布到终端
pub fn print_color_canvas(canvas : ColorCanvas) -> Unit {
  for i = 0; i < canvas.height; i = i + 1 {
    let mut line = ""
    let mut current_color = Reset
    for j = 0; j < canvas.width; j = j + 1 {
      let char = canvas.data[i][j]
      let color = canvas.colors[i][j]

      // 如果颜色改变，添加颜色代码
      if color != current_color {
        line = line + color_code(color)
        current_color = color
      }
      line = line + char
    }

    // 重置颜色
    if current_color != Reset {
      line = line + color_code(Reset)
    }
    @prelude.println(line)
  }
}

///|
/// 获取预定义的颜色方案（用于多函数绘制）
pub fn get_plot_colors() -> Array[AnsiColor] {
  [BrightRed, BrightGreen, BrightBlue, BrightYellow, BrightMagenta, BrightCyan]
}

///|
/// 获取第 n 个绘图颜色（循环使用）
pub fn get_nth_color(n : Int) -> AnsiColor {
  let colors = get_plot_colors()
  colors[n % colors.length()]
}
