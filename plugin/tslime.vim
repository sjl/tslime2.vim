" Tslime.vim. Send portion of buffer to tmux instance
" Maintainer: C.Coutinho <kikijump [at] gmail [dot] com>
" Licence:    DWTFYWTPL

if exists("g:loaded_tslime") && g:loaded_tslime
  finish
endif

let g:loaded_tslime = 1

if !exists("g:tslime_ensure_trailing_newlines")
  let g:tslime_ensure_trailing_newlines = 0
endif
if !exists("g:tslime_normal_mapping")
  let g:tslime_normal_mapping = '<c-c><c-c>'
endif
if !exists("g:tslime_visual_mapping")
  let g:tslime_visual_mapping = '<c-c><c-c>'
endif
if !exists("g:tslime_vars_mapping")
  let g:tslime_vars_mapping = '<c-c>v'
endif

" Main function.
" Use it in your script if you want to send text to a tmux session.
function! Send_to_Tmux(text)
  if !exists("b:tmux_sessionname") || !exists("b:tmux_windowname") || !exists("b:tmux_panenumber")
    if exists("g:tmux_sessionname") && exists("g:tmux_windowname") && exists("g:tmux_panenumber")
      let b:tmux_sessionname = g:tmux_sessionname
      let b:tmux_windowname = g:tmux_windowname
      let b:tmux_panenumber = g:tmux_panenumber
    else
      call <SID>Tmux_Vars()
    end
  end

  let target = b:tmux_sessionname . ":" . b:tmux_windowname . "." . b:tmux_panenumber
  let oldbuffer = system("tmux show-buffer")

  call <SID>set_tmux_buffer(s:ensure_newlines(a:text))
  call system("tmux paste-buffer -t " . target)
  call <SID>set_tmux_buffer(oldbuffer)
endfunction

function! s:ensure_newlines(text)
  let text = a:text
  let trailing_newlines = matchstr(text, '\v\n*$')
  let spaces_to_add = g:tslime_ensure_trailing_newlines - strlen(trailing_newlines)

  while spaces_to_add > 0
    let spaces_to_add -= 1
    let text .= "\n"
  endwhile

  return text
endfunction

function! s:set_tmux_buffer(text)
  call system("tmux set-buffer '" . substitute(a:text, "'", "'\\\\''", 'g') . "'" )
endfunction

function! SendToTmux(text)
  call Send_to_Tmux(a:text)
endfunction

" Session completion
function! Tmux_Session_Names(A,L,P)
  return system("tmux list-sessions | sed -e 's/:.*$//'")
endfunction

" Window completion
function! Tmux_Window_Names(A,L,P)
  return system("tmux list-windows -t" . b:tmux_sessionname . ' | grep -e "^\w:" | sed -e "s/ \[[0-9x]*\]$//"')
endfunction

" Pane completion
function! Tmux_Pane_Numbers(A,L,P)
  return system("tmux list-panes -t " . b:tmux_sessionname . ":" . b:tmux_windowname . " | sed -e 's/:.*$//'")
endfunction

" set tslime.vim variables
function! s:Tmux_Vars()
  let b:tmux_sessionname = ''
  while b:tmux_sessionname == ''
    let b:tmux_sessionname = input("session name: ", "", "custom,Tmux_Session_Names")
  endwhile
  let b:tmux_windowname = substitute(input("window name: ", "", "custom,Tmux_Window_Names"), ":.*$" , '', 'g')
  let b:tmux_panenumber = input("pane number: ", "", "custom,Tmux_Pane_Numbers")

  if b:tmux_windowname == ''
    let b:tmux_windowname = '0'
  endif

  if b:tmux_panenumber == ''
    let b:tmux_panenumber = '0'
  endif

  let g:tmux_sessionname = b:tmux_sessionname
  let g:tmux_windowname = b:tmux_windowname
  let g:tmux_panenumber = b:tmux_panenumber
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

execute "vnoremap" . g:tslime_visual_mapping . ' "ry:call Send_to_Tmux(@r)<CR>'
execute "nnoremap" . g:tslime_normal_mapping . ' vip"ry:call Send_to_Tmux(@r)<CR>'
execute "nnoremap" . g:tslime_vars_mapping   . ' :call <SID>Tmux_Vars()<CR>'
