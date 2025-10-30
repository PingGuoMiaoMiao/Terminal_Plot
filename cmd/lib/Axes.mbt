///| 坐标轴绘制模块

///|
/// 绘制坐标轴（带刻度）
pub fn draw_axes(canvas : Canvas, config : PlotConfig) -> Canvas {
  // 创建新的数据数组
  let new_data = Array::make(canvas.height, Array::make(canvas.width, " "))

  // 复制原有数据
  for i = 0; i < canvas.height; i = i + 1 {
    for j = 0; j < canvas.width; j = j + 1 {
      new_data[i][j] = canvas.data[i][j]
    }
  }

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
  let zero_y_row = if config.y_max == config.y_min {
    config.height / 2
  } else {
    ((0.0 - config.y_min) /
    (config.y_max - config.y_min) *
    (config.height - 1).to_double())
    .floor()
    .to_int()
  }

  // 绘制 x 轴
  if zero_y_row >= 0 && zero_y_row < config.height {
    for col = 0; col < config.width; col = col + 1 {
      if new_data[zero_y_row][col] == " " {
        new_data[zero_y_row][col] = "-"
      }
    }
  }

  // 绘制 y 轴
  if zero_x_col >= 0 && zero_x_col < config.width {
    for row = 0; row < config.height; row = row + 1 {
      if new_data[row][zero_x_col] == " " {
        new_data[row][zero_x_col] = "|"
      }
    }
  }

  // 绘制原点
  if zero_x_col >= 0 &&
    zero_x_col < config.width &&
    zero_y_row >= 0 &&
    zero_y_row < config.height {
    new_data[zero_y_row][zero_x_col] = "+"
  }

  // 添加 x 轴刻度标注（每 10 列一个刻度）
  let x_step = (config.x_max - config.x_min) / 10.0
  for i = 0; i <= 10; i = i + 1 {
    let x_val = config.x_min + x_step * i.to_double()
    let col = ((x_val - config.x_min) /
      (config.x_max - config.x_min) *
      (config.width - 1).to_double())
      .floor()
      .to_int()
    if col >= 0 &&
      col < config.width &&
      zero_y_row >= 0 &&
      zero_y_row < config.height {
      new_data[zero_y_row][col] = "+"
    }
  }

  // 添加 y 轴刻度标注（每 10 行一个刻度）
  let y_step = (config.y_max - config.y_min) / 10.0
  for i = 0; i <= 10; i = i + 1 {
    let y_val = config.y_min + y_step * i.to_double()
    let row = ((y_val - config.y_min) /
      (config.y_max - config.y_min) *
      (config.height - 1).to_double())
      .floor()
      .to_int()
    let normalized_row = config.height - 1 - row
    if normalized_row >= 0 &&
      normalized_row < config.height &&
      zero_x_col >= 0 &&
      zero_x_col < config.width {
      new_data[normalized_row][zero_x_col] = "+"
    }
  }
  Canvas::{ width: canvas.width, height: canvas.height, data: new_data }
}
