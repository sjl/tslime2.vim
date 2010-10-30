function! Send_to_Tmux(text)
  if !exists("b:tmux_sessionname") || !exists("b:tmux_windowname")
    if exists("g:tmux_sessionname") && exists("g:tmux_windowname")
      let b:tmux_sessionname = g:tmux_sessionname
      let b:tmux_windowname = g:tmux_windowname
      if exists("g:tmux_panenumber")
        let b:tmux_panenumber = g:tmux_panenumber
      end
    else
      call Tmux_Vars()
    end
  end

  let target = b:tmux_sessionname . ":" . b:tmux_windowname

  if exists("b:tmux_panenumber")
    let target .= "." . b:tmux_panenumber
  end

  call system("tmux set-buffer -t " . b:tmux_sessionname  . " '" . substitute(a:text, "'", "'\\\\''", 'g') . "'" )
  call system("tmux paste-buffer -t " . target)
endfunction

function! Tmux_Session_Names(A,L,P)
  return system("tmux list-sessions | sed -e 's/:.*$//'")
endfunction

function! Tmux_Window_Names(A,L,P)
  return system("tmux list-windows -t" . b:tmux_sessionname . ' | grep -e "^\w:" | sed -e "s/ \[[0-9x]*\]$//"')
endfunction

function! Tmux_Pane_Numbers(A,L,P)
  return system("tmux list-panes -t " . b:tmux_sessionname . ":" . b:tmux_windowname . " | sed -e 's/:.*$//'")
endfunction

function! Tmux_Vars()
  let b:tmux_sessionname = input("session name: ", "", "custom,Tmux_Session_Names")
  let b:tmux_windowname = substitute(input("window name: ", "", "custom,Tmux_Window_Names"), ":.*$" , '', 'g')

  if system("tmux list-panes -t " . b:tmux_sessionname . ":" . b:tmux_windowname . " | wc -l") > 1
    let b:tmux_panenumber = input("pane number: ", "", "custom,Tmux_Pane_Numbers")
  end

  if !exists("g:tmux_sessionname") || !exists("g:tmux_windowname")
    let g:tmux_sessionname = b:tmux_sessionname
    let g:tmux_windowname = b:tmux_windowname
    if exists("b:tmux_panenumber")
      let g:tmux_panenumber = b:tmux_panenumber
    end
  end
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

vmap <C-c><C-c> "ry :call Send_to_Tmux(@r)<CR>
nmap <C-c><C-c> vip<C-c><C-c>

nmap <C-c>v :call Tmux_Vars()<CR>
