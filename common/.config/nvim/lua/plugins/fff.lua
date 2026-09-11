vim.g.fff = {
  keymaps = {
    move_up = { "<Up>", "<C-k>" },
    move_down = { "<Down>", "<C-j>" },
    cycle_previous_query = "<C-p>",
    cycle_grep_modes = "<C-s>",
  },
  layout = {
    prompt_position = "bottom",
    preview_position = "top",
  },
  hl = {
    border = "FFFBorder",
    normal = "FFFNormal",
    cursor = "FFFCursor",
    directory_path = "FFFDirectoryPath",
    matched = "FFFMatched",
    prompt = "FFFPrompt",
    selected = "FFFSelected",
    selected_active = "FFFSelectedActive",
    title = "FFFTitle",
    winhl = {
      preview = "Normal:FFFNormal,FloatBorder:FFFBorder,FloatTitle:FFFTitle,IncSearch:FFFPreviewMatch",
    },
  },
}

vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(event)
    local spec = event.data.spec
    local kind = event.data.kind

    if not spec or spec.name ~= "fff.nvim" or (kind ~= "install" and kind ~= "update") then
      return
    end

    if not event.data.active then
      vim.cmd.packadd("fff.nvim")
    end

    require("fff.download").download_or_build_binary()
  end,
})

-- Register the build hook before installation so fresh machines receive the native backend.
vim.pack.add({ "https://github.com/dmtrKovalenko/fff.nvim" })

local function find_files()
  require("fff").find_files()
end

local function live_grep()
  require("fff").live_grep()
end

vim.keymap.set("n", "<leader>pf", find_files, { desc = "Find files" })
vim.keymap.set("n", "<C-p>", find_files, { desc = "Find files" })
vim.keymap.set("n", "<leader>ps", live_grep, { desc = "Live grep" })
