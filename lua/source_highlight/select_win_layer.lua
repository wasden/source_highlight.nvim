HighlightWords = require("source_highlight.highlight_words")

-- all SelectWinLayer:func exec will link to here
-- find hl_word_list which belong to this win, and exec its func
-- replace self(SelectWinLayer) with hl_word_list
-- @param self SelectWinLayer
-- @param func_key func_name which aim to exec
-- @return func
local function win_linked_func(self, func_key)
  local winid = vim.api.nvim_get_current_win()
  if not self.win_words[winid] then
    self.win_words[winid] = HighlightWords:new(nil, self.color_selector)
  end
  local hl_word_list = self.win_words[winid]
  local exec_func = hl_word_list[func_key]
  return function (_, ...)
    return exec_func(hl_word_list, ...)
  end
end

-- help HighlightWords to choose a win
-- use SelectWinLayer as HighlightWords
SelectWinLayer = {}
function SelectWinLayer:new(color_selector)

  -- reg SelectWinLayer access
  local o = {
    win_words = {},
    color_selector = color_selector,
    win_closed_handle = SelectWinLayer.win_closed_handle,
    debug = SelectWinLayer.debug,
  }
  setmetatable(o, self)
  self.__index = win_linked_func
  return o
end


function SelectWinLayer:win_closed_handle()
  self.win_words[vim.api.nvim_get_current_win()] = nil
end

function SelectWinLayer:debug()
  for winid, hl_words_list in pairs(self.win_words) do
    print("winid [ " .. winid .. " ]")
    hl_words_list:debug()
  end
end

return SelectWinLayer
