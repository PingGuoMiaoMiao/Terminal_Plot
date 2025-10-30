///| 类型定义模块

///|
/// 画布结构定义
pub(all) struct Canvas {
  width : Int
  height : Int
  data : Array[Array[String]]
}

///|
/// 函数类型定义
pub enum FunctionType {
  Sin
  Cos
  Tan
  ArcTan
  Square
  Linear
}

///|
/// 绘图配置
pub(all) struct PlotConfig {
  x_min : Double
  x_max : Double
  y_min : Double
  y_max : Double
  width : Int
  height : Int
  show_axes : Bool
  symbol : String
}
