List = require("source_highlight.list")
HighlightWords = List:new()

local function pattern_get(text, opt)
  if not opt.is_whole then
    return text
  end
  if opt.is_visual then
    return "\\V\\zs" .. text .. "\\ze"
  else
    return "\\V\\<" .. text .. "\\>"
  end
end

function HighlightWords:new(o, color_selector)
  o = o or List:new()
  setmetatable(o, self)
  self.__index = self
  self.debug_name = "HighlightWords"
  self.color_selector = color_selector
  return o
end

function HighlightWords:add(text, opt)
  local pattern = pattern_get(text, opt)
  local color_group = self.color_selector:alloc()
  local id = vim.fn.matchadd(color_group, pattern)
  self:add_tail({
    text = text,
    id = id,
    color_group = color_group,
    pattern = pattern,
  })
end

function HighlightWords:fetch_by_text(text)
  return self:fetch_by(function(node)
    if node.text == text then
      return true
    else
      return false
    end
  end)
end

function HighlightWords:remove(word)
  vim.fn.matchdelete(word.id)
  self.color_selector:free(word.color_group)
  self:fetch_by_text(word.text)
end

function HighlightWords:clear()
  self:foreach(function(node)
    self:remove(node)
  end)
end

function HighlightWords:find(text)
  local find_word = nil
  self:foreach_break(function(node)
    if node.text == text then
      find_word = node
      return true
    else
      return false
    end
  end)
  return find_word
end

return HighlightWords
