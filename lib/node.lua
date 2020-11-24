local node = {}

function node:new(depth, m, s1, s2, s3)
  local o = {}
  self.__index = self
  setmetatable(o, self)
  o.depth = depth
  o.m = m
  o.s1 = s1
  o.s2 = s2
  o.s3 = s3
  o.note_queue = {}
  o.child = nil
  return o
end

function node:modulus()
  if self.depth == 0 then return 1 end
  return self.s1:func(self.m)
end

function node:add_child()
  self.child = node:new(self.depth + 1, self:modulus(), self.s1, self.s2, self.s3)
end

function node:add_note(note)
  if note == nil then return end
  if self.depth > 0 then
    note.num = self.s2:func(note.num) % 128
    note.vel = self.s3:func(note.vel) % 128
  end
  table.insert(self.note_queue, note)
end

function node:pop_note()
  note = table.remove(self.note_queue, 1)
  if self.depth ~= 0 then
    table.insert(note_buf, note)
  end
  if self.child ~= nil then self.child:add_note(note) end
end

function node:print_queue()
  local s = self.depth..": ["
  for _, note in pairs(self.note_queue) do
    s = s.."("..note.num..", "..note.vel.."), "
  end
  s = s.."]"
  print(s)
end

return node