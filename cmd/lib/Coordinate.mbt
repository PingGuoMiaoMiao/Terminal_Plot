///| 坐标转换模块

///|
/// 坐标归一化 - 将数学坐标映射到画布坐标
pub fn normalize_coordinates(
  points : Array[(Double, Double)],
  config : PlotConfig,
) -> Array[(Int, Int)] {
  let normalized = Array::make(points.length(), (0, 0))
  for i = 0; i < points.length(); i = i + 1 {
    match points[i] {
      (x, y) => {
        // x 坐标映射到列
        let col_float = (x - config.x_min) /
          (config.x_max - config.x_min) *
          (config.width - 1).to_double()
        let col = col_float.floor().to_int()
        let col_clamped = if col < 0 {
          0
        } else if col >= config.width {
          config.width - 1
        } else {
          col
        }

        // y 坐标映射到行（翻转 y 轴）
        let row_float = (y - config.y_min) /
          (config.y_max - config.y_min) *
          (config.height - 1).to_double()
        let row = row_float.floor().to_int()
        let row_clamped = if row < 0 {
          0
        } else if row >= config.height {
          config.height - 1
        } else {
          row
        }
        let normalized_row = config.height - 1 - row_clamped
        normalized[i] = (normalized_row, col_clamped)
      }
    }
  }
  normalized
}

///|
/// 自动计算 y 范围
pub fn auto_y_range(points : Array[(Double, Double)]) -> (Double, Double) {
  if points.length() == 0 {
    (-1.0, 1.0)
  } else {
    let mut y_min = match points[0] {
      (_, y) => y
    }
    let mut y_max = y_min
    for i = 1; i < points.length(); i = i + 1 {
      match points[i] {
        (_, y) => {
          if y < y_min {
            y_min = y
          }
          if y > y_max {
            y_max = y
          }
        }
      }
    }

    // 添加一些边距
    let margin = (y_max - y_min) * 0.1
    (y_min - margin, y_max + margin)
  }
}
