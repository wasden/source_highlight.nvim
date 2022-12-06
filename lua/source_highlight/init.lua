local M = {}

M.config = {
  mappings = {
    hl_toggle_whole = "<F8>",
    hl_clear = "<F9>",
    hl_toggle = "<S-F8>",
  },
}

local function gen_default_color_groups()
  local default_colors = {
    guifg = {
      black = "#1e222a",
    },
    guibg = {
      light_grey = "#6f737b",
      red = "#e06c75",
      pink = "#ff75a0",
      green = "#98c379",
      vibrant_green = "#7eca9c",
      nord_blue = "#81A1C1",
      blue = "#61afef",
      purple = "#de98fd",
      teal = "#519ABA",
      orange = "#fca2aa",
    },
  }
  local color_groups = {}
  for _, guibg_color in pairs(default_colors.guibg) do
    table.insert(color_groups, {
      guibg = guibg_color,
      guifg = default_colors.guifg.black,
      gui = "bold",
    })
  end
  return color_groups
end

local function set_mappings(mappings)
  if mappings.hl_toggle_whole then
    vim.keymap.set('n', mappings.hl_toggle_whole, function()
      M.hl_toggle({
        is_visual = false,
        is_whole = true,
      })
    end, { desc = "source_highlight hl_toggle_whole" })
    vim.keymap.set('v', mappings.hl_toggle_whole, function()
      M.hl_toggle({
        is_visual = true,
        is_whole = true,
      })
    end, { desc = "source_highlight hl_toggle_whole" })
  end
  if mappings.hl_toggle then
    vim.keymap.set('n', mappings.hl_toggle, function()
      M.hl_toggle({
        is_visual = false,
        is_whole = false,
      })
    end, { desc = "source_highlight hl_toggle" })
    vim.keymap.set('v', mappings.hl_toggle, function()
      M.hl_toggle({
        is_visual = true,
        is_whole = false,
      })
    end, { desc = "source_highlight hl_toggle" })
  end
  if mappings.hl_clear then
    vim.keymap.set('n', mappings.hl_clear, M.hl_clear, { desc = "source_highlight hl_clear" })
  end
end

local highlight_words = {}
local color_selector = {}

-- https://github.com/neovim/neovim/pull/21115
local function vtext_get()
  local _, ls, cs = unpack(vim.fn.getpos('v'))
  local _, le, ce = unpack(vim.fn.getpos('.'))

  -- not support cross line select
  if ls ~= le then
    return nil
  end
  if cs > ce then
    cs, ce = ce, cs
  end
  local visulal_lines = vim.api.nvim_buf_get_text(0, ls - 1, cs - 1, le - 1, ce, {})
  vim.api.nvim_input("<esc>")
  for _, text in pairs(visulal_lines) do
    return text
  end
end

local function text_get(is_visual)
  if is_visual then
    return vtext_get()
  else
    return vim.fn.expand('<cword>')
  end
end

-- @param opt:{is_visual:boolean is_whole:boolean}
M.hl_toggle = function(opt)
  local text = text_get(opt.is_visual)
  if not text or text == "" then
    return
  end

  local word = highlight_words:find(text)
  if word then
    highlight_words:remove(word)
  else
    highlight_words:add(text, opt)
  end
end

M.hl_clear = function()
  highlight_words:clear()
end

M.debug = function()
  highlight_words:debug()
  color_selector:debug()
  vim.pretty_print("config", M.config)
  vim.pretty_print("vim matches", vim.fn.getmatches())
end

M.setup = function(config)
  if config then
    print("a")
    M.config = vim.tbl_deep_extend("force", M.config, config)
  end
  set_mappings(M.config.mappings)

  if M.config.color_groups == nil then
    M.config.color_groups = gen_default_color_groups()
  end
  color_selector = require("source_highlight.colors_selector"):new(nil, M.config.color_groups)
  highlight_words = require("source_highlight.select_win_layer"):new(color_selector)
  vim.api.nvim_create_autocmd({ "WinClosed" }, { callback = function(opt)
    highlight_words:win_closed_handle(opt.match)
  end })
end

return M
