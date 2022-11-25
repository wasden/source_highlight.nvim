List = {}

function List:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  self.debug_name = "List"
  o.last = o
  return o
end

function List:add_tail(node)
  -- if self:is_empty() then
  --   self.last = node
  --   self.next = node
  -- else
  --   self.last.next = node
  --   self.last = node
  -- end
  self.last.next = node
  self.last = node
  node.next = nil
end

function List:push(node)
  if self:is_empty() then
    return self:add_tail(node)
  end
  node.next = self.next
  self.next = node
end

function List:__del_next(node)
  local del_node = node.next
  if not node or not del_node then
    return
  end
  if self.last == del_node then
    self.last = node
  end
  node.next = del_node.next
  del_node.next = nil
end

function List:pop()
  if self:is_empty() then
    return nil
  end
  local node = self.next
  self:__del_next(self)
  return node
end

-- fetch node if func return true
-- @param func(node)->bool
function List:fetch_by(func)
  local last_node = nil
  local fetch_node = nil
  self:foreach_break(function(node)
    if func(node) then
      fetch_node = node
      if not last_node then
        self:pop()
      else
        self:__del_next(last_node)
      end
      return true
    end
    last_node = node
    return false
  end)
  return fetch_node
end

-- @param func(node)
function List:foreach(func)
  local node = self.next
  while node do
    local tmp_node = node
    node = node.next
    func(tmp_node)
  end
end

-- break loop if @func return true
-- @param func(node)->bool
function List:foreach_break(func)
  local node = self.next
  while node do
    if func(node) then
      break
    end
    node = node.next
  end
end

function List:is_empty()
  return self.next == nil
end

function List:__print_node(node)
  if not node then
    print("node : nil")
    return
  end
  print("{")
  for key, value in pairs(node) do
    print(string.format("  %s : %s", key, value))
  end
  print("}")
end

function List:debug()
  print("List:", self.debug_name)
  local last_node = nil
  self:foreach(function(node)
    self:__print_node(node)
    last_node = node
  end)
  if last_node == self.last then
    print("last check true")
  elseif not last_node and self.last == self then
    print("last check true")
  else
    error("last check false")
    print("last_node:")
    self:__print_node(last_node)
    print("last_ptr:")
    self:__print_node(self.last)
  end
end

return List
