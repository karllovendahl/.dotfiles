vim.pack.add({
  "https://github.com/nvim-lualine/lualine.nvim",
  "https://github.com/nvim-tree/nvim-web-devicons",
})

local palette = dofile(vim.fn.expand("~/.config/palette/generated/palette.lua"))
local colors = {
  surface = palette.paper,
  surface_alt = palette.overlay,
  ink = palette.ink,
  ink_soft = palette.slate,
  line = palette.navy,
  cyan = palette.teal,
  accent = palette.rust,
  ochre = palette.ochre,
  red = palette.red,
}

local function sections(mode_background)
  return {
    a = { bg = mode_background, fg = colors.surface, gui = "bold" },
    b = { bg = colors.surface_alt, fg = colors.ink },
    c = { bg = colors.surface, fg = colors.ink_soft },
  }
end

local theme = {
  normal = sections(colors.line),
  insert = sections(colors.cyan),
  visual = sections(colors.accent),
  replace = sections(colors.red),
  command = sections(colors.ochre),
  inactive = {
    a = { bg = colors.surface, fg = colors.ink_soft },
    b = { bg = colors.surface, fg = colors.ink_soft },
    c = { bg = colors.surface, fg = colors.ink_soft },
  },
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
