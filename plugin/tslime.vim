" Tslime.vim. Send portion of buffer to tmux instance
" Maintainer: C.Coutinho <kikijump [at] gmail [dot] com>
" Licence:    DWTFYWTPL

if exists("g:tslime_loaded")
  finish
endif

let g:tslime_loaded = 1

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

  call system("tmux set-buffer '" . substitute(a:text, "'", "'\\\\''", 'g') . "'" )
  call system("tmux paste-buffer -t " . target)
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
  let b:tmux_windowname = ''
  while b:tmux_windowname == ''
    let b:tmux_windowname = substitute(input("window name: ", "", "custom,Tmux_Window_Names"), ":.*$" , '', 'g')
  endwhile
  let b:tmux_panenumber = ''
  while b:tmux_panenumber == ''
    let b:tmux_panenumber = input("pane number: ", "", "custom,Tmux_Pane_Numbers")
  endwhile
  if !exists("g:tmux_sessionname") || !exists("g:tmux_windowname") || !exists("g:tmux_panenumber")
    let g:tmux_sessionname = b:tmux_sessionname
    let g:tmux_windowname = b:tmux_windowname
    let g:tmux_panenumber = b:tmux_panenumber
  end
endfunction

function! s:first_readable_file(files) abort
  let files = type(a:files) == type([]) ? copy(a:files) : split(a:files,"\n")
  for file in files
    if filereadable(rails#app().path(file))
      return file
    endif
  endfor
  return files[0]
endfunction

function! s:SendAlternateToTmux() abort
  let current_file = expand("%")
  if current_file =~# '_spec.rb$'
    let command = "rspec ".current_file."\n"
  elseif exists('g:autoloaded_rails')
    let related_file = s:first_readable_file(rails#buffer().related())
    let command = "rspec ".related_file."\n"
  else
    let command = "!!\n"
  endif
  return Send_to_Tmux(command)
endfunction

augroup tmux
  autocmd!

  autocmd FileType ruby map <buffer> <leader>t :w \| :call <SID>SendAlternateToTmux()<CR>

  autocmd FileType cucumber map <buffer> <leader>t
        \ :w \| :call Send_to_Tmux('cucumber '.expand("%").":".line('.')."\n")<CR>

augroup END

