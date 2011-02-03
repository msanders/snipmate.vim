snipmate.vim
============

:Author: `Michael Sanders`_
:Maintainer: `Rok Garbas`_
:Homepage: http://www.vim.org/scripts/script.php?script_id=2540 

::

    After several unsuccessful attempts of contacting Michael Sanders, no
    commits in last half year and long pull request line on github (none of
    pull requests were commented/replied/rejected).

    But nothing to worry about. We all get busy, accupied with our daily work
    or just lose interest in doing boring maintainance.

    While reviewing pull requests on github.com/msanders I found lots of great
    improvements and I decided to **friendly** fork it review and apply patches
    that were send, notify all the patch submiters and do the maintainance of
    snipmate.vim from now on. Ofcourse if somebody want to help, please don't
    hesitate to write me. The only thing in what I'm not interested is leaving
    things like they are now.

    Maybe I'll only maintain it for a while until Michael Sanders takes things
    back into his hand or until some other super-hero shows up.

    Tnx and happy snipmating, Rok Garbas



How to install
--------------

    * using `pathogen`_ and `git submodule`_

        % cd ~/.vim
        $ git submodule

    * manually

        ::
            % git clone git://github.com/msanders/snipmate.vim.git
            % cd snipmate.vim
            % cp -R * ~/.vim

        Then in vim::

            :helptags ~/.vim/doc/

.. _`Michael Sanders`: http://www.vim.org/account/profile.php?user_id=16544
.. _`Rok Garbas`: rok@garbas.si
.. _`pathogen`: http://www.vim.org/scripts/script.php?script_id=2332
.. _`git submodule`: http://www.kernel.org/pub/software/scm/git/docs/git-submodule.html


comment about this (MarcWeber) branch
-------------------------------------

::
    I also asked Michael Sanders - A long time ago I got a reply - but nothing
    which would have lead to a merge.  Probably my branch can be dropped if Rak
    Garbas accepts my (major?) changes

    My forks differs in the following way:

    - snippets are loaded lazily.

    - snippets are no longer cached. Thus you always get the snippets you just
      wrote to a file without reloading anything.

    - when visually selecting a snippet in a .snippets file you can press <cr>
      to replace spaces by tabs automatically in a smart way



future
--------------------------

::
    I'd like to investigate whether xptemplate or snipmate has the better
    engine. So maybe my vision of the future could be making xptemplate read
    snippet files. Its not imortant enough to me to work on it right now as
    snipmate works reasonable well for me.
