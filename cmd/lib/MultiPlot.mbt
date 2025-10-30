///| 多函数绘制模块

///|
/// 函数表达式包装器
pub struct FunctionExpr {
  expr : String
  symbol : String
  color : AnsiColor
}

///|
/// 创建函数表达式
pub fn make_function_expr(
  expr : String,
  symbol : String,
  color : AnsiColor,
) -> FunctionExpr {
  FunctionExpr::{ expr, symbol, color }
}

///|
/// 绘制多个表达式（彩色版本）
pub fn plot_multiple_expressions(
  expressions : Array[String],
  x_min : Double,
  x_max : Double,
  width : Int,
  height : Int,
  use_color : Bool,
) -> Unit {
  if expressions.length() == 0 {
    @prelude.println("错误：没有提供表达式")
    return
  }

  // 为每个函数准备符号和颜色
  let symbols = ["·", "○", "×", "□", "△", "◇"]
  let func_exprs = Array::make(
    expressions.length(),
    make_function_expr("", "", Reset),
  )
  for i = 0; i < expressions.length(); i = i + 1 {
    let symbol = symbols[i % symbols.length()]
    let color = get_nth_color(i)
    func_exprs[i] = make_function_expr(expressions[i], symbol, color)
  }

  // 首先采样所有函数，计算全局 y 范围
  let all_samples = Array::make(
    expressions.length(),
    Array::make(0, (0.0, 0.0)),
  )
  let mut global_y_min = 0.0
  let mut global_y_max = 0.0
  let mut first = true
  // 多函数绘图时使用较低的采样密度，为不同函数留出显示空间
  // 基础采样点数量
  let base_sample_count = width / 3
  let sample_count = base_sample_count
  
  for i = 0; i < expressions.length(); i = i + 1 {
    let expr = expressions[i]
    let samples = Array::make(sample_count, (0.0, 0.0))
    let mut valid_count = 0
    
    // 为每个函数计算一个小的 x 偏移，让采样点错开
    // 偏移量 = (i / 函数总数) * (一个采样间隔)
    let x_range = x_max - x_min
    let sample_interval = if sample_count > 1 {
      x_range / (sample_count - 1).to_double()
    } else {
      0.0
    }
    let x_offset = if expressions.length() > 1 {
      sample_interval * i.to_double() / expressions.length().to_double()
    } else {
      0.0
    }
    
    for j = 0; j < sample_count; j = j + 1 {
      let x_base = if sample_count == 1 {
        x_min
      } else {
        x_min + x_range * j.to_double() / (sample_count - 1).to_double()
      }
      // 添加偏移，让不同函数的采样点错开
      let x = x_base + x_offset
      match evaluate_expression(expr, x) {
        Some(y) => {
          samples[j] = (x, y)
          valid_count = valid_count + 1
          if first {
            global_y_min = y
            global_y_max = y
            first = false
          } else {
            if y < global_y_min {
              global_y_min = y
            }
            if y > global_y_max {
              global_y_max = y
            }
          }
        }
        None => samples[j] = (x, 0.0) // 无效点
      }
    }
    all_samples[i] = samples
    if valid_count == 0 {
      @prelude.println(
        "警告：表达式 \"" + expr + "\" 没有有效的采样点",
      )
    }
  }

  // 添加边距
  let margin = if global_y_max == global_y_min {
    1.0
  } else {
    (global_y_max - global_y_min) * 0.1
  }
  let y_min_final = global_y_min - margin
  let y_max_final = global_y_max + margin

  // 创建画布
  if use_color {
    let mut canvas = init_color_canvas(width, height)

    // 先绘制坐标轴
    canvas = draw_color_axes(canvas, x_min, x_max, y_min_final, y_max_final)

    // 从最后一个函数开始绘制，第一个函数最后绘制（在最上层）
    for i = expressions.length() - 1; i >= 0; i = i - 1 {
      let func_expr = func_exprs[i]
      let samples = all_samples[i]
      for j = 0; j < samples.length(); j = j + 1 {
        match samples[j] {
          (x, y) =>
            if y != 0.0 ||
              not(evaluate_expression(expressions[i], x).is_empty()) {
              let row_float = if y_max_final == y_min_final {
                (height - 1).to_double() / 2.0
              } else {
                (y - y_min_final) /
                (y_max_final - y_min_final) *
                (height - 1).to_double()
              }
              let row = row_float.floor().to_int()
              let row_clamped = if row < 0 {
                0
              } else if row >= height {
                height - 1
              } else {
                row
              }
              let normalized_row = height - 1 - row_clamped
              let col_float = if x_max == x_min {
                (width - 1).to_double() / 2.0
              } else {
                (x - x_min) / (x_max - x_min) * (width - 1).to_double()
              }
              let col = col_float.floor().to_int()
              let col_clamped = if col < 0 {
                0
              } else if col >= width {
                width - 1
              } else {
                col
              }
              if normalized_row >= 0 &&
                normalized_row < height &&
                col_clamped >= 0 &&
                col_clamped < width {
                canvas = plot_color_point(
                  canvas,
                  normalized_row,
                  col_clamped,
                  func_expr.symbol,
                  func_expr.color,
                )
              }
            }
        }
      }
    }
    print_color_canvas(canvas)
  } else {
    // 黑白版本
    let canvas = init_canvas(width, height)
    let canvas_data = canvas.data

    // 先绘制坐标轴
    draw_axes_on_data(
      canvas_data, width, height, x_min, x_max, y_min_final, y_max_final,
    )

    // 从最后一个函数开始绘制，第一个函数最后绘制（在最上层）
    for i = expressions.length() - 1; i >= 0; i = i - 1 {
      let func_expr = func_exprs[i]
      let samples = all_samples[i]
      for j = 0; j < samples.length(); j = j + 1 {
        match samples[j] {
          (x, y) =>
            if y != 0.0 ||
              not(evaluate_expression(expressions[i], x).is_empty()) {
              let row_float = if y_max_final == y_min_final {
                (height - 1).to_double() / 2.0
              } else {
                (y - y_min_final) /
                (y_max_final - y_min_final) *
                (height - 1).to_double()
              }
              let row = row_float.floor().to_int()
              let row_clamped = if row < 0 {
                0
              } else if row >= height {
                height - 1
              } else {
                row
              }
              let normalized_row = height - 1 - row_clamped
              let col_float = if x_max == x_min {
                (width - 1).to_double() / 2.0
              } else {
                (x - x_min) / (x_max - x_min) * (width - 1).to_double()
              }
              let col = col_float.floor().to_int()
              let col_clamped = if col < 0 {
                0
              } else if col >= width {
                width - 1
              } else {
                col
              }
              if normalized_row >= 0 &&
                normalized_row < height &&
                col_clamped >= 0 &&
                col_clamped < width {
                canvas_data[normalized_row][col_clamped] = func_expr.symbol
              }
            }
        }
      }
    }
    let final_canvas = Canvas::{ width, height, data: canvas_data }
    print_canvas(final_canvas)
  }

  // 打印图例
  @prelude.println("")
  @prelude.println("图例：")
  for i = 0; i < expressions.length(); i = i + 1 {
    let func_expr = func_exprs[i]
    if use_color {
      let colored_symbol = colorize(func_expr.symbol, func_expr.color)
      @prelude.println("  " + colored_symbol + " : " + func_expr.expr)
    } else {
      @prelude.println("  " + func_expr.symbol + " : " + func_expr.expr)
    }
  }
}

///|
/// 在彩色画布上绘制坐标轴
fn draw_color_axes(
  canvas : ColorCanvas,
  x_min : Double,
  x_max : Double,
  y_min : Double,
  y_max : Double,
) -> ColorCanvas {
  let mut result = canvas
  let width = canvas.width
  let height = canvas.height

  // 计算原点位置
  let zero_x_col = if x_max == x_min {
    width / 2
  } else {
    ((0.0 - x_min) / (x_max - x_min) * (width - 1).to_double()).floor().to_int()
  }
  let zero_y_row = if y_max == y_min {
    height / 2
  } else {
    ((0.0 - y_min) / (y_max - y_min) * (height - 1).to_double())
    .floor()
    .to_int()
  }
  let normalized_zero_y_row = height - 1 - zero_y_row

  // 绘制 x 轴
  if normalized_zero_y_row >= 0 && normalized_zero_y_row < height {
    for col = 0; col < width; col = col + 1 {
      if result.data[normalized_zero_y_row][col] == " " {
        result = plot_color_point(
          result,
          normalized_zero_y_row,
          col,
          "-",
          White,
        )
      }
    }
  }

  // 绘制 y 轴
  if zero_x_col >= 0 && zero_x_col < width {
    for row = 0; row < height; row = row + 1 {
      if result.data[row][zero_x_col] == " " {
        result = plot_color_point(result, row, zero_x_col, "|", White)
      }
    }
  }

  // 绘制原点
  if zero_x_col >= 0 &&
    zero_x_col < width &&
    normalized_zero_y_row >= 0 &&
    normalized_zero_y_row < height {
    result = plot_color_point(
      result,
      normalized_zero_y_row,
      zero_x_col,
      "+",
      White,
    )
  }
  result
}

///|
/// 在数据数组上直接绘制坐标轴
fn draw_axes_on_data(
  data : Array[Array[String]],
  width : Int,
  height : Int,
  x_min : Double,
  x_max : Double,
  y_min : Double,
  y_max : Double,
) -> Unit {
  let zero_x_col = if x_max == x_min {
    width / 2
  } else {
    ((0.0 - x_min) / (x_max - x_min) * (width - 1).to_double()).floor().to_int()
  }
  let zero_y_row = if y_max == y_min {
    height / 2
  } else {
    ((0.0 - y_min) / (y_max - y_min) * (height - 1).to_double())
    .floor()
    .to_int()
  }
  let normalized_zero_y_row = height - 1 - zero_y_row

  // 绘制 x 轴
  if normalized_zero_y_row >= 0 && normalized_zero_y_row < height {
    for col = 0; col < width; col = col + 1 {
      if data[normalized_zero_y_row][col] == " " {
        data[normalized_zero_y_row][col] = "-"
      }
    }
  }

  // 绘制 y 轴
  if zero_x_col >= 0 && zero_x_col < width {
    for row = 0; row < height; row = row + 1 {
      if data[row][zero_x_col] == " " {
        data[row][zero_x_col] = "|"
      }
    }
  }

  // 绘制原点
  if zero_x_col >= 0 &&
    zero_x_col < width &&
    normalized_zero_y_row >= 0 &&
    normalized_zero_y_row < height {
    data[normalized_zero_y_row][zero_x_col] = "+"
  }
}
