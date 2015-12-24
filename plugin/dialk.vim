" Name:       Dial K for help
" Location:   plugin/dialk.vim
" Maintainer: hertogp <git.hertogp@gmail.com>
" Version:    0.1

" todo:
" o turn DialK into function/command that takes options like
"   -split-tab -split-win -group-tab that can be used to create mappings
"   that do the right thing based on user preferences.  A little bit
"   like Unite does with its mappings.
"
if exists("g:loaded_dialk") || v:version < 700 || &cp
  finish
endif
let g:loaded_dialk = 1

if !exists("g:dialk_split_tab") | let g:dialk_split_tab = 1 | endif
if !exists("g:dialk_split_win") | let g:dialk_split_win = 1 | endif
if !exists("g:dialk_group_tab") | let g:dialk_group_tab = 1 | endif
if !exists("g:dialk_win_cmd")   | let g:dialk_win_cmd = "topleft new" | endif
if !exists("g:dialk_shellfmt")  | let g:dialk_shellfmt = "%s %s | col -bx" | endif

function! DialK(type)
  let l:topic = dialk#get_topic(a:type)
  call dialk#show_help(l:topic)
endfunction

nnoremap <silent><buffer>,k :set opfunc=DialK<cr>g@
nnoremap <silent>K :<c-u>call DialK(mode())<cr>
vnoremap <silent>K :<c-u>call DialK(visualmode())<cr>
