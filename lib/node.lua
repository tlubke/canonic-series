local Node = {
  depth = 1,
  modulus = 1,
  note_queue = {},
  child = nil
}

function Node:new(depth, s1, s2)
  local o = {}
  self.__index = self
  setmetatable(o, self)
  o.depth = depth
  o.modulus = s1:func(depth)
  o.s1 = s1
  o.s2 = s2
  o.note_queue = {}
  o.child = nil
  return o
end

function Node:add_child()
  self.child = Node:new(self.depth + 1, self.s1, self.s2)
end

function Node:add_note(n)
  table.insert(self.note_queue, self.s2:func(n) % 128)
end

function Node:popNote()
  note = table.remove(self.note_queue)
  table.insert(note_buf, note)
  return note
end

return Node