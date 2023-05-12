set scrolloff=8
set number
set relativenumber

set expandtab
set smartindent
set shiftwidth=4
set tabstop=4 softtabstop=4

call plug#begin('~/.vim/plugged')
" TODO: to be replaced with telescope?
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'morhetz/gruvbox'
call plug#end()

set termguicolors
let ayucolor="dark"
colorscheme gruvbox

let mapleader = " "
nnoremap <leader>pv :Vex<CR>
nnoremap <leader><CR> 
nnoremap <leader><CR> :so ~/.config/nvim/init.vim<CR>
nnoremap <C-p> :GFiles<CR>
nnoremap <leader>pf :Files<CR>
nnoremap <C-j> :cnext<CR>
nnoremap <C-k> :cprev<CR>

