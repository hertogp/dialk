" Location: autoloaded/dialk.vim

" Load Guard: {{{1
if exists('g:autoloaded_dialk')
  finish
endif

let g:autoloaded_dialk = 1

" S:Vars: {{{1
let s:dialk_tabid = 'dialK'

" Helpers: {{{1

" get_topic {{{2
function! dialk#get_topic(type)
  let l:sel_save = &selection
  let l:cbd_save = &clipboard
  let l:reg_save = @@
  try
    set selection=inclusive clipboard-=unnamed clipboard-=unnamedplus
    if     a:type ==# 'n'     | silent exe "normal! yiw"
    elseif a:type =~# '^.$'   | silent exe "normal! gvy"
    elseif a:type ==# 'line'  | silent exe "normal! '[V']y"
    elseif a:type ==# 'block' | silent exe "normal! `[\<C-V>`]y"
    elseif a:type ==# 'char'  | silent exe "normal! `[v`]y"
    else                      | let @@='?'
    endif
    redraw
    return substitute(@@, '\v^\s+|\s+$', '', 'g')
  finally
    let &selection = l:sel_save
    let &clipboard = l:cbd_save
    let @@ = l:reg_save
  endtry
endfunction

" find_tabnr {{{2
function! dialk#find_tabnr(label)
  for tabnr in range(1,tabpagenr('$'))
    if gettabvar(tabnr, a:label, 0)
      return tabnr
    endif
  endfor
  return 0
endfunction

" Main {{{1
" show_help {{{2
" Notes:
" o a vim file has help as its keywordprg and should NOT be shelled out
" o get_new_window should cater for grouping tabs by keywordprg
"
function! dialk#help_win(topic)
  let save_tab = tabpagenr()
  let save_win = winnr()
  if g:dialk_split_tab
    let l:dialktab = dialk#find_tabnr(s:dialk_tabid)
    if l:dialktab > 0
      exec "normal! " . l:dialktab . "gt"
      exec g:dialk_win_cmd
    else
      tabnew
      call settabvar(tabpagenr(), s:dialk_tabid, 1)
    endif
  else
    exec g:dialk_win_cmd . " " . a:topic
  endif

  if !g:dialk_split_win
    execute "normal! \<c-w>o"
  endif
  return [save_tab, save_win]
endfunction

function! dialk#get_help(helpcmd, topic)
  " TODO:
  " for VIM buffers, use internal help?
  " create hooks for post processing via user defined function
  return system(printf(g:dialk_shellfmt, a:helpcmd, shellescape(a:topic)))
endfunction

function! dialk#show_help(topic)
  let l:dialkprg = &keywordprg
  let l:src_win = dialk#help_win(a:topic)
  try
    let MSG = dialk#get_help(l:dialkprg, a:topic)
    silent 0put=MSG
  catch
    call append(0, 'Vim exception ' . v:exception)
  finally
    normal! gg
    nnoremap <buffer><silent>q <esc>:<c-u>exe "wincmd c"<cr>
    silent execute "setlocal keywordprg=" . l:dialkprg
    " setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted nomodified
    setlocal buftype=nofile bufhidden=wipe noswapfile nomodified
    " set buffer name
    exec "file [HLP] " . l:dialkprg ."(" . a:topic . ")"
  endtry
endfunction

