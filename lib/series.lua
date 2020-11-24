local series = {
  operators = {},
  var = 1,
  var_min = 1,
  var_max = 1,
  op = "",
  operator_selector = 1
}

function series:new(name, operators, var_min, var_max)
  local o = {}
  self.__index = self
  setmetatable(o, self)
  o.name = name
  o.operators = operators
  o.var = var_min
  o.var_min = var_min
  o.var_max = var_max
  o.op = operators[1]
  o.operator_selector = 1
  return o
end

function series:add_to_var(n)
  self.var = util.clamp(self.var + n, self.var_min, self.var_max)
end

function series:cycle_op(n)
  self.operator_selector = util.clamp(self.operator_selector + n, 1, #self.operators)
  self.op = self.operators[self.operator_selector]
end

function series:func(n)
  return load("return function(x) return x"..self.op..self.var.." end")()(n)
end

function series:__tostring()
  return self.name..": a(i)"..self.op..self.var
end

series.modulus = series:new("modulus", {"+", "*", "^"}, 1, 127)
series.note = series:new("note number", {"+", "-", "*", "//", "^"}, 1, 127)
series.velocity = series:new("note velocity", {"+", "-", "*", "//", "^"}, 1, 127)

return series