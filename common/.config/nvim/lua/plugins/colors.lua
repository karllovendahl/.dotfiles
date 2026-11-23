vim.pack.add({ "https://github.com/rose-pine/neovim" })

-- theme-render writes the active theme's colours here.
local ok, palette = pcall(dofile, vim.fn.expand("~/.config/theme/current/nvim.lua"))
if not ok then
  vim.cmd.colorscheme("rose-pine-dawn")
  return
end

-- Reuse Rose Pine's broad plugin coverage with the workstation's palette:
-- its light "dawn" variant for light themes, "main" for dark ones.
local variant = palette.mode == "light" and "dawn" or "main"
vim.o.background = palette.mode == "light" and "light" or "dark"

require("rose-pine").setup({
  variant = variant,
  styles = {
    bold = true,
    italic = false,
    transparency = false,
  },
  palette = {
    [variant] = {
      _nc = palette.surface,
      base = palette.background,
      surface = palette.surface,
      overlay = palette.overlay,
      muted = palette.line,
      subtle = palette.muted,
      text = palette.foreground,
      love = palette.color1,
      gold = palette.color3,
      rose = palette.color5,
      pine = palette.accent,
      foam = palette.color6,
      iris = palette.color4,
      leaf = palette.color2,
      highlight_low = palette.surface,
      highlight_med = palette.overlay,
      highlight_high = palette.line,
    },
  },
  highlight_groups = {
    Comment = { fg = "subtle" },
    Constant = { fg = "rose" },
    Function = { fg = "iris" },
    Keyword = { fg = "pine", bold = true },
    Number = { fg = "gold" },
    String = { fg = "leaf" },
    Type = { fg = "foam" },
    ["@constant"] = { fg = "rose" },
    ["@function"] = { fg = "iris" },
    ["@keyword"] = { fg = "pine", bold = true },
    ["@number"] = { fg = "gold" },
    ["@string"] = { fg = "leaf" },
    ["@type"] = { fg = "foam" },
    CursorLine = { bg = "highlight_low" },
    CursorLineNr = { fg = "text", bold = true },
    DiffAdd = { inherit = false, bg = palette.diff_add },
    DiffDelete = { inherit = false, bg = palette.diff_delete },
    DiffChange = { inherit = false, bg = palette.diff_change },
    DiffText = { inherit = false, bg = palette.diff_text, bold = true },
    ["@diff.plus"] = { inherit = false, fg = "leaf", bg = palette.diff_add, bold = true },
    ["@diff.minus"] = { inherit = false, fg = "love", bg = palette.diff_delete, bold = true },
    ["@diff.delta"] = { inherit = false, fg = "gold", bg = palette.diff_change },
    GitSignsAdd = { inherit = false, fg = "leaf" },
    GitSignsDelete = { inherit = false, fg = "love" },
    GitSignsChange = { inherit = false, fg = "gold" },
    GitSignsAddInline = { inherit = false, fg = palette.on_accent, bg = "leaf", bold = true },
    GitSignsDeleteInline = { inherit = false, fg = palette.on_accent, bg = "love", bold = true },
    GitSignsChangeInline = { inherit = false, fg = palette.on_accent, bg = "gold", bold = true },
    FloatBorder = { fg = "subtle", bg = "surface" },
    NormalFloat = { bg = "surface" },
    PmenuSel = { fg = palette.on_accent, bg = "pine", bold = true },
    Search = { inherit = false, fg = palette.on_accent, bg = "gold", bold = true },
    Visual = { inherit = false, fg = palette.on_accent, bg = "pine" },
    VisualNOS = { inherit = false, fg = palette.on_accent, bg = "pine" },
    FFFBorder = { inherit = false, fg = "subtle", bg = "base" },
    FFFCursor = { inherit = false, fg = palette.on_accent, bg = "pine", bold = true },
    FFFDirectoryPath = { fg = "subtle" },
    FFFMatched = { bold = true, underline = true },
    FFFNormal = { inherit = false, fg = "text", bg = "base" },
    FFFPreviewMatch = { inherit = false, fg = palette.on_accent, bg = "pine", bold = true },
    FFFPrompt = { fg = "text", bold = true },
    FFFSelected = { fg = "text", bold = true },
    FFFSelectedActive = { inherit = false, fg = palette.on_accent, bg = "pine", bold = true },
    FFFTitle = { inherit = false, fg = "text", bg = "base", bold = true },
    WinSeparator = { fg = "muted" },
  },
})

vim.cmd.colorscheme("rose-pine-" .. variant)
