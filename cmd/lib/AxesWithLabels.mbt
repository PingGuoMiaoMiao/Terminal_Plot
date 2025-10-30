///| 带标签的坐标轴绘制模块

///|
/// 格式化数字显示（保留一位小数）
fn format_number(num : Double) -> String {
  // 简单的数字格式化
  if num == 0.0 {
    "0"
  } else if num >= -0.05 && num < 0.05 && num != 0.0 {
    "0"
  } else if num == num.floor() {
    // 整数
    num.floor().to_int().to_string()
  } else {
    // 带小数
    let int_part = num.floor().to_int()
    let frac_part = ((num - num.floor()) * 10.0).floor().to_int().abs()
    if frac_part == 0 {
      int_part.to_string()
    } else {
      int_part.to_string() + "." + frac_part.to_string()
    }
  }
}

///|
/// 绘制带刻度标签的画布
pub fn plot_with_axes_labels(
  expr : String,
  x_min : Double,
  x_max : Double,
  width : Int,
  height : Int,
) -> Unit {
  // 先绘制主图
  @prelude.println("")
  plot_expression(expr, x_min, x_max, width, height)

  // 绘制 x 轴标签
  @prelude.println("")
  let mut x_label_line = ""
  let num_labels = 5
  for i = 0; i <= num_labels; i = i + 1 {
    let x_val = x_min + (x_max - x_min) * i.to_double() / num_labels.to_double()
    let label = format_number(x_val)
    let spacing = width / num_labels

    // 添加适当的间距
    if i == 0 {
      x_label_line = x_label_line + label
    } else {
      let needed_spaces = spacing - label.length()
      let mut j = 0
      while j < needed_spaces {
        x_label_line = x_label_line + " "
        j = j + 1
      }
      x_label_line = x_label_line + label
    }
  }
  @prelude.println("x: " + x_label_line)
}

///|
/// 打印坐标范围信息
pub fn print_range_info(
  x_min : Double,
  x_max : Double,
  y_min : Double,
  y_max : Double,
) -> Unit {
  @prelude.println("坐标范围:")
  @prelude.println(
    "  x: [" + format_number(x_min) + ", " + format_number(x_max) + "]",
  )
  @prelude.println(
    "  y: [" + format_number(y_min) + ", " + format_number(y_max) + "]",
  )
  @prelude.println("")
}
