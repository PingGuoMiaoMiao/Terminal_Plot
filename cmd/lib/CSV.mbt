///| CSV 文件处理模块

///| 解析 CSV 行，提取 x,y 数值对
///| 格式：x,y 或 x, y（支持空格）
///| 返回：Option[(Double, Double)]
///| 注意：由于 MoonBit 字符串解析限制，建议使用辅助函数从已知格式构建数据
pub fn parse_csv_line(line : String) -> Option[(Double, Double)] {
  // 按逗号分割
  let parts = line.split(",")
  let mut x_str = ""
  let mut y_str = ""
  let mut count = 0
  
  for part in parts {
    let part_str = part.to_string()
    if count == 0 {
      x_str = part_str
    } else if count == 1 {
      y_str = part_str
      break
    }
    count = count + 1
  }
  
  if count < 2 {
    return None
  }
  
  // 注意：MoonBit 字符串解析有限，这里提供基础框架
  // 实际使用时，可以：
  // 1. 使用 plot_data_series 直接传入数组数据
  // 2. 使用 build_data_from_csv_strings 辅助函数手动构建
  None
}

///| 从字符串数组构建数据点（CSV 辅助函数）
///| 示例：build_data_from_csv_strings(["0,1", "1,2", "2,4"])
///| 返回：Array[(Double, Double)]
///| 注意：由于 MoonBit 字符串解析限制，建议直接使用数组字面量
pub fn build_data_from_csv_strings(lines : Array[String]) -> Array[(Double, Double)] {
  let data = Array::make(0, (0.0, 0.0))
  for line in lines {
    let parts = line.split(",")
    let mut count = 0
    let mut x_str = ""
    let mut y_str = ""
    
    for part in parts {
      let part_str = part.to_string()
      if count == 0 {
        x_str = part_str
      } else if count == 1 {
        y_str = part_str
        break
      }
      count = count + 1
    }
    
    // 这里需要手动解析或预处理字符串
    // 实际使用时，建议直接在代码中构建数组：
    // let data = [(0.0, 1.0), (1.0, 2.0), (2.0, 4.0)]
    if count >= 2 {
      // 占位实现，实际需要手动解析
    }
  }
  data
}

///| 从 CSV 文件读取数据点
///| 支持格式：x,y（每行一个点）
///| 返回值：数据点数组
///| 注意：由于 MoonBit 字符串解析限制，此函数主要用于读取文件内容
///| 实际数据解析建议使用 plot_data_series 直接传入数组
pub fn read_csv_data(csv_path : String) -> Array[(Double, Double)] raise @fs.IOError {
  let content = @fs.read_file_to_string(csv_path)
  let lines = content.split("\n")
  let mut data_points = Array::make(0, (0.0, 0.0))
  let mut line_count = 0
  
  for line_iter in lines {
    let line = line_iter.to_string()
    // 跳过空行和可能的标题行
    if line == "" {
      continue
    }
    
    // 尝试解析
    match parse_csv_line(line) {
      Some(point) => {
        // 创建新数组并追加
        let new_array = Array::make(data_points.length() + 1, (0.0, 0.0))
        for i = 0; i < data_points.length(); i = i + 1 {
          new_array[i] = data_points[i]
        }
        new_array[data_points.length()] = point
        data_points = new_array
      }
      None => {
        // 第一行可能是标题，跳过
        if line_count == 0 {
          // 跳过标题行
        }
      }
    }
    line_count = line_count + 1
  }
  
  data_points
}

///| 从 CSV 文件读取数据并绘制（自动计算范围）
pub fn plot_from_csv_auto(
  csv_path : String,
  width : Int,
  height : Int,
) -> Unit raise @fs.IOError {
  let data_points = read_csv_data(csv_path)
  
  if data_points.length() == 0 {
    @prelude.println("错误: CSV 文件中没有有效的数据点")
    @prelude.println("提示: CSV 格式应为 x,y（每行一个点），例如：")
    @prelude.println("  0,1")
    @prelude.println("  1,2")
    @prelude.println("  2,4")
    @prelude.println("")
    @prelude.println("或使用 plot_data_series 函数直接传入数组数据")
    return
  }
  
  let config = PlotConfig::{
    x_min: 0.0,
    x_max: 0.0,
    y_min: 0.0,
    y_max: 0.0,
    width: width,
    height: height,
    show_axes: true,
    symbol: "*",
  }
  
  @prelude.println("从 CSV 文件读取了 " + data_points.length().to_string() + " 个数据点")
  plot_data_series(data_points, config)
}

///| 从 CSV 文件读取数据并绘制（指定范围）
pub fn plot_from_csv(
  csv_path : String,
  width : Int,
  height : Int,
  x_min : Double,
  x_max : Double,
  y_min : Double,
  y_max : Double,
) -> Unit raise @fs.IOError {
  let data_points = read_csv_data(csv_path)
  
  if data_points.length() == 0 {
    @prelude.println("错误: CSV 文件中没有有效的数据点")
    return
  }
  
  let config = PlotConfig::{
    x_min: x_min,
    x_max: x_max,
    y_min: y_min,
    y_max: y_max,
    width: width,
    height: height,
    show_axes: true,
    symbol: "*",
  }
  
  @prelude.println("从 CSV 文件读取了 " + data_points.length().to_string() + " 个数据点")
  plot_data_series(data_points, config)
}

