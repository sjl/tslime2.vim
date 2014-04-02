```text
@@@@@@@   @@@@@@   @@@       @@@  @@@@@@@@@@   @@@@@@@@   @@@@@@
@@@@@@@  @@@@@@@   @@@       @@@  @@@@@@@@@@@  @@@@@@@@  @@@@@@@@
  @@!    !@@       @@!       @@!  @@! @@! @@!  @@!            @@@
  !@!    !@!       !@!       !@!  !@! !@! !@!  !@!           @!@
  @!!    !!@@!!    @!!       !!@  @!! !!@ @!@  @!!!:!       !!@
  !!!     !!@!!!   !!!       !!!  !@!   ! !@!  !!!!!:      !!:
  !!:         !:!  !!:       !!:  !!:     !!:  !!:        !:!
  :!:        !:!    :!:      :!:  :!:     :!:  :!:       :!:
   ::    :::: ::    :: ::::   ::  :::     ::    :: ::::  :: :::::
   :     :: : :    : :: : :  :     :      :    : :: ::   :: : :::
```

tslime lets you send text from Vim to a running tmux session.  It's useful for
interacting with language/database REPLs and such.

tslime2 is a fork of tslime (which itself is a fork of a fork of a...).  It's
completely rewritten (in TimL) and documented.

Check out the [documentation][] for more information.

[documentation]: https://vim-doc.heroku.com/view?https://raw.github.com/sjl/tslime2.vim/master/doc/tslime.txt

Installation
------------

Use Pathogen.

tslime2 requires [TimL](http://github.com/tpope/timl) so install that too.

License
-------

MIT/X11

Credits
-------
In a nutshell:

The original version of tslime as far as I can tell is:
https://github.com/kikijump/tslime.vim

That repo hasn't been updated in a while, but this one has:
https://github.com/jgdavey/tslime.vim

I took that repo and added a few things and documentation and the result was:
https://github.com/sjl/tslime.vim

Then I completely rewrote everything in TimL and out came:
https://github.com/sjl/tslime2.vim
