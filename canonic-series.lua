local Node = include 'canonic-series/lib/node'
local Series = include 'canonic-series/lib/series'

engine.name = 'PolySub'

s1 = Series.modulus
s2 = Series.note
note_cnt = 0
note_buf = {}

-- func: (Node) -> Any/Void
-- condition: (Any/nil) -> Bool
--
-- traverses from the first (root) node until the last
-- running the function 'func' on the node at each depth. 
-- stops before the end only if 'condition' is met.
function traverse_doing_until(func, condition)
  local current = root
  
  repeat
    func(current)
    current = current.child
  until current == nil or condition(current) == true
end

-- func: (Node) -> Any/Void
-- condition: (Any/nil) -> Bool
-- n: Int
--
-- traverses from the first (root) node until the nTH node
-- running the function 'func' on the node at each depth. 
-- if 'condition' is met, stops traversing.
function iterate_doing_until(func, condition, n)
  local current = root
  local i = 0
  
  repeat
    func(current)
    current = current.child
    i = i + 1
  until current == nil or condition(current) == true or i >= n
end

-- func: (Node) -> Any/Void
--
-- traverses from the first (root) node until the last
-- running the function 'func' on the node at each depth.
function traverse_doing(func)
  traverse_doing_until(func, function() return false end)
end

-- func: (Node) -> Any/Void
-- n: Int
--
-- traverses from the first (root) node until the nTH node
-- running the function 'func' on the node at each depth. 
function iterate_doing(func, n)
  iterate_doing_until(func, function() return false end, n)
end

function print_buf()
  local s = "["
  for i = 1, (#note_buf - 1) do
    s = s..note_buf[i]..", "
  end
  s = s..note_buf[#note_buf].."]"
  print(s)
end

function trig(n)
  note_cnt = note_cnt + 1
  
  local add_notes = function(node)
    node:add_note(n)
    if node.child == nil then node:add_child() end
  end
  
  local node_untriggered = function(node)
    return note_cnt % node.modulus ~= 0 
  end
    
  local pop_notes = function(node)
    if note_cnt % node.modulus == 0 then
      node:popNote()
    end
  end
  
  traverse_doing_until(add_notes, node_untriggered, 8)
  traverse_doing(pop_notes)
  
  print_buf()
end

--------------------
-- norns boilerplate
--------------------

function init()
 root = Node:new(0, s1, s2)
 redraw()
end

function key(n, z)
  if z == 0 then
    trig(1)
    note_buf = {}
  end
end

function enc(n, d)
  local selected_series = s1
  
  if n == 2 then
    selected_series:cycle_op(d)
  end
  
   if n == 3 then
    selected_series:add_to_var(d)
  end
  
  redraw()
end

function redraw()
  screen.clear()
  screen.level(15)
  screen.move(0,6)
  screen.text("s1: "..tostring(s1))
  screen.update()
end