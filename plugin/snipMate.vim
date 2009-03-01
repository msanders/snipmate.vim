" File:          snipMate.vim
" Author:        Michael Sanders
" Version:       0.71
" Description:   snipMate.vim implements some of TextMate's snippets features in
"                Vim. A snippet is a piece of often-typed text that you can
"                insert into your document using a trigger word followed by a "<tab>".
"
"                For more help see snipMate.txt; you can do this by using:
"                :helptags ~/.vim/doc
"                :h snipMate.txt
" Last Modified: February 28, 2009.

if exists('loaded_snips') || &cp || version < 700
	finish
endif
let loaded_snips = 1
if !exists('snips_author') | let snips_author = 'Me' | endif

com! -nargs=+ -bang Snipp call s:MakeSnippet(<q-args>, &ft, <bang>0)
com! -nargs=+ -bang GlobalSnip call s:MakeSnippet(<q-args>, '_', <bang>0)

let s:snippets = {} | let s:multi_snips = {}

fun! Filename(...)
	let filename = expand('%:t:r')
	if filename == '' | return a:0 == 2 ? a:2 : '' | endif
	return !a:0 || a:1 == '' ? filename : substitute(a:1, '$1', filename, 'g')
endf

" escapes special characters in snippet triggers
fun s:Hash(text)
	return substitute(a:text, '\W', '\="_".char2nr(submatch(0))."_"', 'g')
endf

fun s:MakeSnippet(text, ft, multisnip)
	let space = stridx(a:text, ' ')
	let trigger = s:Hash(strpart(a:text, 0, space))
	if a:multisnip
		let space += 2
		let quote  = stridx(a:text, '"', space)
		let name   = strpart(a:text, space, quote-space)
		let space  = stridx(a:text, ' ', quote)
		let var    = 's:multi_snips'
	else
		let var = 's:snippets'
	endif
	if !has_key({var}, a:ft) | let {var}[a:ft] = {} | endif
	let end = strpart(a:text, space+1)

	if end == '' || space == '' || (a:multisnip && name == '')
		echom 'Error in snipMate.vim: Snippet '.a:text.' is undefined.'
	elseif !has_key({var}[a:ft], trigger)
		let {var}[a:ft][trigger] = a:multisnip ? [[name, end]] : end
	elseif a:multisnip | let {var}[a:ft][trigger] += [[name, end]]
	else
		echom 'Warning in snipMate.vim: Snippet '.strpart(a:text, 0, stridx(a:text, ' '))
				\ .' is already defined. See :h multi_snip for help on snippets'
				\ .' with multiple matches.'
	endif
endf

fun! ExtractSnips(dir, ft)
	let s:slash = has('win16') || has('win32') || has('win64') ? '\\' : '/'
	for path in split(globpath(a:dir, '*'), "\n")
		if isdirectory(path)
			for snipFile in split(globpath(path, '*.snippet'), "\n")
				call s:ProcessFile(snipFile, a:ft,
									\ strpart(path, strridx(path, s:slash)+1))
			endfor
		else
			call s:ProcessFile(path, a:ft)
		endif
	endfor
	unl s:slash
	let g:did_ft_{a:ft} = 1
endf

" Processes a snippet file; optionally add the name of the parent directory
" for a snippet with multiple matches.
fun s:ProcessFile(file, ft, ...)
	let keyword = matchstr(a:file, '.*'.s:slash.'\zs.*\ze\.snippet')
	if keyword  == '' | return | endif
	try
		let text = join(readfile(a:file), "\n")
	catch /E484/
		echom "Error in snipMate.vim: couldn't read file: ".a:file
	endtry
	return a:0 ? s:MakeSnippet(a:1.' "'.keyword.'" '.text, a:ft, 1)
			\  : s:MakeSnippet(keyword.' '.text, a:ft, 0)
endf

fun! ResetSnippets()
	let s:snippets = {} | let s:multi_snips = {}
endf

fun s:RemoveSnippet()
	unl s:snipPos s:curPos s:snipLen s:endSnip s:endSnipLine s:prevLen
endf

fun s:ChooseSnippet(ft, trigger)
	let snippet = []
	let i = 1
	for snip in s:multi_snips[a:ft][a:trigger]
		let snippet += [i.'. '.snip[0]]
		let i += 1
	endfor
	if i == 2 | return s:multi_snips[a:ft][a:trigger][0][1] | endif
	let num = inputlist(snippet)-1
	return num < i-1 ? s:multi_snips[a:ft][a:trigger][num][1] : ''
endf

fun! TriggerSnippet()
	if pumvisible() " update snippet if completion is used, or deal with supertab
		if exists('s:sid') | return "\<c-n>" | endif
		call feedkeys("\<esc>a", 'n') | call s:UpdateChangedSnip(0)
	endif

	if !exists('s:sid') && exists('g:SuperTabMappingForward')
				\ && g:SuperTabMappingForward == "<tab>"
		call s:GetSuperTabSID()
	endif

	for filetype in split(&ft, '\.') " deal with dotted file-types
		let word = s:GetSnippet(filetype)
		if exists('s:snippet') | break | endif
	endfor

	" if word is a trigger for a snippet, delete the trigger & expand the snippet
	if exists('s:snippet')
		if s:snippet == '' " if user cancelled a multi snippet, quit
			return unl s:snippet
		endif
		let col = col('.')-len(word)
		sil exe 's/'.escape(word, '.^$/\*[]').'\%#//'
		return s:ExpandSnippet(col)
	elseif exists('s:snipPos')
		return s:JumpTabStop()
	endif
	return exists('s:sid') ? {s:sid}_SuperTab('n') : "\<tab>"
endf

" Check if word under cursor is snippet trigger; if it isn't, try checking if
" the text after non-word characters is (e.g. check for "foo" in "bar.foo")
fun s:GetSnippet(ft)
	let origWord = matchstr(getline('.'), '\S\+\%'.col('.').'c')
	wh !exists('s:snippet')
		let word = s:Hash(origWord)
		if exists('s:snippets["'.a:ft.'"]["'.word.'"]')
			let s:snippet = s:snippets[a:ft][word]
		elseif exists('s:snippets["_"]["'.word.'"]')
			let s:snippet = s:snippets['_'][word]
		elseif exists('s:multi_snips["'.a:ft.'"]["'.word.'"]')
			let s:snippet = s:ChooseSnippet(a:ft, word)
		elseif exists('s:multi_snips["_"]["'.word.'"]')
			let s:snippet = s:ChooseSnippet('_', word)
		else
			if match(origWord, '\W') == -1 | break | endif
			let origWord = substitute(origWord, '.\{-}\W', '', '')
		endif
	endw
	return origWord
endf

fun s:GetSuperTabSID()
	let old = @a
	redir @a | exe 'sil fun /SuperTab$' | redir END
	let s:sid = matchstr(@a, '<SNR>\d\+\ze_SuperTab(command)')
	let @a = old
endf

fun s:ExpandSnippet(col)
	let lnum = line('.') | let col = a:col
	let afterCursor = strpart(getline('.'), col-1)
	if afterCursor != "\t" && afterCursor != ' '
		sil exe 's/\%'.col.'c.*//'
	else | let afterCursor = '' | endif

	" for some reason the cursor needs to move one right after this
	let line = getline(lnum)
	if line != '' && col == 1 && afterCursor == '' && &ve !~ 'all\|onemore'
		let col += 1
	endif

	call s:ProcessSnippet()
	if s:snippet == ''
		return unl s:snippet " avoid an error if the snippet is now empty
	endif

	let snip = split(substitute(s:snippet, '$\d\|${\d.\{-}}', '', 'g'), "\n", 1)
	if afterCursor != '' | let snip[-1] .= afterCursor | endif
	call setline(lnum, line.snip[0])

	" autoindent snippet according to previous indentation
	let indent = matchend(line, '^.\{-}\ze\(\S\|$\)')+1
	call append(lnum, map(snip[1:], "'".strpart(line, 0, indent-1)."'.v:val"))

	if exists('s:snipPos') " update tab stops if expanding nested snip
		if exists('s:update')
			call s:UpdateSnip(len(snip[-1])-len(afterCursor))
			call s:UpdatePlaceholderTabStops()
		else
			call s:UpdateTabStops(len(snip)-1, len(snip[-1])-len(afterCursor))
		endif
	endif

	let snipLen = s:BuildTabStops(lnum, col-indent, indent)
	unl s:snippet

	if snipLen
		if exists('s:snipLen')
			let s:snipLen += snipLen | let s:curPos += 1
		else
			let s:snipLen = snipLen | let s:curPos = 0
		endif
		let s:endSnip     = s:snipPos[s:curPos][1]
		let s:endSnipLine = s:snipPos[s:curPos][0]

		call cursor(s:snipPos[s:curPos][0], s:snipPos[s:curPos][1])
		let s:prevLen = [line('$'), col('$')]
		if s:snipPos[s:curPos][2] != -1 | return s:SelectWord() | endif
	else
		if !exists('s:snipLen') | unl s:snipPos | endif
		" place cursor at end of snippet if no tab stop is given
		let newlines = len(snip)-1
		call cursor(lnum + newlines, indent + len(snip[-1]) - len(afterCursor)
					\ + (newlines ? -1: col))
	endif
	return ''
endf

fun s:ProcessSnippet()
	" evaluate eval (`...`) expressions
	" Using a loop here instead of a regex fixes a bug with nested "\="
	if stridx(s:snippet, '`') != -1
		wh match(s:snippet, '`.\{-}`') != -1
			let s:snippet = substitute(s:snippet, '`.\{-}`',
						\ substitute(eval(matchstr(s:snippet, '`\zs.\{-}\ze`')),
						\ "\n\\%$", '', ''), '')
		endw
		let s:snippet = substitute(s:snippet, "\r", "\n", 'g')
	endif

	" place all text after a colon in a tab stop after the tab stop
	" (e.g. "${#:foo}" becomes "${:foo}foo")
	" this helps tell the position of the tab stops later.
	let s:snippet = substitute(s:snippet, '${\d:\(.\{-}\)}', '&\1', 'g')

	" update the s:snippet so that all the $# become
	" the text after the colon in their associated ${#}
	" (e.g. "${1:foo}" turns all "$1"'s into "foo")
	let i = 1
	wh stridx(s:snippet, '${'.i) != -1
		let s = matchstr(s:snippet, '${'.i.':\zs.\{-}\ze}')
		if s != ''
			let s:snippet = substitute(s:snippet, '$'.i, '&'.s, 'g')
		endif
		let i += 1
	endw

	if &et " expand tabs to spaces if 'expandtab' is set
		let s:snippet = substitute(s:snippet, '\t',
						\ repeat(' ', &sts ? &sts : &sw), 'g')
	endif
endf

fun s:Count(haystack, needle)
	let counter = 0
	let index = stridx(a:haystack, a:needle)
	wh index != -1
		let index = stridx(a:haystack, a:needle, index+1)
		let counter += 1
	endw
	return counter
endf

" Sorry, this next function is a bit convoluted...
" This function builds a list of a list of each tab stop in the snippet
" containing:
" 1.) The number of the current line plus the number of "\n"s (line
" breaks) before the tab stop
" 2.) The current column plus the position of the next "${#}" on
" the line by getting the length of the string between the last "\n"
" and the "${#}" tab stop,
" 3.) The length of the text after the colon for the current tab stop
" (e.g. "${#:foo}" would returnrn 3). If there is no text, -1 is returnrned.
" 4.) If the "${#:}" construct is given, the fourth part of the list
" is another list containing all the matches of "$#", to be replaced
" with the variable. This list is composed the same way as the parent:
" the first part is the number of "\n"s before the tab stop, and
" second is the position (column) of the "$#" tab stop on the line.
" If there are none of these tab stop, an empty list ([]) is returnrned
fun s:BuildTabStops(lnum, col, indent)
	let snipPos = [] | let i = 1
	" temporarily delete placeholders
	let cut_snip = substitute(s:snippet, '$\d', '', 'g')
	wh stridx(s:snippet, '${'.i) != -1
		let snipPos += [[a:lnum+s:Count(matchstr(cut_snip, '^.*\ze${'.i), "\n"),
				\ a:indent+len(matchstr(substitute(cut_snip, '${'.i.'\@!\d.\{-}}', '', 'g'),
				\ "^.*\\(\n\\|^\\)\\zs.*\\ze${".i.'.\{-}}')), -1]]
		if snipPos[i-1][0] == a:lnum
			let snipPos[i-1][1] += a:col
		endif

		" get all $# matches in another list, if ${#:name} is given
		if stridx(cut_snip, '${'.i.':') != -1
			let j = i-1
			let snipPos[j][2] = len(matchstr(cut_snip, '${'.i.':\zs.\{-}\ze}'))
			let snipPos[j] += [[]]
			" temporarily delete all other tab stops/placeholders
			let tempstr = substitute(s:snippet, '$'.i.'\@!\d\|${\d.\{-}}', '', 'g')
			wh stridx(tempstr, '$'.i) != -1
				let beforeMark = matchstr(tempstr, '^.\{-}\ze$'.i)
				let linecount = a:lnum+s:Count(beforeMark, "\n")
				let snipPos[j][3] += [[linecount,
							\ a:indent+(linecount > a:lnum ?
							\ len(matchstr(beforeMark, "^.*\n\\zs.*"))
							\ : a:col+len(beforeMark))]]
				let tempstr = substitute(tempstr, '$'.i, '', '')
			endw
		endif
		let i += 1
	endw
	if exists('s:snipPos') " allow nested snippets
		let s:snipPos = extend(s:snipPos, snipPos, s:curPos+1)
	else
		let s:snipPos = snipPos
	endif
	return i-1
endf

fun s:JumpTabStop()
	if exists('s:update')
		call s:UpdatePlaceholderTabStops()
		let updated = 1
	endif
	let s:curPos += 1
	if s:curPos == s:snipLen
		let sMode = s:endSnip == s:snipPos[s:curPos-1][1]+s:snipPos[s:curPos-1][2]
		call s:RemoveSnippet()
		return sMode ? "\<tab>" : TriggerSnippet()
	endif
	if !exists('updated') | call s:UpdateTabStops() | endif

	call cursor(s:snipPos[s:curPos][0], s:snipPos[s:curPos][1])

	let s:endSnipLine = s:snipPos[s:curPos][0]
	let s:endSnip     = s:snipPos[s:curPos][1]
	let s:prevLen     = [line('$'), col('$')]

	return s:snipPos[s:curPos][2] == -1 ? '' : s:SelectWord()
endf

fun s:UpdatePlaceholderTabStops()
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
						elseif s:origPos[i][1] < endSnip " parse variables within placeholders
							let k += 1
						endif
					endif
					let i += 1
				endw
				if pos[0] == lnum && pos[1] > s:origSnipPos
					let j += 1
				endif
				let pos[1] -= changeLen*j
				let pos[2] -= changeLen*k

				if pos[2] != -1
					for nPos in pos[3]
						let i = 0 | let j = 0
						wh i < len && s:origPos[i][0] <= nPos[0]
							if nPos[0] == s:origPos[i][0] && nPos[1] > s:origPos[i][1]
								let j += 1
							endif
							let i += 1
						endw
						if nPos[0] == lnum && nPos[1] > s:origSnipPos
							let j += 1
						endif
						if nPos[0] > s:origPos[0][0] | break | endif
						let nPos[1] -= changeLen*j
					endfor
				endif
			endfor
		endif
		unl s:endSnip s:origPos s:origSnipPos
	endif
	unl s:startSnip s:origWordLen s:update
endf

fun s:UpdateTabStops(...)
	let changeLine = a:0 ? a:1 : s:endSnipLine - s:snipPos[s:curPos-1][0]
	let changeCol  = a:0 > 1 ? a:2 : s:endSnip - s:snipPos[s:curPos-1][1]
	if exists('s:origWordLen')
		let changeCol -= s:origWordLen | unl s:origWordLen
	endif
	" there's probably a more efficient way to do this as well...
	let lnum = s:snipPos[s:curPos-1][0]
	let col  = s:snipPos[s:curPos-1][1]
	" update the line number of all proceeding tab stops if <cr> has
	" been inserted
	if changeLine != 0
		for pos in s:snipPos[(s:curPos):]
			if pos[0] >= lnum
				if pos[0] == lnum
					let pos[1] += changeCol
				endif
				let pos[0] += changeLine
			endif
			if pos[2] != -1
				for nPos in pos[3]
					if nPos[0] >= lnum
						if nPos[0] == lnum
							let nPos[1] += changeCol
						endif
						let nPos[0] += changeLine
					endif
				endfor
			endif
		endfor
	elseif changeCol != 0
		" update the column of all proceeding tab stops if text has
		" been inserted/deleted in the current line
		for pos in s:snipPos[(s:curPos):]
			if pos[1] >= col && pos[0] == lnum
				let pos[1] += changeCol
			endif
			if pos[2] != -1
				for nPos in pos[3]
					if nPos[0] > lnum | break | endif
					if nPos[0] == lnum && nPos[1] >= col
						let nPos[1] += changeCol
					endif
				endfor
			endif
		endfor
	endif
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
	endif
	if !s:origWordLen | return '' | endif
	let l = col('.') != 1 ? 'l' : ''
	if &sel == 'exclusive'
		return "\<esc>".l.'v'.s:origWordLen."l\<c-g>"
	endif
	return s:origWordLen == 1 ? "\<esc>".l.'gh'
							\ : "\<esc>".l.'v'.(s:origWordLen-1)."l\<c-g>"
endf

" This updates the snippet as you type when text needs to be inserted
" into multiple places (e.g. in "${1:default text}foo$1bar$1",
" "default text" would be highlighted, and if the user types something,
" UpdateChangedSnip() would be called so that the text after "foo" & "bar"
" are updated accordingly)
"
" It also automatically quits the snippet if the cursor is moved out of it
" while in insert mode.
au CursorMovedI * call s:UpdateChangedSnip(0)
au InsertEnter * call s:UpdateChangedSnip(1)
fun s:UpdateChangedSnip(entering)
	if exists('s:update')
		if !exists('s:origPos') && s:curPos+1 < s:snipLen
			" save the old snippet & word length before it's updated
			" s:startSnip must be saved too, in case text is added
			" before the snippet (e.g. in "foo$1${2}bar${1:foo}")
			let s:origSnipPos = s:startSnip
			let s:origPos     = deepcopy(s:snipPos[s:curPos][3])
		endif
		let col = col('.')-1

		if s:endSnip != -1
			let changeLen = col('$') - s:prevLen[1]
			let s:endSnip += changeLen
		else " when being updated the first time, after leaving select mode
			if a:entering | return | endif
			let s:endSnip = col-1
		endif

		" if the cursor moves outside the snippet, quit it
		if line('.') != s:snipPos[s:curPos][0] || col < s:startSnip ||
					\ col-1 > s:endSnip
			unl! s:startSnip s:origWordLen s:origPos s:update
			return s:RemoveSnippet()
		endif

		call s:UpdateSnip()
		let s:prevLen[1] = col('$')
	elseif exists('s:snipPos')
		let col        = col('.')
		let lnum       = line('.')
		let changeLine = line('$') - s:prevLen[0]

		if lnum == s:endSnipLine
			let s:endSnip += col('$') - s:prevLen[1]
			let s:prevLen = [line('$'), col('$')]
		endif
		if changeLine != 0
			let s:endSnipLine += changeLine
			let s:endSnip = col
		endif

		" delete snippet if cursor moves out of it in insert mode
		if (lnum == s:endSnipLine && (col > s:endSnip || col < s:snipPos[s:curPos][1]))
			\ || lnum > s:endSnipLine || lnum < s:snipPos[s:curPos][0]
			call s:RemoveSnippet()
		endif
	endif
endf

fun s:UpdateSnip(...)
	" using strpart() here avoids a bug if s:endSnip is negative that would
	" happen with the getline('.')[(s:startSnip):(s:endSnip)] syntax
	let newWordLen = a:0 ? a:1 : s:endSnip - s:startSnip + 1
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
				endif
				for nPos in s:snipPos[s:curPos][3][(i):]
					if nPos[0] == pos[0]
						if nPos[1] > pos[1] || (nPos == [curLine, pos[1]] &&
												\ nPos[1] > start)
							let nPos[1] -= changeLen
						endif
					elseif nPos[0] > pos[0] | break | endif
				endfor
				let i += 1
			endif

			call setline(pos[0], substitute(getline(pos[0]), '\%'.pos[1].'c'.
						\ s:oldWord, newWord, ''))
		endfor
		if oldStartSnip != s:startSnip
			call cursor('.', startCol + s:startSnip - oldStartSnip)
		endif

		let s:oldWord = newWord
		let s:snipPos[s:curPos][2] = newWordLen
	endif
endf
" vim:noet:sw=4:ts=4:ft=vim
