List = require("source_highlight.list")
ColorSelector = List:new()

local function hl_set(group_name, opt)
  local param_str = ""
  for key, value in pairs(opt) do
    param_str = param_str .. string.format(" %s=%s", key, value)
  end
  vim.cmd(
    string.format(
      "highlight %s %s",
      group_name,
      param_str
    )
  )
end

local function hl_unset(group)
  vim.cmd(
    string.format(
      "highlight clear %s", group
    )
  )
end

function ColorSelector:new(o, colors_config)
  o = o or List:new()
  setmetatable(o, self)
  self.__index = self
  self.debug_name = "ColorSelector"
  local countor = 1
  for _, color_opt in pairs(colors_config) do
    local group_name = "SourceHighlight_" .. countor
    hl_set(group_name, color_opt)
    o:add_tail({
      name = group_name,
    })
    countor = countor + 1
  end
  if o:is_empty() then
    error("colors is empty")
    return nil
  end
  return o
end

function ColorSelector:alloc()
  local color = self:pop()
  self:add_tail(color)
  return color.name
end

function ColorSelector:fetch_by_name(color_name)
  local color = self:fetch_by(function(node)
    if node.name == color_name then
      return true
    else
      return false
    end
  end)
  return color
end

function ColorSelector:free(color_name)
  local color = self:fetch_by_name(color_name)
  self:push(color)
end

function ColorSelector:off()
  self:foreach(function(color)
    hl_unset(color.name)
  end)
end

return ColorSelector
