" Tslime.vim. Send portion of buffer to tmux instance
" Maintainer: C.Coutinho <kikijump [at] gmail [dot] com>
" Licence:    DWTFYWTPL

if exists("g:loaded_tslime") && g:loaded_tslime
  finish
endif

let g:loaded_tslime = 1

" Main function.
" Use it in your script if you want to send text to a tmux session.
function! SendToTmux(text)
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

  call <SID>set_tmux_buffer(a:text)
  call system("tmux paste-buffer -t " . target)
  call <SID>set_tmux_buffer(oldbuffer)
endfunction

function! s:set_tmux_buffer(text)
  call system("tmux set-buffer '" . substitute(a:text, "'", "'\\\\''", 'g') . "'" )
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
  let b:tmux_windowname = ''
  let b:tmux_panenumber = ''

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
  return ''
endfunction

function! s:prefix_for_test(file)
  if a:file =~# '_spec.rb$'
    return "rspec "
  elseif a:file =~# '_test.rb$'
    return "ruby -Itest "
  endif
  return ''
endfunction

function! s:SendAlternateToTmux(suffix) abort
  let current_file = expand("%")
  let executable = ""
  if s:prefix_for_test(current_file) != ''
    let executable = s:prefix_for_test(current_file) . current_file . a:suffix
  elseif current_file =~# '.feature$'
    let executable = "cucumber " . current_file . a:suffix
  elseif exists('g:autoloaded_rails')
    let related_file = s:first_readable_file(rails#buffer().related())
    if related_file =~# '.rb$'
      let executable = s:prefix_for_test(related_file) . related_file
    endif
  endif
  if executable == ""
    let executable = "!!"
  endif
  return SendToTmux("".executable."\n")
endfunction

map <leader>t :w \| :call <SID>SendAlternateToTmux("")<CR>
map <leader>T :w \| :call <SID>SendAlternateToTmux(":".line('.'))<CR>
