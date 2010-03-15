function! Send_to_Tmux(text)
  if !exists("b:tmux_sessionname") || !exists("b:tmux_windowname")
    call Tmux_Vars()
  end

  call system("tmux set-buffer -t " . b:tmux_sessionname  . " '" . substitute(a:text, "'", "'\\\\''", 'g') . "'" )
  call system("tmux paste-buffer -t " . b:tmux_sessionname . ":" . b:tmux_windowname)
endfunction

function! Tmux_Session_Names(A,L,P)
  return system("tmux list-sessions | sed -e 's/:.*$//'")
endfunction

function! Tmux_Window_Names(A,L,P)
  return system("tmux list-windows -t" . b:tmux_sessionname . ' | sed -e "s/ \[[0-9x]*\]$//"')
endfunction

function! Tmux_Vars()
  if !exists("b:tmux_sessionname") || !exists("b:tmux_windowname")
    let b:tmux_sessionname = ""
    let b:tmux_windowname = ""
  end

  let b:tmux_sessionname = input("session name: ", "", "custom,Tmux_Session_Names")
  let b:tmux_windowname = input("window name: ", "", "custom,Tmux_Window_Names")
  let b:tmux_windowname = substitute(b:tmux_windowname, ":.*$", '', 'g')
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

vmap <C-c><C-c> "ry :call Send_to_Tmux(@r)<CR>
nmap <C-c><C-c> vip<C-c><C-c>

nmap <C-c>v :call Tmux_Vars()<CR>
