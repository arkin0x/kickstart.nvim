-- Git diff configuration for comparing against staging branch
local M = {}

-- Function to show files changed against staging
M.show_changed_files = function()
  -- Use Telescope to show changed files
  vim.cmd('Telescope git_status')
end

-- Function to diff current branch against staging
M.diff_against_staging = function()
  -- Set the diff base to staging
  vim.cmd('Gitsigns change_base staging true')
  print("Gitsigns now showing diff against staging branch")
end

-- Function to reset diff base to HEAD
M.reset_diff_base = function()
  vim.cmd('Gitsigns change_base nil true')
  print("Gitsigns reset to show diff against HEAD")
end

-- Function to open git status and diff view
M.fugitive_diff_staging = function()
  -- Open fugitive status
  vim.cmd('Git')
  -- Set up diff against staging
  vim.cmd('Git difftool -y staging')
end

-- Set up keybindings
M.setup = function()
  -- Keybinding to show changed files using Telescope
  vim.keymap.set('n', '<leader>gc', function()
    -- Show git status with Telescope (changed files)
    require('telescope.builtin').git_status()
  end, { desc = '[G]it [C]hanged files' })

  -- Keybinding to diff current file against staging
  vim.keymap.set('n', '<leader>gds', function()
    vim.cmd('Gitsigns diffthis staging')
  end, { desc = '[G]it [D]iff against [S]taging' })

  -- Keybinding to show all changes against staging
  vim.keymap.set('n', '<leader>gvs', function()
    vim.cmd('Git diff staging')
  end, { desc = '[G]it [V]iew diff against [S]taging' })

  -- Keybinding to change Gitsigns base to staging
  vim.keymap.set('n', '<leader>gbs', M.diff_against_staging, { desc = '[G]it [B]ase [S]taging - Show inline changes against staging' })

  -- Keybinding to reset Gitsigns base
  vim.keymap.set('n', '<leader>gbr', M.reset_diff_base, { desc = '[G]it [B]ase [R]eset - Show inline changes against HEAD' })

  -- Keybinding to list files changed between current branch and staging
  vim.keymap.set('n', '<leader>gls', function()
    -- Open a new buffer with the list of changed files
    vim.cmd('new')
    vim.cmd('r !git diff --name-status staging')
    vim.cmd('setlocal buftype=nofile bufhidden=wipe noswapfile')
    vim.cmd('normal! ggdd')
    vim.bo.filetype = 'git'
    print("Files changed between current branch and staging")
  end, { desc = '[G]it [L]ist files changed against [S]taging' })

  -- Enhanced Gitsigns keybindings for navigation
  vim.keymap.set('n', ']c', function()
    if vim.wo.diff then
      vim.cmd.normal({']c', bang = true})
    else
      require('gitsigns').nav_hunk('next')
    end
  end, { desc = 'Next git change' })

  vim.keymap.set('n', '[c', function()
    if vim.wo.diff then
      vim.cmd.normal({'[c', bang = true})
    else
      require('gitsigns').nav_hunk('prev')
    end
  end, { desc = 'Previous git change' })

  -- Keybinding for preview hunk
  vim.keymap.set('n', '<leader>hp', ':Gitsigns preview_hunk<CR>', { desc = '[H]unk [P]review' })
  -- Keybinding for inline blame
  vim.keymap.set('n', '<leader>hb', ':Gitsigns toggle_current_line_blame<CR>', { desc = '[H]unk [B]lame line' })

  -- Additional Fugitive commands for staging comparison
  vim.keymap.set('n', '<leader>gfs', function()
    -- Open file list that differs from staging
    vim.cmd('Git! diff --name-only staging')
  end, { desc = '[G]it [F]iles different from [S]taging' })

  -- Command to open a file and immediately show diff against staging
  vim.api.nvim_create_user_command('DiffFileStaging', function(opts)
    local file = opts.args
    if file == '' then
      file = vim.fn.expand('%')
    end
    vim.cmd('edit ' .. file)
    vim.cmd('Gitsigns diffthis staging')
  end, { nargs = '?', complete = 'file', desc = 'Open file and diff against staging' })
end

return M
