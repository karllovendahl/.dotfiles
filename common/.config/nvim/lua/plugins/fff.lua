local function canonical_directory(path)
  local absolute_path = vim.fn.fnamemodify(path, ":p")
  return vim.uv.fs_realpath(absolute_path) or vim.fs.normalize(absolute_path)
end

local home_directory = canonical_directory(vim.env.HOME)

local function safe_picker_root()
  local buffer_name = vim.api.nvim_buf_get_name(0)
  local start_directory = buffer_name ~= "" and vim.fs.dirname(buffer_name) or vim.uv.cwd()
  local root = vim.fs.root(start_directory, { ".git" }) or vim.uv.cwd()
  local directory = canonical_directory(root)

  if directory == "/" or directory == home_directory then
    vim.notify("FFF needs a project directory; refusing to index " .. directory, vim.log.levels.WARN)
    return nil
  end

  return directory
end

vim.g.fff = {
  -- FFF initializes its native scanner before per-picker `cwd` overrides apply.
  -- Never let a Neovim session launched from $HOME or / make that first scan broad.
  base_path = vim.fn.stdpath("config"),
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
  local root = safe_picker_root()
  if root then require("fff").find_files({ cwd = root }) end
end

local function live_grep()
  local root = safe_picker_root()
  if root then require("fff").live_grep({ cwd = root }) end
end

vim.keymap.set("n", "<leader>pf", find_files, { desc = "Find files" })
vim.keymap.set("n", "<C-p>", find_files, { desc = "Find files" })
vim.keymap.set("n", "<leader>ps", live_grep, { desc = "Live grep" })
