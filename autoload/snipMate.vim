fun! Filename(...)
	let filename = expand('%:t:r')
	if filename == '' | return a:0 == 2 ? a:2 : '' | endif
	return !a:0 || a:1 == '' ? filename : substitute(a:1, '$1', filename, 'g')
endf

fun s:RemoveSnippet()
	unl g:snipPos s:curPos s:snipLen s:endSnip s:endSnipLine s:prevLen
endf

fun snipMate#expandSnip(col)
	let lnum = line('.') | let col = a:col

	call s:ProcessSnippet()
	if g:snippet == ''
		unl g:snippet | return '' " Avoid an error if the snippet is now empty
	endif

	let snip = split(substitute(g:snippet, '$\d\|${\d.\{-}}', '', 'g'), "\n", 1)

	let line = getline(lnum)
	let afterCursor = strpart(line, col - 1)
	if afterCursor != "\t" && afterCursor != ' '
		let line = strpart(line, 0, col - 1)
		let snip[-1] .= afterCursor
	else
		let afterCursor = ''
		" For some reason the cursor needs to move one right after this
		if line != '' && col == 1 && &ve !~ 'all\|onemore'
			let col += 1
		endif
	endif

	call setline(lnum, line.snip[0])

	" Autoindent snippet according to previous indentation
	let indent = matchend(line, '^.\{-}\ze\(\S\|$\)') + 1
	call append(lnum, map(snip[1:], "'".strpart(line, 0, indent - 1)."'.v:val"))
	if &fen | sil! exe lnum.','.(lnum + len(snip) - 1).'foldopen' | endif

	let snipLen = s:BuildTabStops(lnum, col - indent, indent)
	unl g:snippet

	if snipLen
		let s:snipLen     = snipLen
		let s:curPos      = 0
		let s:endSnip     = g:snipPos[s:curPos][1]
		let s:endSnipLine = g:snipPos[s:curPos][0]

		call cursor(g:snipPos[s:curPos][0], g:snipPos[s:curPos][1])
		let s:prevLen = [line('$'), col('$')]
		if g:snipPos[s:curPos][2] != -1 | return s:SelectWord() | endif
	else
		unl g:snipPos
		" Place cursor at end of snippet if no tab stop is given
		let newlines = len(snip) - 1
		call cursor(lnum + newlines, indent + len(snip[-1]) - len(afterCursor)
					\ + (newlines ? 0: col - 1))
	endif
	return ''
endf

fun s:ProcessSnippet()
	" Evaluate eval (`...`) expressions.
	" Using a loop here instead of a regex fixes a bug with nested "\=".
	if stridx(g:snippet, '`') != -1
		wh match(g:snippet, '`.\{-}`') != -1
			let g:snippet = substitute(g:snippet, '`.\{-}`',
						\ substitute(eval(matchstr(g:snippet, '`\zs.\{-}\ze`')),
						\ "\n\\%$", '', ''), '')
		endw
		let g:snippet = substitute(g:snippet, "\r", "\n", 'g')
	endif

	" Place all text after a colon in a tab stop after the tab stop
	" (e.g. "${#:foo}" becomes "${:foo}foo").
	" This helps tell the position of the tab stops later.
	let g:snippet = substitute(g:snippet, '${\d:\(.\{-}\)}', '&\1', 'g')

	" Update the g:snippet so that all the $# become
	" the text after the colon in their associated ${#}.
	" (e.g. "${1:foo}" turns all "$1"'s into "foo")
	let i = 1
	wh stridx(g:snippet, '${'.i) != -1
		let s = matchstr(g:snippet, '${'.i.':\zs.\{-}\ze}')
		if s != ''
			let g:snippet = substitute(g:snippet, '$'.i, '&'.s, 'g')
		endif
		let i += 1
	endw

	if &et " Expand tabs to spaces if 'expandtab' is set.
		let g:snippet = substitute(g:snippet, '\t',
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

" This function builds a list of a list of each tab stop in the
" snippet containing:
" 1.) The tab stop's line number.
" 2.) The tab stop's column number
"     (by getting the length of the string between the last "\n" and the
"     tab stop).
" 3.) The length of the text after the colon for the current tab stop
"     (e.g. "${1:foo}" would return 3). If there is no text, -1 is returned.
" 4.) If the "${#:}" construct is given, another list containing all
"     the matches of "$#", to be replaced with the placeholder. This list is
"     composed the same way as the parent; the first item is the line number,
"     and the second is the column.
fun s:BuildTabStops(lnum, col, indent)
	let snipPos = []
	let i = 1
	let withoutVars = substitute(g:snippet, '$\d', '', 'g')
	wh stridx(g:snippet, '${'.i) != -1
		let beforeTabStop = matchstr(withoutVars, '^.*\ze${'.i)
		let withoutOthers = substitute(withoutVars, '${'.i.'\@!\d.\{-}}', '', 'g')
		let snipPos += [[a:lnum + s:Count(beforeTabStop, "\n"),
						\ a:indent + len(matchstr(withoutOthers,
						\ "^.*\\(\n\\|^\\)\\zs.*\\ze${".i)), -1]]
		if snipPos[i-1][0] == a:lnum
			let snipPos[i-1][1] += a:col
		endif

		" Get all $# matches in another list, if ${#:name} is given
		if stridx(withoutVars, '${'.i.':') != -1
			let j = i-1
			let snipPos[j][2] = len(matchstr(withoutVars, '${'.i.':\zs.\{-}\ze}'))
			let snipPos[j] += [[]]
			let withoutOthers = substitute(g:snippet, '${\d.\{-}}\|$'.i.'\@!\d', '', 'g')
			wh stridx(withoutOthers, '$'.i) != -1
				let beforeMark = matchstr(withoutOthers, '^.\{-}\ze$'.i)
				let linecount = a:lnum + s:Count(beforeMark, "\n")
				let snipPos[j][3] += [[linecount,
							\ a:indent + (linecount > a:lnum
							\ ? len(matchstr(beforeMark, "^.*\n\\zs.*"))
							\ : a:col + len(beforeMark))]]
				let withoutOthers = substitute(withoutOthers, '$'.i, '', '')
			endw
		endif
		let i += 1
	endw

	let g:snipPos = snipPos
	return i - 1
endf

fun snipMate#jumpTabStop()
	if exists('s:update')
		call s:UpdatePlaceholderTabStops()
	else
		call s:UpdateTabStops()
	endif

	let s:curPos += 1
	if s:curPos == s:snipLen
		let sMode = s:endSnip == g:snipPos[s:curPos-1][1]+g:snipPos[s:curPos-1][2]
		call s:RemoveSnippet()
		return sMode ? "\<tab>" : TriggerSnippet()
	endif

	call cursor(g:snipPos[s:curPos][0], g:snipPos[s:curPos][1])

	let s:endSnipLine = g:snipPos[s:curPos][0]
	let s:endSnip     = g:snipPos[s:curPos][1]
	let s:prevLen     = [line('$'), col('$')]

	return g:snipPos[s:curPos][2] == -1 ? '' : s:SelectWord()
endf

fun s:UpdatePlaceholderTabStops()
	" Update tab stops in snippet if text has been added via "$#",
	" e.g. in "${1:foo}bar$1${2}"
	if exists('s:origPos')
		let changeLen = s:origWordLen - g:snipPos[s:curPos][2]

		" This could probably be more efficent...
		if changeLen != 0
			let lnum = line('.')
			let len = len(s:origPos)

			for pos in g:snipPos[s:curPos + 1:]
				let i = 0 | let j = 0 | let k = 0
				let endSnip = pos[2] + pos[1] - 1
				" Subtract changeLen to each tab stop that was after any of
				" the current tab stop's placeholders.
				wh i < len && s:origPos[i][0] <= pos[0]
					if pos[0] == s:origPos[i][0]
						if pos[1] > s:origPos[i][1]
								\ || (pos[2] == -1 && pos[1] == s:origPos[i][1])
							let j += 1
						elseif s:origPos[i][1] < endSnip
							let k += 1
						endif
					endif
					let i += 1
				endw
				if pos[0] == lnum && pos[1] > s:origSnipPos
					let j += 1
				endif
				let pos[1] -= changeLen*j
				let pos[2] -= changeLen*k " Parse variables within placeholders

				" Do the same to any placeholders in the other tab stops.
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
	let changeLine = a:0 ? a:1 : s:endSnipLine - g:snipPos[s:curPos][0]
	let changeCol  = a:0 > 1 ? a:2 : s:endSnip - g:snipPos[s:curPos][1]
	if exists('s:origWordLen')
		let changeCol -= s:origWordLen | unl s:origWordLen
	endif
	" There's probably a more efficient way to do this as well...
	let lnum = g:snipPos[s:curPos][0]
	let col  = g:snipPos[s:curPos][1]
	" Update the line number of all proceeding tab stops if <cr> has
	" been inserted.
	if changeLine != 0
		for pos in g:snipPos[(s:curPos + 1):]
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
		" Update the column of all proceeding tab stops if text has
		" been inserted/deleted in the current line.
		for pos in g:snipPos[(s:curPos + 1):]
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
	let s:origWordLen = g:snipPos[s:curPos][2]
	let s:oldWord     = strpart(getline('.'), g:snipPos[s:curPos][1] - 1,
								\ s:origWordLen)
	let s:prevLen[1] -= s:origWordLen
	if !empty(g:snipPos[s:curPos][3])
		let s:update    = 1
		let s:endSnip   = -1
		let s:startSnip = g:snipPos[s:curPos][1] - 1
	endif
	if !s:origWordLen | return '' | endif
	let l = col('.') != 1 ? 'l' : ''
	if &sel == 'exclusive'
		return "\<esc>".l.'v'.s:origWordLen."l\<c-g>"
	endif
	return s:origWordLen == 1 ? "\<esc>".l.'gh'
							\ : "\<esc>".l.'v'.(s:origWordLen - 1)."l\<c-g>"
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
		if !exists('s:origPos') && s:curPos + 1 < s:snipLen
			" Save the old snippet & word length before it's updated
			" s:startSnip must be saved too, in case text is added
			" before the snippet (e.g. in "foo$1${2}bar${1:foo}").
			let s:origSnipPos = s:startSnip
			let s:origPos     = deepcopy(g:snipPos[s:curPos][3])
		endif
		let col = col('.') - 1

		if s:endSnip != -1
			let changeLen = col('$') - s:prevLen[1]
			let s:endSnip += changeLen
		else " When being updated the first time, after leaving select mode
			if a:entering | return | endif
			let s:endSnip = col - 1
		endif

		" If the cursor moves outside the snippet, quit it
		if line('.') != g:snipPos[s:curPos][0] || col < s:startSnip ||
					\ col - 1 > s:endSnip
			unl! s:startSnip s:origWordLen s:origPos s:update
			return s:RemoveSnippet()
		endif

		call s:UpdateSnip()
		let s:prevLen[1] = col('$')
	elseif exists('g:snipPos')
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

		" Delete snippet if cursor moves out of it in insert mode
		if (lnum == s:endSnipLine && (col > s:endSnip || col < g:snipPos[s:curPos][1]))
			\ || lnum > s:endSnipLine || lnum < g:snipPos[s:curPos][0]
			call s:RemoveSnippet()
		endif
	endif
endf

fun s:UpdateSnip(...)
	" Using strpart() here avoids a bug if s:endSnip was negative that would
	" happen with the getline('.')[(s:startSnip):(s:endSnip)] syntax
	let newWordLen = a:0 ? a:1 : s:endSnip - s:startSnip + 1
	let newWord    = strpart(getline('.'), s:startSnip, newWordLen)
	if newWord != s:oldWord
		let changeLen    = g:snipPos[s:curPos][2] - newWordLen
		let curLine      = line('.')
		let startCol     = col('.')
		let oldStartSnip = s:startSnip
		let updateSnip   = changeLen != 0
		let i            = 0

		for pos in g:snipPos[s:curPos][3]
			if updateSnip
				let start = s:startSnip
				if pos[0] == curLine && pos[1] <= start
					let s:startSnip -= changeLen
					let s:endSnip -= changeLen
				endif
				for nPos in g:snipPos[s:curPos][3][(i):]
					if nPos[0] == pos[0]
						if nPos[1] > pos[1] || (nPos == [curLine, pos[1]] &&
												\ nPos[1] > start)
							let nPos[1] -= changeLen
						endif
					elseif nPos[0] > pos[0] | break | endif
				endfor
				let i += 1
			endif

			call setline(pos[0], substitute(getline(pos[0]), '\%'.pos[1].'c\V'.
						\ escape(s:oldWord, '\'), escape(newWord, '\'), ''))
		endfor
		if oldStartSnip != s:startSnip
			call cursor('.', startCol + s:startSnip - oldStartSnip)
		endif

		let s:oldWord = newWord
		let g:snipPos[s:curPos][2] = newWordLen
	endif
endf
