local Series = {
  operators = {},
  var = 1,
  var_min = 1,
  var_max = 1,
  op = "",
  operator_selector = 1
}

function Series:new(operators, var_min, var_max)
  local o = {}
  self.__index = self
  setmetatable(o, self)
  o.operators = operators
  o.var = var_min
  o.var_min = var_min
  o.var_max = var_max
  o.op = operators[1]
  o.operator_selector = 1
  return o
end

function Series:add_to_var(n)
  self.var = util.clamp(self.var + n, self.var_min, self.var_max)
end

function Series:cycle_op(n)
  self.operator_selector = util.clamp(self.operator_selector + n, 1, #self.operators)
  self.op = self.operators[self.operator_selector]
end

function Series:func(n)
  return load("return function(x) return x"..self.op..self.var.." end")()(n)
end

function Series:__tostring()
  return "i"..self.op..self.var
end

Series.modulus = Series:new({"+", "*", "^"}, 1, 127)
Series.note = Series:new({"+", "-", "*", "//", "^"}, 1, 127)

return Series