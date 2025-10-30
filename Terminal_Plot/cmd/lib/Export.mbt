///| 文件导出模块

///| 将画布导出到文件
pub fn export_canvas_to_file(canvas : Canvas, filepath : String) -> Unit raise @fs.IOError {
  let content = canvas_to_string(canvas)
  @fs.write_string_to_file(filepath, content)
}

///| 绘制并保存到文件（单函数）
pub fn plot_and_save(
  func : FunctionType,
  config : PlotConfig,
  output_file : String,
) -> Unit raise @fs.IOError {
  let canvas = init_canvas(config.width, config.height)
  let mut result = canvas

  // 采样函数
  let points = sample_function(func, config.x_min, config.x_max, config.width)
  
  // 自动计算 y 范围
  let (y_min, y_max) = if config.y_min == config.y_max {
    auto_y_range(points)
  } else {
    (config.y_min, config.y_max)
  }

  let final_config = PlotConfig::{
    x_min: config.x_min,
    x_max: config.x_max,
    y_min: y_min,
    y_max: y_max,
    width: config.width,
    height: config.height,
    show_axes: config.show_axes,
    symbol: config.symbol,
  }

  // 归一化坐标
  let normalized_points = normalize_coordinates(points, final_config)
  
  // 绘制坐标轴
  if config.show_axes {
    result = draw_axes(result, final_config)
  }
  
  // 绘制函数点
  for i = 0; i < normalized_points.length(); i = i + 1 {
    match normalized_points[i] {
      (row, col) => result = plot_point(result, row, col, config.symbol)
    }
  }
  
  // 导出到文件
  export_canvas_to_file(result, output_file)
  @prelude.println("图表已保存到: " + output_file)
}

