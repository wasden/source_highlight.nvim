List = {}

function List:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  self.next = nil
  self.last = nil
  self.debug_name = "List"
  return o
end

-- empty list add savely
function List:add_tail(node)
  if self:is_empty() then
    self.last = node
    self.next = node
  else
    self.last.next = node
    self.last = node
  end
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
  self:foreach_break(function (node)
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

function List:debug()
  print("List:", self.debug_name)
  local last_node = nil
  self:foreach(function (node)
    vim.pretty_print(node)
    last_node = node
  end)
  if last_node == self.last then
    print("last check true")
  else
    print("last check false")
    vim.pretty_print("last_node", last_node)
    vim.pretty_print("last_ptr", self.last)
  end
end

return List
