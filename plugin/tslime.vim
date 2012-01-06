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

  let g:tmux_sessionname = b:tmux_sessionname
  let g:tmux_windowname = b:tmux_windowname
  let g:tmux_panenumber = b:tmux_panenumber
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
  elseif a:file =~# '.feature$'
    return "cucumber "
  endif
  return ''
endfunction

function! s:alternate_for_file(file)
  let related_file = ""
  if exists('g:autoloaded_rails')
    let alt = s:first_readable_file(rails#buffer().related())
    if alt =~# '.rb$'
      let related_file = alt
    endif
  endif
  return related_file
endfunction

function! s:command_for_file(file)
  let executable=""
  let alternate_file = s:alternate_for_file(a:file)
  if s:prefix_for_test(a:file) != ''
    let executable = s:prefix_for_test(a:file) . a:file
  elseif alternate_file != ''
    let executable = s:prefix_for_test(alternate_file) . alternate_file
  endif
  return executable
endfunction

function! s:send_test(executable)
  let executable = a:executable
  if executable == ''
    if exists("g:tmux_last_command") && g:tmux_last_command != ''
      let executable = g:tmux_last_command
    else
      let executable = 'echo "Warning: No command has been run yet"'
    endif
  endif
  return SendToTmux("".executable."\n")
endfunction

function! SendTestToTmux(file) abort
  let executable = s:command_for_file(a:file)
  if executable != ''
    let g:tmux_last_command = executable
  endif
  return s:send_test(executable)
endfunction

function! SendFocusedTestToTmux(file, line) abort
  let focus = ":".a:line

  if s:prefix_for_test(a:file) != ''
    let executable = s:command_for_file(a:file).focus
    let g:tmux_last_focused_command = executable
  elseif exists("g:tmux_last_focused_command") && g:tmux_last_focused_command != ''
    let executable = g:tmux_last_focused_command
  else
    let executable = ''
  endif

  return s:send_test(executable)
endfunction

" Mappings
nnoremap <silent> <Plug>SetTmuxVars :<C-U>call <SID>Tmux_Vars()<CR>
nnoremap <silent> <Plug>SendTestToTmux :<C-U>w \| call SendTestToTmux(expand('%'))<CR>
nnoremap <silent> <Plug>SendFocusedTestToTmux :<C-U>w \| call SendFocusedTestToTmux(expand('%'), line('.'))<CR>

if !exists("g:no_tmux_test_mappings")
  nmap <leader>t <Plug>SendTestToTmux
  nmap <leader>T <Plug>SendFocusedTestToTmux
endif

if !exists("g:no_tmux_reset_mapping")
  nmap <leader>y <Plug>SetTmuxVars
end

" vim:set ft=vim ff=unix ts=4 sw=2 sts=2:
