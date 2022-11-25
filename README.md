# source_highlight.nvim
![Peek-source-highlight](https://user-images.githubusercontent.com/26076025/204005490-5a15af84-a5a5-4a1b-8c19-97098a11ea7c.gif)
## Description
Simple highlight based on `matchadd`(managed by window), similar to sourceinsight's highlighting.
## Feature
* Highlight with multiple colors

## Usage

|function                               | defaut key |
| ------------------------------------- | ---------- |
| highlight current word                |  F8        |
| highlight current word without \< \>  |  S-F8      |
| clear highlightings of current window |  F9        |
## Installation
```lua
-- packer 
-- use default settings
use {
  'wasden/source_highlight.nvim',
    config = function ()
      require("source_highlight").setup() 
    end,
}

-- customize
use {
  'wasden/source_highlight.nvim',
    config = function ()
      require("source_highlight").setup{
        mappings = {
          hl_toggle_whole = "<F8>",
          hl_clear = "<F9>",
          hl_toggle = "<S-F8>",
        },
        -- see :h highlight-args
        color_groups = {
          {
            guibg = "#1e222a",
            guifg = "e06c75",
            gui = "bold",
          },
        },
      }
    end,
}

```
