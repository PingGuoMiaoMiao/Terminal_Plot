///| 绘图功能模块

///|
/// 绘制单条曲线
pub fn plot_single_function(func : FunctionType, config : PlotConfig) -> Unit {
  // 创建画布
  let canvas = init_canvas(config.width, config.height)
  let canvas_data = canvas.data

  // 先采样所有点以计算 y 范围
  let points = sample_function(func, config.x_min, config.x_max, config.width)

  // 自动计算 y 范围（如果未指定）
  let (y_min, y_max) = if config.y_min == config.y_max {
    auto_y_range(points)
  } else {
    (config.y_min, config.y_max)
  }

  // 使用更密集的采样来绘制完整的曲线
  // 采样点数是宽度的 3 倍，确保曲线平滑连续，不会有直线段
  let sample_count = config.width * 3
  for i = 0; i < sample_count; i = i + 1 {
    // 计算对应的 x 值 - 确保覆盖整个范围
    let x = if sample_count == 1 {
      config.x_min
    } else {
      config.x_min +
      (config.x_max - config.x_min) *
      i.to_double() /
      (sample_count - 1).to_double()
    }
    let y = match func {
      Sin => @math.sin(x)
      Cos => @math.cos(x)
      Tan => {
        let tan_val = @math.tan(x)
        // 限制 tan 值在合理范围内
        if tan_val > 10.0 {
          10.0
        } else if tan_val < -10.0 {
          -10.0
        } else {
          tan_val
        }
      }
      ArcTan => @math.atan(x)
      Square => x * x
      Linear => x
    }

    // 归一化 y 坐标到行
    let row_float = if y_max == y_min {
      (config.height - 1).to_double() / 2.0
    } else {
      (y - y_min) / (y_max - y_min) * (config.height - 1).to_double()
    }
    let row = row_float.floor().to_int()
    let row_clamped = if row < 0 {
      0
    } else if row >= config.height {
      config.height - 1
    } else {
      row
    }
    let normalized_row = config.height - 1 - row_clamped

    // 归一化 x 坐标到列
    let col_float = if config.x_max == config.x_min {
      (config.width - 1).to_double() / 2.0
    } else {
      (x - config.x_min) /
      (config.x_max - config.x_min) *
      (config.width - 1).to_double()
    }
    let col = col_float.floor().to_int()
    let col_clamped = if col < 0 {
      0
    } else if col >= config.width {
      config.width - 1
    } else {
      col
    }

    // 直接在画布上设置点
    if normalized_row >= 0 &&
      normalized_row < config.height &&
      col_clamped >= 0 &&
      col_clamped < config.width {
      canvas_data[normalized_row][col_clamped] = config.symbol
    }
  }

  // 绘制坐标轴
  if config.show_axes {
    // 计算原点位置
    let zero_x_col = if config.x_max == config.x_min {
      config.width / 2
    } else {
      ((0.0 - config.x_min) /
      (config.x_max - config.x_min) *
      (config.width - 1).to_double())
      .floor()
      .to_int()
    }
    let zero_y_row = if y_max == y_min {
      config.height / 2
    } else {
      ((0.0 - y_min) / (y_max - y_min) * (config.height - 1).to_double())
      .floor()
      .to_int()
    }
    let normalized_zero_y_row = config.height - 1 - zero_y_row

    // 绘制 x 轴
    if normalized_zero_y_row >= 0 && normalized_zero_y_row < config.height {
      for col = 0; col < config.width; col = col + 1 {
        if canvas_data[normalized_zero_y_row][col] == " " {
          canvas_data[normalized_zero_y_row][col] = "-"
        }
      }
    }

    // 绘制 y 轴
    if zero_x_col >= 0 && zero_x_col < config.width {
      for row = 0; row < config.height; row = row + 1 {
        if canvas_data[row][zero_x_col] == " " {
          canvas_data[row][zero_x_col] = "|"
        }
      }
    }

    // 绘制原点
    if zero_x_col >= 0 &&
      zero_x_col < config.width &&
      normalized_zero_y_row >= 0 &&
      normalized_zero_y_row < config.height {
      canvas_data[normalized_zero_y_row][zero_x_col] = "+"
    }
  }

  // 创建画布并输出
  let canvas = Canvas::{
    width: config.width,
    height: config.height,
    data: canvas_data,
  }
  print_canvas(canvas)
}

///|
/// 绘制多条曲线
pub fn plot_multiple_functions(
  funcs : Array[FunctionType],
  symbols : Array[String],
  config : PlotConfig,
) -> Unit {
  let canvas = init_canvas(config.width, config.height)
  let mut result = canvas

  // 收集所有点以计算全局 y 范围
  let all_points = Array::make(funcs.length(), Array::make(0, (0.0, 0.0)))
  let mut global_y_min = 0.0
  let mut global_y_max = 0.0
  let mut first = true
  for i = 0; i < funcs.length(); i = i + 1 {
    let points = sample_function(
      funcs[i],
      config.x_min,
      config.x_max,
      config.width,
    )
    all_points[i] = points
    let (y_min, y_max) = auto_y_range(points)
    if first || y_min < global_y_min {
      global_y_min = y_min
    }
    if first || y_max > global_y_max {
      global_y_max = y_max
    }
    first = false
  }
  let final_config = PlotConfig::{
    x_min: config.x_min,
    x_max: config.x_max,
    y_min: global_y_min,
    y_max: global_y_max,
    width: config.width,
    height: config.height,
    show_axes: config.show_axes,
    symbol: config.symbol,
  }

  // 绘制坐标轴
  if config.show_axes {
    result = draw_axes(result, final_config)
  }

  // 绘制每条曲线
  for i = 0; i < funcs.length(); i = i + 1 {
    let symbol = if i < symbols.length() { symbols[i] } else { "*" }
    let normalized_points = normalize_coordinates(all_points[i], final_config)
    for j = 0; j < normalized_points.length(); j = j + 1 {
      match normalized_points[j] {
        (row, col) => result = plot_point(result, row, col, symbol)
      }
    }
  }
  print_canvas(result)
}

///|
/// 绘制数据序列（数组输入）
pub fn plot_data_series(
  data : Array[(Double, Double)],
  config : PlotConfig,
) -> Unit {
  let canvas = init_canvas(config.width, config.height)
  let mut result = canvas

  // 自动计算范围
  let (x_min, x_max) = if config.x_min == config.x_max {
    let mut min_x = match data[0] {
      (x, _) => x
    }
    let mut max_x = min_x
    for i = 1; i < data.length(); i = i + 1 {
      match data[i] {
        (x, _) => {
          if x < min_x {
            min_x = x
          }
          if x > max_x {
            max_x = x
          }
        }
      }
    }
    (min_x, max_x)
  } else {
    (config.x_min, config.x_max)
  }
  let (y_min, y_max) = if config.y_min == config.y_max {
    auto_y_range(data)
  } else {
    (config.y_min, config.y_max)
  }
  let final_config = PlotConfig::{
    x_min,
    x_max,
    y_min,
    y_max,
    width: config.width,
    height: config.height,
    show_axes: config.show_axes,
    symbol: config.symbol,
  }

  // 归一化坐标
  let normalized_points = normalize_coordinates(data, final_config)

  // 绘制坐标轴
  if config.show_axes {
    result = draw_axes(result, final_config)
  }

  // 绘制数据点
  for i = 0; i < normalized_points.length(); i = i + 1 {
    match normalized_points[i] {
      (row, col) => result = plot_point(result, row, col, config.symbol)
    }
  }
  print_canvas(result)
}

///|
/// 便捷函数 - 绘制正弦函数
pub fn plot_sin(
  x_min : Double,
  x_max : Double,
  width : Int,
  height : Int,
) -> Unit {
  let config = PlotConfig::{
    x_min,
    x_max,
    y_min: -1.0,
    y_max: 1.0,
    width,
    height,
    show_axes: true,
    symbol: "·",
  }
  plot_single_function(Sin, config)
}

///|
/// 便捷函数 - 绘制余弦函数
pub fn plot_cos(
  x_min : Double,
  x_max : Double,
  width : Int,
  height : Int,
) -> Unit {
  let config = PlotConfig::{
    x_min,
    x_max,
    y_min: -1.0,
    y_max: 1.0,
    width,
    height,
    show_axes: true,
    symbol: "·",
  }
  plot_single_function(Cos, config)
}

///|
/// 便捷函数 - 绘制正切函数
pub fn plot_tan(
  x_min : Double,
  x_max : Double,
  width : Int,
  height : Int,
) -> Unit {
  let config = PlotConfig::{
    x_min,
    x_max,
    y_min: -10.0,
    y_max: 10.0,
    width,
    height,
    show_axes: true,
    symbol: "*",
  }
  plot_single_function(Tan, config)
}

///|
/// 便捷函数 - 绘制反正切函数
pub fn plot_arctan(
  x_min : Double,
  x_max : Double,
  width : Int,
  height : Int,
) -> Unit {
  let config = PlotConfig::{
    x_min,
    x_max,
    y_min: -2.0,
    y_max: 2.0,
    width,
    height,
    show_axes: true,
    symbol: "#",
  }
  plot_single_function(ArcTan, config)
}

///|
/// 便捷函数 - 绘制平方函数
pub fn plot_square(
  x_min : Double,
  x_max : Double,
  width : Int,
  height : Int,
) -> Unit {
  let config = PlotConfig::{
    x_min,
    x_max,
    y_min: 0.0,
    y_max: 0.0,
    width,
    height,
    show_axes: true,
    symbol: "#",
  }
  plot_single_function(Square, config)
}

///|
/// 便捷函数 - 绘制线性函数
pub fn plot_line(
  x_min : Double,
  x_max : Double,
  width : Int,
  height : Int,
) -> Unit {
  let config = PlotConfig::{
    x_min,
    x_max,
    y_min: 0.0,
    y_max: 0.0,
    width,
    height,
    show_axes: true,
    symbol: "o",
  }
  plot_single_function(Linear, config)
}
