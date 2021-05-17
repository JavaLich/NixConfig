let mapleader = " "

set exrc
set secure

let g:vimwiki_list = [{
	\ 'path': '~/Dropbox/notes/',
	\ 'template_path': '~/vimwiki/templates/',
	\ 'template_default': 'default',
	\ 'syntax': 'markdown',
	\ 'ext': '.md',
	\ 'path_html': '~/vimwiki/site_html/',
	\ 'custom_wiki2html': 'vimwiki_markdown',
	\ 'template_ext': '.tpl'}]

tmap <Esc> <C-\><C-n>

tmap <C-w> <Esc><C-w>

set nocompatible

filetype plugin indent on

imap jk <Esc>

set grepprg=rg\ --vimgrep\ --smart-case\ --follow

set showtabline=1  " Show tabline

au TextYankPost * silent! lua vim.highlight.on_yank()

set termguicolors

syntax enable

lua require('lualine').setup{ options = { theme = 'ayu_mirage' } }

" Requires xclip and Linux to work
set clipboard+=unnamedplus

nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>

" Auto format .rs files on save
autocmd BufWritePre *.rs lua vim.lsp.buf.formatting_sync(nil, 1000)

lua <<EOF
require'nvim-treesitter.configs'.setup {
  ensure_installed = {"lua", "c", "java", "rust", "cpp"}, 
  -- one of "all", "maintained" (parsers with maintainers), or a list of languages
  highlight = {
    enable = true,              -- false will disable the whole extension
    disable = {},  -- list of language that will be disabled
  },
}
local nvim_lsp = require('lspconfig')
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  -- Set autocommands conditional on server_capabilities
  if client.resolved_capabilities.document_highlight then
    vim.api.nvim_exec([[
      hi LspReferenceRead cterm=bold ctermbg=red guibg=grey
      hi LspReferenceText cterm=bold ctermbg=red guibg=grey
      hi LspReferenceWrite cterm=bold ctermbg=red guibg=grey
      augroup lsp_document_highlight
        autocmd! * <buffer>
        autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
        autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
      augroup END
    ]], false)
  end

  require'completion'.on_attach(client)
end

-- Use a loop to conveniently both setup defined servers 
-- and map buffer local keybindings when the language server attaches
local servers = { "ccls", "rust_analyzer"}
for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup { on_attach = on_attach }
end

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = true,
    signs = true,
    update_in_insert = true,
  }
)
EOF

nnoremap <silent> gd <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent> gD <cmd>lua vim.lsp.buf.declaration()<CR>
nnoremap <silent> gr <cmd>lua vim.lsp.buf.references()<CR>
nnoremap <silent> gi <cmd>lua vim.lsp.buf.implementation()<CR>
nnoremap <silent> K <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <silent> <C-k> <cmd>lua vim.lsp.buf.signature_help()<CR>
nnoremap <silent> <C-n> <cmd>lua vim.lsp.diagnostic.goto_prev()<CR>
nnoremap <silent> <C-p> <cmd>lua vim.lsp.diagnostic.goto_next()<CR>
nnoremap <silent> ga    <cmd>lua vim.lsp.buf.code_action()<CR>

" Show diagnostic popup on cursor hold
autocmd CursorHold * lua vim.lsp.diagnostic.show_line_diagnostics()

" Goto previous/next diagnostic warning/error
nnoremap <silent> [c <cmd>lua vim.lsp.diagnostic.goto_prev()<CR>
nnoremap <silent> ]c <cmd>lua vim.lsp.diagnostic.goto_next()<CR>

autocmd BufWinEnter,WinEnter term://* startinsert
command Ot FloatermNew --height=0.2 --wintype=normal --position=bottom
command T FloatermToggle
command R FloatermNew ranger
autocmd BufLeave term://* stopinsert 

let g:tex_flavor  = 'latex'
let g:tex_conceal = ''
let g:vimtex_fold_manual = 1
let g:vimtex_latexmk_continuous = 1
let g:vimtex_compiler_progname = 'nvr'

let g:vimtex_view_method = 'zathura'

map <C-e> :NERDTreeToggle<CR>

" Make it so that long lines wrap smartly
set breakindent
let &showbreak=repeat(' ', 3)
set linebreak

set relativenumber
set number
set ignorecase
set smartcase

set autoindent

set splitright
set splitbelow

set scrolloff=10

"set colorcolumn=80

" if set autoindenthidden is not set, TextEdit might fail.
set hidden

set tabstop=4
set expandtab shiftwidth=4 softtabstop=4

"set expandtab       " Expand TABs to spaces

" Some servers have issues with backup files, see #649
set nobackup
set nowritebackup

" Better display for messages
set cmdheight=1

" You will have bad experience for diagnostic messages when it's default 4000.
set updatetime=300

" Use <Tab> and <S-Tab> to navigate through popup menu
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" Set completeopt to have a better completion experience
set completeopt=menuone,noinsert,noselect

let g:completion_matching_strategy_list = ['exact', 'substring', 'fuzzy', 'all']

" Avoid showing message extra message when using completion
set shortmess+=c

" always show signcolumns
set signcolumn=yes

autocmd FileType c,cpp ClangFormatAutoEnable

let g:clang_format#code_style = "google"
let g:clang_format#style_options = {
            \ "Standard" : "C++11",
            \ "IncludeBlocks" : "Preserve"}

"let g:VM_theme = "codedark"
