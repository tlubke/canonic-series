local Node = include 'canonic-series/lib/node'
local Series = include 'canonic-series/lib/series'

engine.name = 'PolySub'

s1 = Series.modulus
s2 = Series.note
s3 = Series.velocity
ss = {
  s1,
  s2,
  s3,
}
selected_s_cursor = 1
selected_s = ss[selected_s_cursor]
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
  local i = 1
  
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
  for _, note in pairs(note_buf) do
    s = s.."("..note.num..", "..note.vel.."), "
  end
  s = s.."]"
  print(s)
end

local pop_notes = function(node)
  if note_cnt % node:modulus() == 0 then
    node:pop_note()
  end
end
  
local print_queues = function(node)
  node:print_queue()
end

local clear_queues = function(node)
  node.note_queue = {}
end

function note_on(n)
  root:add_note(n) 
  note_cnt = note_cnt + 1
  
  traverse_doing(pop_notes)
  
  print_buf()
  for _, note in pairs(note_buf) do
    midi_device:note_on(note.num, note.vel, 1)
  end
end

function all_notes_off()
  for _, note in pairs(note_buf) do
    midi_device:note_off(note.num, note.vel, 1)
  end
  note_buf ={}
end

--------------------
-- norns boilerplate
--------------------

function init()
  midi_device = midi.connect(3)
  --midi_device.event = midi_event
  root = Node:new(0, 0, s1, s2, s3)
  local add_child = function(node)
    node:add_child()
  end
  iterate_doing(add_child, 8)
 redraw()
end

function key(n, z)
  if z == 0 then
    if n == 1 then
      traverse_doing(clear_queues)
      note_buf = {}
      print("cleared")
    end
    
    if n == 2 then
      
    end
    
    if n == 3 then
      
    end
  end
end
function enc(n, d)
  if n == 1 then
    selected_s = ss[util.clamp(selected_s_cursor+d, 1, #ss)]
  end
  
  if n == 2 then
    selected_s:cycle_op(d)
  end
  
   if n == 3 then
    selected_s:add_to_var(d)
  end
  
  redraw()
end

function midi.event(data)
  local status_byte = data[1]
  local note        = {num = data[2], vel = data[3]}
  if is_note_on_event(status_byte) then
    note_on(note)
  end
  if is_note_off_event(status_byte) then
    all_notes_off()
  end
end

function is_note_on_event(status_byte)
  return status_byte >= 0x90 and status_byte <= 0x9F
end

function is_note_off_event(status_byte)
  return status_byte >= 0x80 and status_byte <= 0x8F
end

function redraw()
  screen.clear()
  screen.move(0,6)
  for n, s in pairs(ss) do
    if selected_s == s then
      screen.level(15)
    else
      screen.level(5)
    end
    screen.text(tostring(s))
    screen.move(0, n*8 + 6)
  end
  screen.update()
end