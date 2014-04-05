if exists("g:loaded_tslime") || v:version < 700 || &cp
  finish
endif
let g:loaded_tslime = 1

command! ConnectToTmux      call tslime#core#connect_to_tmux()
command! DisconnectFromTmux call tslime#core#disconnect_from_tmux()
command! -range SendSelectionToTmux        call tslime#core#send_selection_to_tmux()
command! -range SendSelectionToTmuxTrimmed call tslime#core#send_selection_to_tmux_trimmed()
command! -range SendSelectionToTmuxRaw     call tslime#core#send_selection_to_tmux_raw()

function! SendToTmux(text)
    call tslime#core#send_to_tmux(a:text)
endfunction

function! SendToTmuxRaw(text)
    call tslime#core#send_to_tmux_raw(a:text)
endfunction

function! SendToTmuxTrimmed(text)
    call tslime#core#send_to_tmux_trimmed(a:text)
endfunction
