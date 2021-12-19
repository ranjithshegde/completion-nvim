local vim = vim
local api = vim.api
local source = require 'completion.source'
local opt = require 'completion.option'
local health = require 'health'

local M = {}

local checkCompletionSource = function()
  source.checkHealth()
end

local checkSnippetSource = function()
  local snippet_source = opt.get_option 'enable_snippet'
  if snippet_source == nil then
    health.report_info "You haven't set up any snippet source"
  else
    local rtp = string.lower(api.nvim_get_option 'rtp')
    local unknown_snippet_source = true
    local snippet_sources = {
      ['UltiSnips'] = 'ultisnips',
      ['Neosnippet'] = 'neosnippet.vim',
      ['vim-vsnip'] = 'vsnip',
      ['snippets.nvim'] = 'snippets.nvim',
      ['luasnip'] = 'LuaSnip',
    }

    for k, v in pairs(snippet_sources) do
      if snippet_source == k then
        unknown_snippet_source = false
        if string.match(rtp, '.*' .. v .. '.*') then
          health.report_ok('You are using ' .. k .. ' as your snippet source')
        else
          health.report_error(k .. ' is not available! Check if you installed ' .. k .. ' correctly')
        end
        break
      end
    end

    if unknown_snippet_source then
      health.report_error 'Your snippet source is not available! Possible values are: UltiSnips, Neosnippet, vim-vsnip, snippets.nvim'
    end
  end
end

function M.checkHealth()
  health.report_start 'general'
  if vim.tbl_filter == nil then
    health.report_error('vim.tbl_filter is not found!', { 'consider recompiling neovim from the latest master branch' })
  else
    health.report_ok 'neovim version is supported'
  end
  health.report_start 'completion source'
  checkCompletionSource()
  health.report_start 'snippet source'
  checkSnippetSource()
end

return M
