Quickly install with:

    git clone git://github.com/msanders/snipmate.vim.git
	cd snipmate.vim
	cp -R * ~/.vim

Note: You're using a fork which is located at

    git://github.com/MarcWeber/snipmate.vim.git

    This forks differs in the following way:

    - snippets are loaded lazily.

    - snippets are no longer cached. Thus you always get the snippets you just
      wrote to a file without reloading anything.

    - when visually selecting a snippet in a .snippets file you can press <cr>
      to replace spaces by tabs automatically in a smart way


I asked the author multiple times for a review which never happened. I would be
fine with merging my changes upstream. I'd also like to investigate whether
xpemplate or snipmate has the better engine. So maybe my vision of the future
could be making xptemplate read snippet files. Its not imortant enough to me to
work on it right now as snipmate works reasonable well for me.
