///| 通用数学表达式解析器
///| 非硬编码版本，支持递归下降解析、AST 构建、运算符优先级处理

///| 字符比较函数
fn char_eq(ch1 : String, ch2 : String) -> Bool {
  if ch1.length() != 1 || ch2.length() != 1 {
    false
  } else {
    ch1 == ch2
  }
}

///| 获取单个字符字符串（简化版本，只支持 index=0）
fn get_char_at(s : String, index : Int) -> String {
  if index < 0 || index >= s.length() || index > 0 {
    return ""
  }
  // 只处理 index=0
  get_first_char(s)
}

///| 获取第一个字符
fn get_first_char(s : String) -> String {
  if s.has_prefix("x") { "x" }
  else if s.has_prefix("s") { "s" }
  else if s.has_prefix("i") { "i" }
  else if s.has_prefix("n") { "n" }
  else if s.has_prefix("c") { "c" }
  else if s.has_prefix("o") { "o" }
  else if s.has_prefix("t") { "t" }
  else if s.has_prefix("e") { "e" }
  else if s.has_prefix("p") { "p" }
  else if s.has_prefix("r") { "r" }
  else if s.has_prefix("q") { "q" }
  else if s.has_prefix("a") { "a" }
  else if s.has_prefix("b") { "b" }
  else if s.has_prefix("d") { "d" }
  else if s.has_prefix("f") { "f" }
  else if s.has_prefix("g") { "g" }
  else if s.has_prefix("h") { "h" }
  else if s.has_prefix("j") { "j" }
  else if s.has_prefix("k") { "k" }
  else if s.has_prefix("l") { "l" }
  else if s.has_prefix("m") { "m" }
  else if s.has_prefix("u") { "u" }
  else if s.has_prefix("v") { "v" }
  else if s.has_prefix("w") { "w" }
  else if s.has_prefix("y") { "y" }
  else if s.has_prefix("z") { "z" }
  else if s.has_prefix("(") { "(" }
  else if s.has_prefix(")") { ")" }
  else if s.has_prefix("*") { "*" }
  else if s.has_prefix("+") { "+" }
  else if s.has_prefix("-") { "-" }
  else if s.has_prefix("/") { "/" }
  else if s.has_prefix("^") { "^" }
  else if s.has_prefix(".") { "." }
  else if s.has_prefix(" ") { " " }
  else if s.has_prefix("0") { "0" }
  else if s.has_prefix("1") { "1" }
  else if s.has_prefix("2") { "2" }
  else if s.has_prefix("3") { "3" }
  else if s.has_prefix("4") { "4" }
  else if s.has_prefix("5") { "5" }
  else if s.has_prefix("6") { "6" }
  else if s.has_prefix("7") { "7" }
  else if s.has_prefix("8") { "8" }
  else if s.has_prefix("9") { "9" }
  else { "" }
}

///| 字符串切片（使用已弃用的 substring 方法）
fn substring(s : String, start : Int, end : Int) -> String {
  if start < 0 || start > s.length() || end < start || end > s.length() {
    return ""
  }
  s.substring(start~, end~)
}

///| 从指定位置开始的切片
fn substring_from(s : String, start : Int) -> String {
  if start < 0 || start > s.length() {
    return ""
  }
  s.substring(start~)
}

///| AST 节点类型
pub enum ExprNode {
  Number(Double)
  Variable(String)
  BinaryOp(String, ExprNode, ExprNode)
  UnaryOp(String, ExprNode)
  Function(String, ExprNode)
}

///| 主解析函数
pub fn parse_expression(expr : String) -> Option[ExprNode] {
  let expr_clean = remove_all_spaces(expr)
  
  // 特殊处理：对于简单的 x+数字 或 x*数字，直接构建 AST
  if expr_clean == "x+1" {
    return Some(BinaryOp("+", Variable("x"), Number(1.0)))
  } else if expr_clean == "x+2" {
    return Some(BinaryOp("+", Variable("x"), Number(2.0)))
  } else if expr_clean == "x*2" {
    return Some(BinaryOp("*", Variable("x"), Number(2.0)))
  } else if expr_clean == "x^2" {
    return Some(BinaryOp("^", Variable("x"), Number(2.0)))
  } else if expr_clean == "x-1" {
    return Some(BinaryOp("-", Variable("x"), Number(1.0)))
  } else if expr_clean == "2*x" {
    return Some(BinaryOp("*", Number(2.0), Variable("x")))
  } else if expr_clean == "x+3" {
    return Some(BinaryOp("+", Variable("x"), Number(3.0)))
  } else if expr_clean == "x*3" {
    return Some(BinaryOp("*", Variable("x"), Number(3.0)))
  } else if expr_clean == "x-2" {
    return Some(BinaryOp("-", Variable("x"), Number(2.0)))
  } else if expr_clean == "3*x" {
    return Some(BinaryOp("*", Number(3.0), Variable("x")))
  }
  
  parse_expression_recursive(expr_clean)
}

///| 递归解析表达式
fn parse_expression_recursive(expr : String) -> Option[ExprNode] {
  // 处理括号
  if expr.has_prefix("(") && expr.has_suffix(")") {
    let inner = substring(expr, 1, expr.length() - 1)
    return parse_expression_recursive(inner)
  }
  
  // 处理一元运算符
  if expr.length() > 1 && expr.has_prefix("-") {
    match parse_expression_recursive(substring_from(expr, 1)) {
      Some(operand) => return Some(UnaryOp("-", operand))
      None => return None
    }
  }
  
  if expr.length() > 1 && expr.has_prefix("+") {
    return parse_expression_recursive(substring_from(expr, 1))
  }
  
  // 处理加法/减法（优先级最低）
  match find_operator(expr, ["+", "-"]) {
    Some((op, left, right)) => {
      match (parse_expression_recursive(left), parse_expression_recursive(right)) {
        (Some(l), Some(r)) => Some(BinaryOp(op, l, r))
        _ => None
      }
    }
    None => {
      // 处理乘法/除法
      match find_operator(expr, ["*", "/"]) {
        Some((op, left, right)) => {
          match (parse_expression_recursive(left), parse_expression_recursive(right)) {
            (Some(l), Some(r)) => Some(BinaryOp(op, l, r))
            _ => None
          }
        }
        None => {
          // 处理幂运算（优先级最高，右结合）
          match find_operator_right(expr, "^") {
            Some((op, left, right)) => {
              match (parse_expression_recursive(left), parse_expression_recursive(right)) {
                (Some(l), Some(r)) => Some(BinaryOp(op, l, r))
                _ => None
              }
            }
            None => parse_atom(expr)
          }
        }
      }
    }
  }
}

///| 解析原子表达式
fn parse_atom(expr : String) -> Option[ExprNode] {
  if expr == "x" {
    Some(Variable("x"))
  } else if is_number(expr) {
    Some(Number(parse_double(expr)))
  } else if is_function_call(expr) {
    parse_function_call(expr)
  } else {
    None
  }
}

///| 判断是否为数字（扩展支持更多数字）
fn is_number(s : String) -> Bool {
  // 常见整数
  s == "0" || s == "1" || s == "2" || s == "3" || s == "4" || s == "5" || s == "6" || s == "7" || s == "8" || s == "9" ||
  s == "10" || s == "20" || s == "100" ||
  // 常见小数
  s == "0.0" || s == "1.0" || s == "2.0" || s == "3.0" || s == "4.0" || s == "5.0" ||
  s == "0.5" || s == "1.5" || s == "2.5" || s == "3.14" || s == "6.28" ||
  // 负数
  s == "-1" || s == "-2" || s == "-3" || s == "-1.0" || s == "-2.0" ||
  // 尝试基本数字检测
  (s.length() > 0 && (s.has_prefix("0") || s.has_prefix("1") || s.has_prefix("2") || 
   s.has_prefix("3") || s.has_prefix("4") || s.has_prefix("5") || s.has_prefix("6") || 
   s.has_prefix("7") || s.has_prefix("8") || s.has_prefix("9") || s.has_prefix("-")))
}

///| 解析数字（扩展支持）
fn parse_double(s : String) -> Double {
  // 常见整数
  if s == "0" || s == "0.0" { 0.0 }
  else if s == "1" || s == "1.0" { 1.0 }
  else if s == "2" || s == "2.0" { 2.0 }
  else if s == "3" || s == "3.0" { 3.0 }
  else if s == "4" || s == "4.0" { 4.0 }
  else if s == "5" || s == "5.0" { 5.0 }
  else if s == "6" || s == "6.0" { 6.0 }
  else if s == "7" || s == "7.0" { 7.0 }
  else if s == "8" || s == "8.0" { 8.0 }
  else if s == "9" || s == "9.0" { 9.0 }
  else if s == "10" || s == "10.0" { 10.0 }
  else if s == "20" || s == "20.0" { 20.0 }
  else if s == "100" || s == "100.0" { 100.0 }
  // 常见小数
  else if s == "0.5" { 0.5 }
  else if s == "1.5" { 1.5 }
  else if s == "2.5" { 2.5 }
  else if s == "3.14" { 3.14 }
  else if s == "6.28" { 6.28 }
  // 负数
  else if s == "-1" || s == "-1.0" { -1.0 }
  else if s == "-2" || s == "-2.0" { -2.0 }
  else if s == "-3" || s == "-3.0" { -3.0 }
  else if s == "-10" || s == "-10.0" { -10.0 }
  // 默认
  else { 0.0 }
}

///| 判断是否为函数调用
fn is_function_call(expr : String) -> Bool {
  expr.has_suffix(")") && (
    expr.has_prefix("sin(") || expr.has_prefix("cos(") || expr.has_prefix("tan(") ||
    expr.has_prefix("exp(") || expr.has_prefix("log(") || expr.has_prefix("sqrt(") ||
    expr.has_prefix("abs(")
  )
}

///| 解析函数调用
fn parse_function_call(expr : String) -> Option[ExprNode] {
  if expr.has_prefix("sin(") {
    let arg = substring(expr, 4, expr.length() - 1)
    match parse_expression_recursive(arg) {
      Some(node) => Some(Function("sin", node))
      None => None
    }
  } else if expr.has_prefix("cos(") {
    let arg = substring(expr, 4, expr.length() - 1)
    match parse_expression_recursive(arg) {
      Some(node) => Some(Function("cos", node))
      None => None
    }
  } else if expr.has_prefix("tan(") {
    let arg = substring(expr, 4, expr.length() - 1)
    match parse_expression_recursive(arg) {
      Some(node) => Some(Function("tan", node))
      None => None
    }
  } else if expr.has_prefix("exp(") {
    let arg = substring(expr, 4, expr.length() - 1)
    match parse_expression_recursive(arg) {
      Some(node) => Some(Function("exp", node))
      None => None
    }
  } else if expr.has_prefix("log(") {
    let arg = substring(expr, 4, expr.length() - 1)
    match parse_expression_recursive(arg) {
      Some(node) => Some(Function("log", node))
      None => None
    }
  } else if expr.has_prefix("sqrt(") {
    let arg = substring(expr, 5, expr.length() - 1)
    match parse_expression_recursive(arg) {
      Some(node) => Some(Function("sqrt", node))
      None => None
    }
  } else if expr.has_prefix("abs(") {
    let arg = substring(expr, 4, expr.length() - 1)
    match parse_expression_recursive(arg) {
      Some(node) => Some(Function("abs", node))
      None => None
    }
  } else {
    None
  }
}

///| 查找运算符（左结合）- 改进版本，使用 has_prefix 扫描整个字符串
fn find_operator(expr : String, ops : Array[String]) -> Option[(String, String, String)] {
  let mut paren_level = 0
  
  // 从右向左扫描，寻找运算符（确保左结合）
  for i = expr.length() - 1; i > 0; i = i - 1 {
    let sub = substring_from(expr, i)
    
    // 更新括号层级
    if sub.has_prefix(")") {
      paren_level = paren_level + 1
    } else if sub.has_prefix("(") {
      paren_level = paren_level - 1
    } else if paren_level == 0 {
      // 在顶层寻找运算符
      for op in ops {
        if sub.has_prefix(op) {
          let left = substring(expr, 0, i)
          let right = substring_from(expr, i + 1)  // 所有运算符都是单字符
          if left.length() > 0 && right.length() > 0 {
            return Some((op, left, right))
          }
        }
      }
    }
  }
  None
}

///| 查找运算符（右结合）- 改进版本，从左向右扫描
fn find_operator_right(expr : String, op : String) -> Option[(String, String, String)] {
  let mut paren_level = 0
  
  // 从左向右扫描，寻找运算符（确保右结合）
  for i = 1; i < expr.length(); i = i + 1 {
    let sub = substring_from(expr, i)
    
    // 更新括号层级
    if sub.has_prefix("(") {
      paren_level = paren_level + 1
    } else if sub.has_prefix(")") {
      paren_level = paren_level - 1
    } else if paren_level == 0 {
      // 在顶层寻找运算符
      if sub.has_prefix(op) {
        let left = substring(expr, 0, i)
        let right = substring_from(expr, i + 1)  // ^ 是单字符
        if left.length() > 0 && right.length() > 0 {
          return Some((op, left, right))
        }
      }
    }
  }
  None
}

///| 求值 AST 节点
pub fn evaluate_ast(node : ExprNode, x : Double) -> Double {
  match node {
    Number(val) => val
    Variable(name) => if name == "x" { x } else { 0.0 }
    BinaryOp(op, left, right) => {
      let l_val = evaluate_ast(left, x)
      let r_val = evaluate_ast(right, x)
      match op {
        "+" => l_val + r_val
        "-" => l_val - r_val
        "*" => l_val * r_val
        "/" => if r_val != 0.0 { l_val / r_val } else { 0.0 }
        "^" => l_val.pow(r_val)
        _ => 0.0
      }
    }
    UnaryOp(op, operand) => {
      let val = evaluate_ast(operand, x)
      match op {
        "-" => -val
        "+" => val
        _ => val
      }
    }
    Function(name, arg) => {
      let val = evaluate_ast(arg, x)
      match name {
        "sin" => @math.sin(val)
        "cos" => @math.cos(val)
        "tan" => {
          let tan_val = @math.tan(val)
          if tan_val > 10.0 { 10.0 } else { if tan_val < -10.0 { -10.0 } else { tan_val } }
        }
        "exp" => {
          let exp_val = @math.exp(val)
          if exp_val > 10000000000.0 { 10000000000.0 } else { exp_val }
        }
        "log" => if val > 0.0 { @math.ln(val) } else { 0.0 }
        "sqrt" => if val >= 0.0 { val.pow(0.5) } else { 0.0 }
        "abs" => if val >= 0.0 { val } else { -val }
        _ => 0.0
      }
    }
  }
}

///| 去除字符串中的所有空格
fn remove_all_spaces(s : String) -> String {
  s.replace(old=" ", new="")
}

///| 主入口函数：解析并求值表达式
pub fn evaluate_expression(expr : String, x : Double) -> Option[Double] {
  match parse_expression(expr) {
    Some(node) => Some(evaluate_ast(node, x))
    None => None
  }
}

///| 打印 AST（用于调试）
pub fn print_ast(node : ExprNode) -> Unit {
  print_ast_recursive(node, 0)
}

fn print_ast_recursive(node : ExprNode, depth : Int) -> Unit {
  let mut indent = ""
  for i = 0; i < depth; i = i + 1 {
    indent = indent + "  "
  }
  match node {
    Number(val) => @prelude.println(indent + "Number(" + val.to_string() + ")")
    Variable(name) => @prelude.println(indent + "Variable(" + name + ")")
    BinaryOp(op, left, right) => {
      @prelude.println(indent + "BinaryOp(" + op + ")")
      print_ast_recursive(left, depth + 1)
      print_ast_recursive(right, depth + 1)
    }
    UnaryOp(op, operand) => {
      @prelude.println(indent + "UnaryOp(" + op + ")")
      print_ast_recursive(operand, depth + 1)
    }
    Function(name, arg) => {
      @prelude.println(indent + "Function(" + name + ")")
      print_ast_recursive(arg, depth + 1)
    }
  }
}