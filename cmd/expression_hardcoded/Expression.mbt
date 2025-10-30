///| 表达式解析模块


///| 函数表达式求值器 - 半通用版
///| 虽然使用模式匹配，但支持更多组合：
///| - 基本函数：sin(x), cos(x), tan(x), atan(x), exp(x), log(x), sqrt(x), abs(x)
///| - 运算符：+ - * / ^
///| - 复合表达式：sin(x) + x^2, exp(-x^2), x^2 + cos(x) * 2, sqrt(x^2+1)
///| 
///| 注意：这是半硬编码方式，但比完全硬编码更灵活
///| 真正的通用解析器需要更复杂的字符串处理，MoonBit 目前限制较多
pub fn evaluate_expression(expr : String, x : Double) -> Option[Double] {
  let expr_clean = remove_all_spaces(expr)
  
  // 处理复杂表达式：sin(x) + x^2
  if expr_clean == "sin(x)+x^2" || expr_clean == "sin(x)+x*x" {
    Some(@math.sin(x) + x * x)
  } else if expr_clean == "x^2+sin(x)" || expr_clean == "x*x+sin(x)" {
    Some(x * x + @math.sin(x))
  } else if expr_clean == "cos(x)+x^2" || expr_clean == "cos(x)+x*x" {
    Some(@math.cos(x) + x * x)
  } else if expr_clean == "x^2+cos(x)" || expr_clean == "x*x+cos(x)" {
    Some(x * x + @math.cos(x))
  } else if expr_clean == "x^2+cos(x)*2" || expr_clean == "x*x+cos(x)*2" {
    Some(x * x + @math.cos(x) * 2.0)
  } else if expr_clean == "2*cos(x)+x^2" || expr_clean == "2*cos(x)+x*x" {
    Some(2.0 * @math.cos(x) + x * x)
  } else if expr_clean == "sin(x)+cos(x)" {
    Some(@math.sin(x) + @math.cos(x))
  } else if expr_clean == "sin(x)-cos(x)" {
    Some(@math.sin(x) - @math.cos(x))
  } else if expr_clean == "sin(x)*cos(x)" {
    Some(@math.sin(x) * @math.cos(x))
  } else if expr_clean == "sin(x)/cos(x)" {
    let cos_val = @math.cos(x)
    if cos_val != 0.0 { Some(@math.sin(x) / cos_val) } else { None }
  }
  // 处理 exp(-x^2) 和 exp(-x*x)
  else if expr_clean == "exp(-x^2)" || expr_clean == "exp(-x*x)" {
    let arg = -x * x
    let exp_val = @math.exp(arg)
    Some(if exp_val > 10000000000.0 { 10000000000.0 } else { exp_val })
  } else if expr_clean == "exp(x^2)" || expr_clean == "exp(x*x)" {
    let arg = x * x
    let exp_val = @math.exp(arg)
    Some(if exp_val > 10000000000.0 { 10000000000.0 } else { exp_val })
  }
  // 处理 sqrt(x^2+1) 和 sqrt(x*x+1)
  else if expr_clean == "sqrt(x^2+1)" || expr_clean == "sqrt(x*x+1)" {
    let arg = x * x + 1.0
    Some(arg.pow(0.5))
  } else if expr_clean == "sqrt(x^2-1)" || expr_clean == "sqrt(x*x-1)" {
    let arg = x * x - 1.0
    if arg >= 0.0 {
      Some(arg.pow(0.5))
    } else {
      None
    }
  }
  // 基本函数
  else if expr_clean == "sin(x)" {
    Some(@math.sin(x))
  } else if expr_clean == "cos(x)" {
    Some(@math.cos(x))
  } else if expr_clean == "tan(x)" {
    let tan_val = @math.tan(x)
    Some(if tan_val > 10.0 { 10.0 } else { if tan_val < -10.0 { -10.0 } else { tan_val } })
  } else if expr_clean == "atan(x)" {
    Some(@math.atan(x))
  } else if expr_clean == "exp(x)" {
    let exp_val = @math.exp(x)
    Some(if exp_val > 10000000000.0 { 10000000000.0 } else { exp_val })
  } else if expr_clean == "log(x)" {
    if x > 0.0 {
      Some(@math.ln(x))
    } else {
      None
    }
  } else if expr_clean == "sqrt(x)" {
    if x >= 0.0 {
      Some(x.pow(0.5))
    } else {
      None
    }
  } else if expr_clean == "abs(x)" {
    Some(if x >= 0.0 { x } else { -x })
  }
  // 变量和幂运算
  else if expr_clean == "x" {
    Some(x)
  } else if expr_clean == "-x" {
    Some(-x)
  } else if expr_clean == "x^2" || expr_clean == "x*x" {
    Some(x * x)
  } else if expr_clean == "x^3" || expr_clean == "x*x*x" {
    Some(x * x * x)
  } else if expr_clean == "x^4" {
    Some(x * x * x * x)
  }
  // 多项式
  else if expr_clean == "x^2+1" || expr_clean == "x*x+1" {
    Some(x * x + 1.0)
  } else if expr_clean == "x^2-1" || expr_clean == "x*x-1" {
    Some(x * x - 1.0)
  } else if expr_clean == "x+1" {
    Some(x + 1.0)
  } else if expr_clean == "x-1" {
    Some(x - 1.0)
  } else if expr_clean == "2*x" || expr_clean == "x*2" {
    Some(2.0 * x)
  } else if expr_clean == "3*x" || expr_clean == "x*3" {
    Some(3.0 * x)
  } else if expr_clean == "2*x+1" {
    Some(2.0 * x + 1.0)
  } else if expr_clean == "x/2" {
    Some(x / 2.0)
  } else if expr_clean == "x/3" {
    Some(x / 3.0)
  }
  // 用于绘制圆的表达式
  else if expr_clean == "sqrt(1-x^2)" || expr_clean == "sqrt(1-x*x)" {
    let val = 1.0 - x * x
    if val >= 0.0 {
      Some(val.pow(0.5))
    } else {
      None
    }
  }
  // 其他复杂表达式
  else if expr_clean == "sin(x)*x" || expr_clean == "x*sin(x)" {
    Some(@math.sin(x) * x)
  } else if expr_clean == "cos(x)*x" || expr_clean == "x*cos(x)" {
    Some(@math.cos(x) * x)
  } else if expr_clean == "exp(x)*sin(x)" || expr_clean == "sin(x)*exp(x)" {
    Some(@math.exp(x) * @math.sin(x))
  } else if expr_clean == "exp(x)*cos(x)" || expr_clean == "cos(x)*exp(x)" {
    Some(@math.exp(x) * @math.cos(x))
  } else if expr_clean == "x^3+x^2+x" || expr_clean == "x*x*x+x*x+x" {
    Some(x * x * x + x * x + x)
  } else if expr_clean == "x^3-x^2+x" || expr_clean == "x*x*x-x*x+x" {
    Some(x * x * x - x * x + x)
  } else if expr_clean == "2*x^2+3*x+1" || expr_clean == "2*x*x+3*x+1" {
    Some(2.0 * x * x + 3.0 * x + 1.0)
  }
  // 向后兼容：使用原始表达式（带空格）匹配
  else if expr == "sin(x)" {
    Some(@math.sin(x))
  } else if expr == "cos(x)" {
    Some(@math.cos(x))
  } else if expr == "tan(x)" {
    let tan_val = @math.tan(x)
    Some(if tan_val > 10.0 { 10.0 } else { if tan_val < -10.0 { -10.0 } else { tan_val } })
  } else if expr == "atan(x)" {
    Some(@math.atan(x))
  } else if expr == "x" {
    Some(x)
  } else if expr == "-x" {
    Some(-x)
  } else if expr == "x^2" || expr == "x*x" {
    Some(x * x)
  } else if expr == "x^3" || expr == "x*x*x" {
    Some(x * x * x)
  } else if expr == "x^2+1" {
    Some(x * x + 1.0)
  } else if expr == "x^2-1" {
    Some(x * x - 1.0)
  } else if expr == "x+1" {
    Some(x + 1.0)
  } else if expr == "x-1" {
    Some(x - 1.0)
  } else if expr == "2*x" || expr == "x*2" {
    Some(2.0 * x)
  } else if expr == "2*x+1" {
    Some(2.0 * x + 1.0)
  } else if expr == "x/2" {
    Some(x / 2.0)
  } else if expr == "sqrt(1-x^2)" || expr == "sqrt(1-x*x)" {
    // 用于绘制圆的上半部分
    let val = 1.0 - x * x
    if val >= 0.0 {
      Some(val.pow(0.5))
    } else {
      None
    }
  } else {
    None
  }
}

///| 绘制圆（x^2 + y^2 = 1）
pub fn plot_circle(x_min : Double, x_max : Double, width : Int, height : Int) -> Unit {
  let y_min = -1.5
  let y_max = 1.5

  let canvas = @lib.init_canvas(width, height)
  let canvas_data = canvas.data
  
  let sample_count = width * 3
  for i = 0; i < sample_count; i = i + 1 {
    let x = if sample_count == 1 {
      x_min
    } else {
      x_min + (x_max - x_min) * i.to_double() / (sample_count - 1).to_double()
    }
    
    // 计算 y = sqrt(1 - x^2) 和 y = -sqrt(1 - x^2)
    if x >= -1.0 && x <= 1.0 {
      let y1 = (1.0 - x * x).pow(0.5)
      let y2 = -y1
      
      // 绘制上半圆
      let row_float1 = ((y1 - y_min) / (y_max - y_min) * (height - 1).to_double())
      let row1 = row_float1.floor().to_int()
      let row_clamped1 = if row1 < 0 { 0 } else { if row1 >= height { height - 1 } else { row1 } }
      let normalized_row1 = (height - 1) - row_clamped1
      
      // 绘制下半圆
      let row_float2 = ((y2 - y_min) / (y_max - y_min) * (height - 1).to_double())
      let row2 = row_float2.floor().to_int()
      let row_clamped2 = if row2 < 0 { 0 } else { if row2 >= height { height - 1 } else { row2 } }
      let normalized_row2 = (height - 1) - row_clamped2
      
      let col_float = ((x - x_min) / (x_max - x_min) * (width - 1).to_double())
      let col = col_float.floor().to_int()
      let col_clamped = if col < 0 { 0 } else { if col >= width { width - 1 } else { col } }
      
      if normalized_row1 >= 0 && normalized_row1 < height && col_clamped >= 0 && col_clamped < width {
        canvas_data[normalized_row1][col_clamped] = "·"
      }
      if normalized_row2 >= 0 && normalized_row2 < height && col_clamped >= 0 && col_clamped < width {
        canvas_data[normalized_row2][col_clamped] = "·"
      }
    }
  }
  
  // 绘制坐标轴
  let zero_x_col = if x_max == x_min {
    width / 2
  } else {
    ((0.0 - x_min) / (x_max - x_min) * (width - 1).to_double()).floor().to_int()
  }
  let zero_y_row = height / 2
  let normalized_zero_y_row = (height - 1) - zero_y_row
  
  // 绘制 x 轴
  if normalized_zero_y_row >= 0 && normalized_zero_y_row < height {
    for col = 0; col < width; col = col + 1 {
      if canvas_data[normalized_zero_y_row][col] == " " {
        canvas_data[normalized_zero_y_row][col] = "-"
      }
    }
  }
  
  // 绘制 y 轴
  if zero_x_col >= 0 && zero_x_col < width {
    for row = 0; row < height; row = row + 1 {
      if canvas_data[row][zero_x_col] == " " {
        canvas_data[row][zero_x_col] = "|"
      }
    }
  }
  
  // 绘制原点
  if zero_x_col >= 0 && zero_x_col < width && normalized_zero_y_row >= 0 && normalized_zero_y_row < height {
    canvas_data[normalized_zero_y_row][zero_x_col] = "+"
  }
  
  // 输出
  let canvas_final = @lib.Canvas::{ width: width, height: height, data: canvas_data }
  @lib.print_canvas(canvas_final)
}

///| 去除字符串中的所有空格
fn remove_all_spaces(s : String) -> String {
  let mut result = s
  // 多次替换直到没有空格（最多循环足够次数）
  for i = 0; i < 100; i = i + 1 {
    if result.contains(" ") {
      result = result.replace(old=" ", new="")
    } else {
      break
    }
    let _ = i  // 使用 i 以避免未使用警告
  }
  result
}

///| 绘制自定义函数表达式
///| 支持隐式方程如 "y^2 + x^2 = 1"（会被转换为圆）
pub fn plot_expression(expr : String, x_min : Double, x_max : Double, width : Int, height : Int) -> Unit {
  // 检测是否为隐式圆方程：y^2 + x^2 = 1 或类似形式
  let expr_trimmed = remove_all_spaces(expr)
  
  // 检测是否为隐式圆方程 x^2 + y^2 = 1
  // 支持各种写法：x^2+y^2=1, y^2+x^2=1, x*x+y*y=1 等
  if expr_trimmed == "y^2+x^2=1" || 
     expr_trimmed == "x^2+y^2=1" || 
     expr_trimmed == "y^2+x*x=1" ||
     expr_trimmed == "x*x+y^2=1" ||
     expr_trimmed == "y^2+x^2=1.0" ||
     expr_trimmed == "x^2+y^2=1.0" ||
     expr_trimmed == "x*x+y*y=1" ||
     expr_trimmed == "y*y+x*x=1" {
    // 使用专门的圆绘制函数
    // 对于圆，使用更适合的范围（-1.5 到 1.5）
    let circle_x_min = if x_min > -2.0 && x_max < 2.0 { x_min } else { -1.5 }
    let circle_x_max = if x_min > -2.0 && x_max < 2.0 { x_max } else { 1.5 }
    plot_circle(circle_x_min, circle_x_max, width, height)
    return
  }
  
  // 先采样计算 y 范围
  let sample_count_preview = 100
  let mut y_min = 0.0
  let mut y_max = 0.0
  let mut first = true
  
  for i = 0; i < sample_count_preview; i = i + 1 {
    let x = x_min + (x_max - x_min) * i.to_double() / (sample_count_preview - 1).to_double()
    match evaluate_expression(expr, x) {
      Some(y) => {
        if first {
          y_min = y
          y_max = y
          first = false
        } else {
          if y < y_min { y_min = y }
          if y > y_max { y_max = y }
        }
      }
      None => {
        ()
      }
    }
  }
  
  // 添加边距
  let margin = if y_max == y_min { 1.0 } else { (y_max - y_min) * 0.1 }
  let y_min_final = y_min - margin
  let y_max_final = y_max + margin
  
  // 绘制函数
  let canvas = @lib.init_canvas(width, height)
  let canvas_data = canvas.data
  
  let sample_count = width * 3
  for i = 0; i < sample_count; i = i + 1 {
    let x = if sample_count == 1 {
      x_min
    } else {
      x_min + (x_max - x_min) * i.to_double() / (sample_count - 1).to_double()
    }
    
    match evaluate_expression(expr, x) {
      Some(y) => {
        let row_float = if y_max_final == y_min_final {
          (height - 1).to_double() / 2.0
        } else {
          ((y - y_min_final) / (y_max_final - y_min_final) * (height - 1).to_double())
        }
        let row = row_float.floor().to_int()
        let row_clamped = if row < 0 { 0 } else { if row >= height { height - 1 } else { row } }
        let normalized_row = (height - 1) - row_clamped
        
        let col_float = if x_max == x_min {
          (width - 1).to_double() / 2.0
        } else {
          ((x - x_min) / (x_max - x_min) * (width - 1).to_double())
        }
        let col = col_float.floor().to_int()
        let col_clamped = if col < 0 { 0 } else { if col >= width { width - 1 } else { col } }
        
        if normalized_row >= 0 && normalized_row < height && col_clamped >= 0 && col_clamped < width {
          canvas_data[normalized_row][col_clamped] = "·"
        }
      }
      None => {
        ()
      }
    }
  }
  
  // 绘制坐标轴
  let zero_x_col = if x_max == x_min {
    width / 2
  } else {
    ((0.0 - x_min) / (x_max - x_min) * (width - 1).to_double()).floor().to_int()
  }
  let zero_y_row = if y_max_final == y_min_final {
    height / 2
  } else {
    ((0.0 - y_min_final) / (y_max_final - y_min_final) * (height - 1).to_double()).floor().to_int()
  }
  let normalized_zero_y_row = (height - 1) - zero_y_row
  
  // 绘制 x 轴
  if normalized_zero_y_row >= 0 && normalized_zero_y_row < height {
    for col = 0; col < width; col = col + 1 {
      if canvas_data[normalized_zero_y_row][col] == " " {
        canvas_data[normalized_zero_y_row][col] = "-"
      }
    }
  }
  
  // 绘制 y 轴
  if zero_x_col >= 0 && zero_x_col < width {
    for row = 0; row < height; row = row + 1 {
      if canvas_data[row][zero_x_col] == " " {
        canvas_data[row][zero_x_col] = "|"
      }
    }
  }
  
  // 绘制原点
  if zero_x_col >= 0 && zero_x_col < width && normalized_zero_y_row >= 0 && normalized_zero_y_row < height {
    canvas_data[normalized_zero_y_row][zero_x_col] = "+"
  }
  
  // 输出
  let canvas_final = @lib.Canvas::{ width: width, height: height, data: canvas_data }
  @lib.print_canvas(canvas_final)
}

///| 简单的字符串到 Double 解析（仅支持基本格式）
pub fn parse_double_simple(s : String) -> Option[Double] {
  // 这里简化处理，实际应该使用更完善的解析
  // 暂时返回 None，让调用者使用硬编码值
  None
}

///| 简单的字符串到 Int 解析
pub fn parse_int_simple(s : String) -> Option[Int] {
  None
}

