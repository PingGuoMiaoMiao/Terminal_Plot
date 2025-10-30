///| 函数采样模块
///| 函数采样 - 计算函数在指定范围内的值
pub fn sample_function(
  func : FunctionType,
  x_min : Double,
  x_max : Double,
  num_points : Int,
) -> Array[(Double, Double)] {
  let points = Array::make(num_points, (0.0, 0.0))
  let step = (x_max - x_min) / (num_points - 1).to_double()
  for i = 0; i < num_points; i = i + 1 {
    let x = x_min + step * i.to_double()
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
    points[i] = (x, y)
  }
  points
}

