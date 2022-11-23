local M = {}

M.config = {
  map = {
    hl_toggle_whole = "<F8>",
    hl_clear = "<F9>",
    hl_toggle = "<S-F8>",
  },

  -- see :h highlight-args
  colors = {
    {
      guifg = "#353b45",
      guibg = "#cbcb41",
      gui = "bold,underline",
    },
    {
      guifg = "#353b45",
      guibg = "#89e051",
      gui = "bold,underline",
    },
  },
}

local highlight_words = {}
local color_selector = {}

-- https://github.com/neovim/neovim/pull/21115
local function visual_text_get()
  local _, ls, cs = unpack(vim.fn.getpos('v'))
  local _, le, ce = unpack(vim.fn.getpos('.'))
  local visulal_lines = vim.api.nvim_buf_get_text(0, ls-1, cs-1, le-1, ce, {})
  vim.api.nvim_input("<esc>")
  for _, text in pairs(visulal_lines) do
    return text
  end
end

local function text_get(is_visual)
  if is_visual then
    return visual_text_get()
  else
    return vim.fn.expand('<cword>')
  end
end

-- @opt is_visual is_whole
M.hl_toggle = function (opt)
  local text = text_get(opt.is_visual)
  if not text then
    print("not support operation")
  end

  local word = highlight_words:find(text)
  if word then
    highlight_words:remove(word)
  else
    highlight_words:add(text, opt)
  end
end

M.hl_clear = function ()
  highlight_words:clear()
end

M.debug = function ()
  highlight_words:debug()
  color_selector:debug()
  vim.pretty_print("config", M.config)
  vim.pretty_print("vim matches", vim.fn.getmatches())
end

M.setup = function ()
  vim.keymap.set('n', M.config.map.hl_toggle_whole, function ()
    M.hl_toggle({
      is_visual = false,
      is_whole = true,
    })
  end, {desc="source_highlight hl_toggle_whole"})
  vim.keymap.set('v', M.config.map.hl_toggle_whole, function ()
    M.hl_toggle({
      is_visual = true,
      is_whole = true,
    })
  end, {desc="source_highlight hl_toggle_whole"})
  vim.keymap.set('n', M.config.map.hl_toggle, function ()
    M.hl_toggle({
      is_visual = false,
      is_whole = false,
    })
  end, {desc="source_highlight hl_toggle"})
  vim.keymap.set('v', M.config.map.hl_toggle, function ()
    M.hl_toggle({
      is_visual = true,
      is_whole = false,
    })
  end, {desc="source_highlight hl_toggle"})
  vim.keymap.set('n', M.config.map.hl_clear, M.hl_clear, {desc="source_highlight hl_clear"})

  color_selector = require("source_highlight.colors_selector"):new(nil, M.config.colors)
  highlight_words = require("source_highlight.highlight_words"):new(nil, color_selector)
end

return M
