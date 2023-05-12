set scrolloff=8
set number
set relativenumber

set expandtab
set smartindent
set shiftwidth=4
set tabstop=4 softtabstop=4

call plug#begin('~/.vim/plugged')
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
call plug#end()

colorscheme desert

let mapleader = " "
nnoremap <leader>pv :Vex<CR>
nnoremap <leader><CR> 
nnoremap <leader><CR> :so ~/.config/nvim/init.vim<CR>
nnoremap <C-p> :GFiles<CR>
nnoremap <leader>pf :Files<CR>
