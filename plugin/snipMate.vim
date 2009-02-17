" File:          snipMate.vim
" Author:        Michael Sanders
" Version:       0.61803399
" Description:   snipMate.vim implements some of TextMate's snippets features in
"                Vim. A snippet is a piece of often-typed text that you can
"                insert into your document using a trigger word followed by a "<tab>".
"
"                For more help see snipMate.txt; you can do this by doing:
"                :helptags ~/.vim/doc
"                :h snipMate.txt
" Last Modified: February 16, 2009.

if exists('g:loaded_snips') || &cp || version < 700
	fini
en
let g:loaded_snips = 1

" snippets for making snippets :)
au FileType vim let b:Snippet_snip = 'exe "Snipp ${1:trigger}"${2}'
			\|  let b:Snippet_snipp = "exe 'Snipp ${1:trigger}'${2}"
			\|  let b:Snippet_gsnip = 'exe "GlobalSnip ${1:trigger}"${2}'
			\|  let b:Snippet_gsnipp = "exe 'GlobalSnip ${1:trigger}'${2}"

com! -nargs=+ -bang Snipp cal s:MakeSnippet(<q-args>, 'b', <bang>0)
com! -nargs=+ -bang GlobalSnip cal s:MakeSnippet(<q-args>, 'g', <bang>0)

if !exists('g:snips_author') | let g:snips_author = 'Me' | en

fun! Filename(...)
	let filename = expand('%:t:r')
	if filename == '' | retu a:0 == 2 ? a:2 : '' | en
	retu !a:0 || a:1 == '' ? filename : substitute(a:1, '$1', filename, 'g')
endf

" escapes special characters in snippet triggers
fun s:Hash(text)
	retu substitute(a:text, '\W', '\="_".char2nr(submatch(0))."_"', 'g')
endf

fun s:MakeSnippet(text, scope, bang)
	let space = stridx(a:text, ' ')
	let trigger = s:Hash(strpart(a:text, 0, space))
	if a:bang
		let space += 2
		let quote   = stridx(a:text, '"', space)
		let name    = strpart(a:text, space, quote-space)
		let space   = stridx(a:text, ' ', quote)
		let trigger = a:scope.':Snippets_'.trigger
	el
		let trigger = a:scope.':Snippet_'.trigger
	en
	let end = strpart(a:text, space+1)
	if !exists(trigger) || a:bang
		if end != '' && space != -1 && (!a:bang || name != '')
			if a:bang
				if !exists(trigger) | let {trigger} = [] | en
				let {trigger} += [[name, end]]
			el
				let {trigger} = end
			en
		el
			echoh ErrorMsg
			echom 'Error in snipMate.vim: Snippet '.a:text.' is undefined.'
			echoh None
		en
	el
		echoh WarningMsg
		echom 'Warning in snipMate.vim: Snippet '.strpart(a:text, 0, stridx(a:text, ' '))
				\ .' is already defined. See :h multi_snip for help on snippets'
				\ .' with multiple matches.'
		echoh None
	en
endf

" This updates the snippet as you type when text needs to be inserted
" into multiple places (e.g. in "${1:default text}foo$1bar$1",
" "default text" would be highlighted, and if the user types something,
" UpdateChangedSnip() would be called so that the text after "foo" & "bar"
" are updated accordingly)
"
" It also automatically quits the snippet if the cursor is moved out of it
" while in insert mode.
au CursorMovedI * cal s:UpdateChangedSnip(0)
au InsertEnter * cal s:UpdateChangedSnip(1)
fun s:UpdateChangedSnip(entering)
	if exists('s:update')
		if !exists('s:origPos') && s:curPos+1 < s:snipLen
			" save the old snippet & word length before it's updated
			" s:startSnip must be saved too, in case text is added
			" before the snippet (e.g. in "foo$1${2}bar${1:foo}")
			let s:origSnipPos = s:startSnip
			let s:origPos     = deepcopy(s:snipPos[s:curPos][3])
		en
		let col = col('.')-1

		if s:endSnip != -1
			let changeLen = col('$') - s:prevLen[1]
			let s:endSnip += changeLen
		el " when being updated the first time, after leaving select mode
			if a:entering | retu | en
			let s:endSnip = col-1
		en

		" if the cursor moves outside the snippet, quit it
		if line('.') != s:snipPos[s:curPos][0] || col < s:startSnip ||
					\ col-1 > s:endSnip
			unl! s:startSnip s:origWordLen s:origPos s:update
			cal s:RemoveSnippet()
			retu
		en

		cal s:UpdateSnip()
		let s:prevLen[1] = col('$')
	elsei exists('s:snipPos')
		let col        = col('.')
		let lnum       = line('.')
		let changeLine = line('$') - s:prevLen[0]

		if lnum == s:endSnipLine
			let s:endSnip += col('$') - s:prevLen[1]
			let s:prevLen = [line('$'), col('$')]
		en
		if changeLine != 0 "&& !a:entering
			let s:endSnipLine += changeLine
			let s:endSnip = col
		en

		" delete snippet if cursor moves out of it in insert mode
		if (lnum == s:endSnipLine && (col > s:endSnip || col < s:snipPos[s:curPos][1]))
			\ || lnum > s:endSnipLine || lnum < s:snipPos[s:curPos][0]
			cal s:RemoveSnippet()
		en
	en
endf

fun s:RemoveSnippet()
	unl s:snipPos s:curPos s:snipLen s:endSnip s:endSnipLine s:prevLen
endf

fun s:ChooseSnippet(snippet)
	let snippet = [] | let i = 1
	for snip in {a:snippet}
		let snippet += [i.'. '.snip[0]] | let i += 1
	endfo
	if i == 2 | retu {a:snippet}[0][1] | en
	let num = inputlist(snippet)-1
	retu num < i-1 ? {a:snippet}[num][1] : ''
endf

fun s:Count(haystack, needle)
	let counter = 0
	let index = stridx(a:haystack, a:needle)
	wh index != -1
		let index = stridx(a:haystack, a:needle, index+1)
		let counter += 1
	endw
	retu counter
endf

fun! ExpandSnippet()
	if !exists('s:snipPos') " don't expand snippets within snippets
		" get word under cursor
		let word = matchstr(getline('.'), '\(^\|\s\)\zs\S\+\%'.col('.').'c\ze\($\|\s\)')
		let len = len(word) | let word = s:Hash(word)

		if exists('b:Snippet_'.word)
			let snippet = b:Snippet_{word}
		elsei exists('g:Snippet_'.word)
			let snippet = g:Snippet_{word}
		elsei exists('b:Snippets_'.word)
			let snippet = s:ChooseSnippet('b:Snippets_'.word)
		elsei exists('g:Snippet_'.word)
			let snippet = s:ChooseSnippet('g:Snippets_'.word)
		en

		if exists('snippet')
			if snippet == '' | retu '' | en " if user cancelled multi snippet, quit
			let b:word = word
			" if word is a trigger for a snippet, delete the trigger & expand
			" the snippet (BdE doesn't work for just a single character)
			if len == 1 | norm! h"_x
			el | norm! B"_dE
			en
			let lnum = line('.')
			let col = col('.')

			let afterCursor = strpart(getline('.'), col-1)
			if afterCursor != "\t" && afterCursor != ' ' | sil s/\%#.*//
			el | let afterCursor = '' | en

			" evaluate eval expressions
			if stridx(snippet, '`') != -1
				let snippet = substitute(substitute(snippet, '`\(.\{-}\)`',
							\ '\=substitute(eval(submatch(1)), "\n\\%$", "", "")', 'g'),
							\ "\r", "\n", 'g')
				if snippet == '' | retu '' | en " avoid an error if the snippet is now empty
			en

			" place all text after a colon in a tab stop after the tab stop
			" (e.g. "${#:foo}" becomes "${:foo}foo")
			" this helps tell the position of the tab stops later.
			let snippet = substitute(snippet, '${\d:\(.\{-}\)}', '&\1', 'g')

			" update the snippet so that all the $# become
			" the text after the colon in their associated ${#}
			" (e.g. "${1:foo}" turns all "$1"'s into "foo")
			let i = 1
			wh stridx(snippet, '${'.i) != -1
				let s = matchstr(snippet, '${'.i.':\zs.\{-}\ze}')
				if s != ''
					let snippet = substitute(snippet, '$'.i, '&'.s, 'g')
				en
				let i += 1
			endw
			" expand tabs to spaces if 'expandtab' is set
			if &et | let snippet = substitute(snippet, '\t', repeat(' ', &sts), 'g') | en

			let snip = split(substitute(snippet, '$\d\|${\d.\{-}}', '', 'g'), "\n", 1)
			if afterCursor != '' | let snip[-1] .= afterCursor | en
			let line = getline(lnum)
			cal setline(lnum, line.snip[0])

			" for some reason the cursor needs to move one right after this
			if line != '' && afterCursor == '' && &ve != 'all' && &ve != 'onemore'
				let col += 1
			en
			" autoindent snippet according to previous indentation
			let tab = matchstr(line, '^.\{-}\ze\(\S\|$\)')
			cal append(lnum, tab != '' ? map(snip[1:], "'".tab."'.v:val") : snip[1:])
			let tab = len(tab)+1 | let col -= tab

			" Sorry, this next section is a bit convoluted...
			" This loop builds a list of a list of each tab stop in the snippet
			" containing:
			" 1.) The number of the current line plus the number of "\n"s (line
			" breaks) before the tab stop
			" 2.) The current column plus the position of the next "${#}" on
			" the line by getting the length of the string between the last "\n"
			" and the "${#}" tab stop,
			" 3.) The length of the text after the colon for the current tab stop
			" (e.g. "${#:foo}" would return 3). If there is no text, -1 is returned.
			" 4.) If the "${#:}" construct is given, the fourth part of the list
			" is another list containing all the matches of "$#", to be replaced
			" with the variable. This list is composed the same way as the parent:
			" the first part is the number of "\n"s before the tab stop, and
			" second is the position (column) of the "$#" tab stop on the line.
			" If there are none of these tab stop, an empty list ([]) is returned
			let s:snipPos = [] | let i = 1
			" temporarily delete placeholders
			let cut_snip = substitute(snippet, '$\d', '', 'g')
			wh stridx(snippet, '${'.i) != -1
				let s:snipPos += [[lnum+s:Count(matchstr(cut_snip, '^.*\ze${'.i), "\n"),
				\ tab+len(matchstr(substitute(cut_snip, '${'.i.'\@!\d.\{-}}', '', 'g'),
				\ "^.*\\(\n\\|^\\)\\zs.*\\ze${".i.'.\{-}}')), -1]]
				if s:snipPos[i-1][0] == lnum | let s:snipPos[i-1][1] += col | en

				" get all $# matches in another list, if ${#:name} is given
				if stridx(cut_snip, '${'.i.':') != -1
					let j = i-1
					let s:snipPos[j][2] = len(matchstr(cut_snip, '${'.i.':\zs.\{-}\ze}'))
					let s:snipPos[j] += [[]]
					" temporarily delete all other tab stops/placeholders
					let tempstr = substitute(snippet, '$'.i.'\@!\d\|${\d.\{-}}', '', 'g')
					wh stridx(tempstr, '$'.i) != -1
						let beforeMark = matchstr(tempstr, '^.\{-}\ze$'.i)
						let linecount = lnum+s:Count(beforeMark, "\n")
						let s:snipPos[j][3] += [[linecount,
								\ tab+(linecount > lnum ?
								\ len(matchstr(beforeMark, "^.*\n\\zs.*"))
								\ : col+len(beforeMark))]]
						let tempstr = substitute(tempstr, '$'.i, '', '')
					endw
				en
				let i += 1
			endw

			if i > 1 " if snippet is not empty
				let s:curPos      = 0
				let s:snipLen     = i-1
				let s:endSnip     = s:snipPos[0][1]
				let s:endSnipLine = s:snipPos[s:curPos][0]

				cal cursor(s:snipPos[0][0], s:snipPos[0][1])
				let s:prevLen = [line('$'), col('$')]
				if s:snipPos[0][2] != -1 | retu s:SelectWord() | en
			el
				unl s:snipPos
				" place cursor at end of snippet if no tab stop is given
				let len = len(snip)-1
				cal cursor(lnum+len, tab+len(snip[-1])+(len ? 0 : col))
			en
			retu ''
		en
		if !exists('s:sid') && exists('g:SuperTabMappingForward')
					\ && g:SuperTabMappingForward == "<tab>"
			cal s:GetSuperTabSID()
		en
		retu exists('s:sid') ? {s:sid}_SuperTab('n') : "\<tab>"
	en

	if exists('s:update')
		" update tab stops in snippet if text has been added via "$#",
		" e.g. in "${1:foo}bar$1${2}"
		if exists('s:origPos')
			let changeLen = s:origWordLen - s:snipPos[s:curPos][2]

			" This could probably be more efficent...
			if changeLen != 0
				let lnum = line('.')
				let len = len(s:origPos)
				for pos in s:snipPos[(s:curPos+1):]
					let i = 0 | let j = 0 | let k = 0
					let endSnip = pos[2]+pos[1]-1
					wh i < len && s:origPos[i][0] <= pos[0]
						if pos[0] == s:origPos[i][0]
							if pos[1] > s:origPos[i][1]
								\ || (pos[2] == -1 && pos[1] == s:origPos[i][1])
								let j += 1
							elsei s:origPos[i][1] < endSnip " parse variables within placeholders
								let k += 1
							en
						en
						let i += 1
					endw
					if pos[0] == lnum && pos[1] > s:origSnipPos | let j += 1 | en
					let pos[1] -= changeLen*j | let pos[2] -= changeLen*k

					if pos[2] != -1
						for nPos in pos[3]
							let i = 0 | let j = 0
							wh i < len && s:origPos[i][0] <= nPos[0]
								if nPos[0] == s:origPos[i][0] && nPos[1] > s:origPos[i][1]
									let j += 1
								en
								let i += 1
							endw
							if nPos[0] == lnum && nPos[1] > s:origSnipPos | let j += 1 | en
							if nPos[0] > s:origPos[0][0] | brea | en
							let nPos[1] -= changeLen*j
						endfo
					en
				endfo
			en
			unl s:endSnip s:origPos s:origSnipPos
		en
		let changeLine = 0
		let changeCol  = 0
		unl s:startSnip s:origWordLen s:update
	el
		let changeLine = s:endSnipLine - s:snipPos[s:curPos][0]
		let changeCol  = s:endSnip - s:snipPos[s:curPos][1]
		if exists('s:origWordLen')
			let changeCol -= s:origWordLen | unl s:origWordLen
		en
	en

	let s:curPos += 1
	if s:curPos == s:snipLen
		let sMode = s:endSnip == s:snipPos[s:curPos-1][1]+s:snipPos[s:curPos-1][2]
		cal s:RemoveSnippet()
		retu sMode ? "\<tab>" : ExpandSnippet()
	en
	if changeLine != 0 || changeCol != 0
		" there's probably a more efficient way to do this as well...
		let lnum = s:snipPos[s:curPos-1][0]
		let col  = s:snipPos[s:curPos-1][1]
		" update the line number of all proceeding tab stops if <cr> has
		" been inserted
		if changeLine != 0
			for pos in s:snipPos[(s:curPos):]
				if pos[0] >= lnum
					if pos[0] == lnum | let pos[1] += changeCol | en
					let pos[0] += changeLine
				en
				if pos[2] != -1
					for nPos in pos[3]
						if nPos[0] >= lnum
							if nPos[0] == lnum | let nPos[1] += changeCol | en
							let nPos[0] += changeLine
						en
					endfo
				en
			endfo
		el
			" update the column of all proceeding tab stops if text has
			" been inserted/deleted in the current line
			for pos in s:snipPos[(s:curPos):]
				if pos[1] >= col && pos[0] == lnum
					let pos[1] += changeCol
				en
				if pos[2] != -1
					for nPos in pos[3]
						if nPos[0] > lnum | brea | en
						if nPos[0] == lnum && nPos[1] >= col
							let nPos[1] += changeCol
						en
					endfo
				en
			endfo
		en
	en
	cal cursor(s:snipPos[s:curPos][0], s:snipPos[s:curPos][1])

	let s:endSnipLine = s:snipPos[s:curPos][0]
	let s:endSnip     = s:snipPos[s:curPos][1]
	let s:prevLen     = [line('$'), col('$')]

	if s:snipPos[s:curPos][2] != -1 | retu s:SelectWord() | en
	retu ''
endf

fun s:GetSuperTabSID()
	let a_save = @a
	redir @a
	exe 'sil fu /SuperTab$'
	redir END
	let s:sid = matchstr(@a, '<SNR>\d\+\ze_SuperTab(command)')
	let @a = a_save
endf

fun s:SelectWord()
	let s:origWordLen = s:snipPos[s:curPos][2]
	let s:oldWord     = strpart(getline('.'), s:snipPos[s:curPos][1]-1,
								\ s:origWordLen)
	let s:prevLen[1] -= s:origWordLen
	if !empty(s:snipPos[s:curPos][3])
		let s:update    = 1
		let s:endSnip   = -1
		let s:startSnip = s:snipPos[s:curPos][1]-1
	en
	if !s:origWordLen | retu '' | en
	let l = col('.') != 1 ? 'l' : ''
	if &sel == 'exclusive' | retu "\<esc>".l.'v'.s:origWordLen."l\<c-g>" | en
	retu "\<esc>".l.(s:origWordLen == 1 ? 'gh' : 'v'.(s:origWordLen-1)."l\<c-g>")
endf

fun s:UpdateSnip()
	" using strpart() here avoids a bug if s:endSnip is negative that would
	" happen with the getline('.')[(s:startSnip):(s:endSnip)] syntax
	let newWordLen = s:endSnip - s:startSnip + 1
	let newWord    = strpart(getline('.'), s:startSnip, newWordLen)
	if newWord != s:oldWord
		let changeLen    = s:snipPos[s:curPos][2] - newWordLen
		let curLine      = line('.')
		let startCol     = col('.')
		let oldStartSnip = s:startSnip
		let updateSnip   = changeLen != 0
		let i            = 0

		for pos in s:snipPos[s:curPos][3]
			if updateSnip
					let start = s:startSnip
					if pos[0] == curLine && pos[1] <= start
						let s:startSnip -= changeLen
						let s:endSnip -= changeLen
					en
					for nPos in s:snipPos[s:curPos][3][(i):]
						if nPos[0] == pos[0]
							if nPos[1] > pos[1] || (nPos == [curLine, pos[1]] &&
													\ nPos[1] > start)
								let nPos[1] -= changeLen
							en
						elsei nPos[0] > pos[0]
							brea
						en
					endfo
					let i += 1
			en

			cal setline(pos[0], substitute(getline(pos[0]), '\%'.pos[1].'c'.
						\ s:oldWord, newWord, ''))
		endfo
		if oldStartSnip != s:startSnip
			cal cursor('.', startCol + s:startSnip - oldStartSnip)
		en

		let s:oldWord = newWord
		let s:snipPos[s:curPos][2] = newWordLen
	en
endf
" vim:sw=4:ts=4:ft=vim
