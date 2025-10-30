///| 解析器测试文件

///|
/// 演示解析器功能
fn demo_parser() -> Unit {
  @prelude.println("=== 通用解析器演示 ===")
  @prelude.println("")

  // 演示基本功能
  @prelude.println("1. 基本表达式:")
  demo_expression("x", 2.0)
  demo_expression("x+1", 2.0)
  demo_expression("x*2", 2.0)
  demo_expression("x^2", 2.0)
  @prelude.println("")
  @prelude.println("2. 复杂表达式:")
  demo_expression("x^2+2*x+1", 2.0)
  demo_expression("sin(x)", 1.57)
  demo_expression("exp(-x^2)", 1.0)
  @prelude.println("")
  @prelude.println("3. 运算符优先级:")
  demo_expression("2+3*4", 0.0) // 应该是 14
  demo_expression("2*3+4", 0.0) // 应该是 10
  demo_expression("2^3^2", 0.0) // 应该是 512
}

///|
/// 演示单个表达式
fn demo_expression(expr : String, x : Double) -> Unit {
  @prelude.println("表达式: " + expr + " (x=" + x.to_string() + ")")
  match @expression_parser.evaluate_expression(expr, x) {
    Some(result) => {
      @prelude.println("  结果: " + result.to_string())

      // 显示 AST
      match @expression_parser.parse_expression(expr) {
        Some(node) => {
          @prelude.println("  AST:")
          @expression_parser.print_ast(node)
        }
        None => @prelude.println("  AST: 解析失败")
      }
    }
    None => @prelude.println("  结果: 解析失败")
  }
  @prelude.println("")
}
