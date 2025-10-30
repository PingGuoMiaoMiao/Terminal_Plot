///| 画布管理模块

///|
/// 初始化画布
pub fn init_canvas(width : Int, height : Int) -> Canvas {
  // 创建画布数据 - 为每一行创建独立的数组
  let rows = Array::make(height, Array::make(0, ""))
  for i = 0; i < height; i = i + 1 {
    rows[i] = Array::make(width, " ")
  }
  Canvas::{ width, height, data: rows }
}

///|
/// 在画布上绘制一个点
pub fn plot_point(
  canvas : Canvas,
  row : Int,
  col : Int,
  symbol : String,
) -> Canvas {
  if row >= 0 && row < canvas.height && col >= 0 && col < canvas.width {
    // 创建新的数据数组
    let new_data = Array::make(canvas.height, Array::make(canvas.width, " "))

    // 复制原有数据
    for i = 0; i < canvas.height; i = i + 1 {
      for j = 0; j < canvas.width; j = j + 1 {
        new_data[i][j] = canvas.data[i][j]
      }
    }

    // 设置新点
    new_data[row][col] = symbol
    Canvas::{ width: canvas.width, height: canvas.height, data: new_data }
  } else {
    canvas
  }
}

///|
/// 输出画布到终端
pub fn print_canvas(canvas : Canvas) -> Unit {
  for i = 0; i < canvas.height; i = i + 1 {
    let line = canvas.data[i].join("")
    @prelude.println(line)
  }
}

///|
/// 将画布转换为字符串
pub fn canvas_to_string(canvas : Canvas) -> String {
  let mut result = ""
  for i = 0; i < canvas.height; i = i + 1 {
    let line = canvas.data[i].join("")
    result = result + line
    if i < canvas.height - 1 {
      result = result + "\n"
    }
  }
  result
}
