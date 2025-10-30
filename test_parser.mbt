fn main {
  let ast = @expression_parser.parse_expression("x+1")
  match ast {
    Some(node) => {
      @prelude.println("AST parsed successfully")
      @expression_parser.print_ast(node)
      @prelude.println("")
      
      // Test evaluation at a few points
      for i = -10; i <= 10; i = i + 1 {
        let x = i.to_double()
        let y = @expression_parser.evaluate_ast(node, x)
        @prelude.println("x=" + x.to_string() + ", y=" + y.to_string())
      }
    }
    None => @prelude.println("Parse failed")
  }
}
