vim.pack.add({
  "https://github.com/nvim-lualine/lualine.nvim",
  "https://github.com/nvim-tree/nvim-web-devicons",
})

local ok, palette = pcall(dofile, vim.fn.expand("~/.config/theme/current/nvim.lua"))
if not ok then
  require("lualine").setup({})
  return
end
-- Neutral in normal and command mode; insert, visual and replace use the
-- state colours.
local function sections(mode_background, mode_foreground)
  return {
    a = { bg = mode_background, fg = mode_foreground or palette.background, gui = "bold" },
    b = { bg = palette.overlay, fg = palette.foreground },
    c = { bg = palette.background, fg = palette.muted },
  }
end

local quiet = { bg = palette.background, fg = palette.muted }
local theme = {
  normal = sections(palette.overlay, palette.foreground),
  insert = sections(palette.color2),
  visual = sections(palette.color3),
  replace = sections(palette.color1),
  command = sections(palette.overlay, palette.foreground),
  inactive = { a = quiet, b = quiet, c = quiet },
}

require("lualine").setup({
  options = {
    icons_enabled = true,
    theme = theme,
    component_separators = { left = "", right = "" },
    section_separators = { left = "", right = "" },
    disabled_filetypes = {
      statusline = {},
      winbar = {},
    },
    ignore_focus = {},
    always_divide_middle = true,
    globalstatus = false,
    refresh = {
      statusline = 1000,
      tabline = 1000,
      winbar = 1000,
    },
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = {},
    lualine_c = { { "filename", path = 1, shorting_target = 40 } },
    lualine_x = { "fileformat", "filetype" },
    lualine_y = { "progress" },
    lualine_z = { "location" },
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { { "filename", path = 1, shorting_target = 40 } },
    lualine_x = { "location" },
    lualine_y = {},
    lualine_z = {},
  },
  tabline = {},
  winbar = {},
  inactive_winbar = {},
  extensions = { "nerdtree" },
})
