" config which can be overridden (shared lines)
if !exists('g:snipMate')
  let g:snipMate = {}
endif
let s:snipMate = g:snipMate

" if filetype is objc, cpp, or cs also append snippets from scope 'c'
" you can add multiple by separating scopes by ',', see s:AddScopeAliases
" TODO add documentation to doc/*
let s:snipMate['scope_aliases'] = get(s:snipMate,'scope_aliases',
	  \ {'objc' :'c'
	  \ ,'cpp': 'c'
	  \ ,'cs':'c'
	  \ ,'xhtml': 'html'
	  \ ,'html': 'javascript'
	  \ ,'php': 'html,javascript'
	  \ ,'ur': 'html,javascript'
	  \ ,'mxml': 'actionscript'
	  \ } )

fun! Filename(...)
	let filename = expand('%:t:r')
	if filename == '' | return a:0 == 2 ? a:2 : '' | endif
	return !a:0 || a:1 == '' ? filename : substitute(a:1, '$1', filename, 'g')
endf

fun s:RemoveSnippet()
	unl! g:snipPos s:curPos s:snipLen s:endCol s:endLine s:prevLen
	     \ s:lastBuf s:oldWord
	if exists('s:update')
		unl s:startCol s:origWordLen s:update
		if exists('s:oldVars') | unl s:oldVars s:oldEndCol | endif
	endif
	aug! snipMateAutocmds
endf

fun! snipMate#expandSnip(snip, col)
	let lnum = line('.') | let col = a:col

	let snippet = s:ProcessSnippet(a:snip)
	" Avoid error if eval evaluates to nothing
	if snippet == '' | return '' | endif

	" Expand snippet onto current position with the tab stops removed
	let snipLines = split(substitute(snippet, '$\d\+\|${\d\+.\{-}}', '', 'g'), "\n", 1)

	let line = getline(lnum)
	let afterCursor = strpart(line, col - 1)
	" Keep text after the cursor
	if afterCursor != "\t" && afterCursor != ' '
		let line = strpart(line, 0, col - 1)
		let snipLines[-1] .= afterCursor
	else
		let afterCursor = ''
		" For some reason the cursor needs to move one right after this
		if line != '' && col == 1 && &ve != 'all' && &ve != 'onemore'
			let col += 1
		endif
	endif

	call setline(lnum, line.snipLines[0])

	" Autoindent snippet according to previous indentation
	let indent = matchend(line, '^.\{-}\ze\(\S\|$\)') + 1
	call append(lnum, map(snipLines[1:], "'".strpart(line, 0, indent - 1)."'.v:val"))

	" Open any folds snippet expands into
	if &fen | sil! exe lnum.','.(lnum + len(snipLines) - 1).'foldopen' | endif

	let [g:snipPos, s:snipLen] = s:BuildTabStops(snippet, lnum, col - indent, indent)

	if s:snipLen
		aug snipMateAutocmds
			au CursorMovedI * call s:UpdateChangedSnip(0)
			au InsertEnter * call s:UpdateChangedSnip(1)
		aug END
		let s:lastBuf = bufnr(0) " Only expand snippet while in current buffer
		let s:curPos = 0
		let s:endCol = g:snipPos[s:curPos][1]
		let s:endLine = g:snipPos[s:curPos][0]

		call cursor(g:snipPos[s:curPos][0], g:snipPos[s:curPos][1])
		let s:prevLen = [line('$'), col('$')]
		if g:snipPos[s:curPos][2] != -1 | return s:SelectWord() | endif
	else
		unl g:snipPos s:snipLen
		" Place cursor at end of snippet if no tab stop is given
		let newlines = len(snipLines) - 1
		call cursor(lnum + newlines, indent + len(snipLines[-1]) - len(afterCursor)
					\ + (newlines ? 0: col - 1))
	endif
	return ''
endf

" Prepare snippet to be processed by s:BuildTabStops
fun! s:ProcessSnippet(snip)
	let snippet = a:snip

	if exists('g:snipmate_content_visual')
		let visual = g:snipmate_content_visual | unlet g:snipmate_content_visual
	else
		let visual = ''
	endif
	let snippet = substitute(snippet,'{VISUAL}', escape(visual,'%\'), 'g')

	" Evaluate eval (`...`) expressions.
	" Backquotes prefixed with a backslash "\" are ignored.
	" And backslash can be escaped by doubling it.
	" Using a loop here instead of a regex fixes a bug with nested "\=".
	if stridx(snippet, '`') != -1
		let new = []
		let snip = split(snippet, '\%(\\\@<!\%(\\\\\)*\)\@<=`', 1)
		let isexp = 0
		for i in snip
			if isexp
				call add(new, substitute(eval(i), "\n\\%$", '', ''))
			else
				call add(new, i)
			endif
			let isexp = !isexp
		endfor
		let snippet = join(new, '')
		let snippet = substitute(snippet, "\r", "\n", 'g')
		let snippet = substitute(snippet, '\\`', "`", 'g')
		let snippet = substitute(snippet, '\\\\', "\\", 'g')
	endif

	" Place all text after a colon in a tab stop after the tab stop
	" (e.g. "${#:foo}" becomes "${:foo}foo").
	" This helps tell the position of the tab stops later.
	let snippet = substitute(snippet, '${\d\+:\(.\{-}\)}', '&\1', 'g')

	" Update the a:snip so that all the $# become the text after
	" the colon in their associated ${#}.
	" (e.g. "${1:foo}" turns all "$1"'s into "foo")
	let i = 1
	while stridx(snippet, '${'.i) != -1
		let s = matchstr(snippet, '${'.i.':\zs.\{-}\ze}')
		if s != ''
			let snippet = substitute(snippet, '$'.i, s.'&', 'g')
		endif
		let i += 1
	endw

	if &et " Expand tabs to spaces if 'expandtab' is set.
		return substitute(snippet, '\t', repeat(' ', &sts ? &sts : &sw), 'g')
	endif
	return snippet
endf

" Counts occurences of haystack in needle
fun! s:Count(haystack, needle)
	let counter = 0
	let index = stridx(a:haystack, a:needle)
	while index != -1
		let index = stridx(a:haystack, a:needle, index+1)
		let counter += 1
	endw
	return counter
endf

" Builds a list of a list of each tab stop in the snippet containing:
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
fun! s:BuildTabStops(snip, lnum, col, indent)
	let snipPos = []
	let i = 1
	let withoutVars = substitute(a:snip, '$\d\+', '', 'g')
	while stridx(a:snip, '${'.i) != -1
		let beforeTabStop = matchstr(withoutVars, '^.*\ze${'.i.'\D')
		let withoutOthers = substitute(withoutVars, '${\('.i.'\D\)\@!\d\+.\{-}}', '', 'g')

		let j = i - 1
		call add(snipPos, [0, 0, -1])
		let snipPos[j][0] = a:lnum + s:Count(beforeTabStop, "\n")
		let snipPos[j][1] = a:indent + len(matchstr(withoutOthers, '.*\(\n\|^\)\zs.*\ze${'.i.'\D'))
		if snipPos[j][0] == a:lnum | let snipPos[j][1] += a:col | endif

		" Get all $# matches in another list, if ${#:name} is given
		if stridx(withoutVars, '${'.i.':') != -1
			let snipPos[j][2] = len(matchstr(withoutVars, '${'.i.':\zs.\{-}\ze}'))
			let dots = repeat('.', snipPos[j][2])
			call add(snipPos[j], [])
			let withoutOthers = substitute(a:snip, '${\d\+.\{-}}\|$'.i.'\@!\d\+', '', 'g')
			while match(withoutOthers, '$'.i.'\(\D\|$\)') != -1
				let beforeMark = matchstr(withoutOthers, '^.\{-}\ze'.dots.'$'.i.'\(\D\|$\)')
				call add(snipPos[j][3], [0, 0])
				let snipPos[j][3][-1][0] = a:lnum + s:Count(beforeMark, "\n")
				let snipPos[j][3][-1][1] = a:indent + (snipPos[j][3][-1][0] > a:lnum
				                           \ ? len(matchstr(beforeMark, '.*\n\zs.*'))
				                           \ : a:col + len(beforeMark))
				let withoutOthers = substitute(withoutOthers, '$'.i.'\ze\(\D\|$\)', '', '')
			endw
		endif
		let i += 1
	endw
	return [snipPos, i - 1]
endf

fun! snipMate#jumpTabStop(backwards)
	let leftPlaceholder = exists('s:origWordLen')
	                      \ && s:origWordLen != g:snipPos[s:curPos][2]
	if leftPlaceholder && exists('s:oldEndCol')
		let startPlaceholder = s:oldEndCol + 1
	endif

	if exists('s:update')
		call s:UpdatePlaceholderTabStops()
	else
		call s:UpdateTabStops()
	endif

	" Don't reselect placeholder if it has been modified
	if leftPlaceholder && g:snipPos[s:curPos][2] != -1
		if exists('startPlaceholder')
			let g:snipPos[s:curPos][1] = startPlaceholder
		else
			let g:snipPos[s:curPos][1] = col('.')
			let g:snipPos[s:curPos][2] = 0
		endif
	endif

	let s:curPos += a:backwards ? -1 : 1
	" Loop over the snippet when going backwards from the beginning
	if s:curPos < 0 | let s:curPos = s:snipLen - 1 | endif

	if s:curPos == s:snipLen
		let sMode = s:endCol == g:snipPos[s:curPos-1][1]+g:snipPos[s:curPos-1][2]
		call s:RemoveSnippet()
		return sMode ? "\<tab>" : TriggerSnippet()
	endif

	call cursor(g:snipPos[s:curPos][0], g:snipPos[s:curPos][1])

	let s:endLine = g:snipPos[s:curPos][0]
	let s:endCol = g:snipPos[s:curPos][1]
	let s:prevLen = [line('$'), col('$')]

	return g:snipPos[s:curPos][2] == -1 ? '' : s:SelectWord()
endf

fun! s:UpdatePlaceholderTabStops()
	let changeLen = s:origWordLen - g:snipPos[s:curPos][2]
	unl s:startCol s:origWordLen s:update
	if !exists('s:oldVars') | return | endif
	" Update tab stops in snippet if text has been added via "$#"
	" (e.g., in "${1:foo}bar$1${2}").
	if changeLen != 0
		let curLine = line('.')

		for pos in g:snipPos
			if pos == g:snipPos[s:curPos] | continue | endif
			let changed = pos[0] == curLine && pos[1] > s:oldEndCol
			let changedVars = 0
			let endPlaceholder = pos[2] - 1 + pos[1]
			" Subtract changeLen from each tab stop that was after any of
			" the current tab stop's placeholders.
			for [lnum, col] in s:oldVars
				if lnum > pos[0] | break | endif
				if pos[0] == lnum
					if pos[1] > col || (pos[2] == -1 && pos[1] == col)
						let changed += 1
					elseif col < endPlaceholder
						let changedVars += 1
					endif
				endif
			endfor
			let pos[1] -= changeLen * changed
			let pos[2] -= changeLen * changedVars " Parse variables within placeholders
                                                  " e.g., "${1:foo} ${2:$1bar}"

			if pos[2] == -1 | continue | endif
			" Do the same to any placeholders in the other tab stops.
			for nPos in pos[3]
				let changed = nPos[0] == curLine && nPos[1] > s:oldEndCol
				for [lnum, col] in s:oldVars
					if lnum > nPos[0] | break | endif
					if nPos[0] == lnum && nPos[1] > col
						let changed += 1
					endif
				endfor
				let nPos[1] -= changeLen * changed
			endfor
		endfor
	endif
	unl s:endCol s:oldVars s:oldEndCol
endf

fun! s:UpdateTabStops()
	let changeLine = s:endLine - g:snipPos[s:curPos][0]
	let changeCol = s:endCol - g:snipPos[s:curPos][1]
	if exists('s:origWordLen')
		let changeCol -= s:origWordLen
		unl s:origWordLen
	endif
	let lnum = g:snipPos[s:curPos][0]
	let col = g:snipPos[s:curPos][1]
	" Update the line number of all proceeding tab stops if <cr> has
	" been inserted.
	if changeLine != 0
		let changeLine -= 1
		for pos in g:snipPos
			if pos[0] >= lnum
				if pos[0] == lnum | let pos[1] += changeCol | endif
				let pos[0] += changeLine
			endif
			if pos[2] == -1 | continue | endif
			for nPos in pos[3]
				if nPos[0] >= lnum
					if nPos[0] == lnum | let nPos[1] += changeCol | endif
					let nPos[0] += changeLine
				endif
			endfor
		endfor
	elseif changeCol != 0
		" Update the column of all proceeding tab stops if text has
		" been inserted/deleted in the current line.
		for pos in g:snipPos
			if pos[1] >= col && pos[0] == lnum
				let pos[1] += changeCol
			endif
			if pos[2] == -1 | continue | endif
			for nPos in pos[3]
				if nPos[0] > lnum | break | endif
				if nPos[0] == lnum && nPos[1] >= col
					let nPos[1] += changeCol
				endif
			endfor
		endfor
	endif
endf

fun! s:SelectWord()
	let s:origWordLen = g:snipPos[s:curPos][2]
	let s:oldWord = strpart(getline('.'), g:snipPos[s:curPos][1] - 1,
				\ s:origWordLen)
	let s:prevLen[1] -= s:origWordLen
	if !empty(g:snipPos[s:curPos][3])
		let s:update = 1
		let s:endCol = -1
		let s:startCol = g:snipPos[s:curPos][1] - 1
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
fun! s:UpdateChangedSnip(entering)
	if exists('g:snipPos') && bufnr(0) != s:lastBuf
		call s:RemoveSnippet()
	elseif exists('s:update') " If modifying a placeholder
		if !exists('s:oldVars') && s:curPos + 1 < s:snipLen
			" Save the old snippet & word length before it's updated
			" s:startCol must be saved too, in case text is added
			" before the snippet (e.g. in "foo$1${2}bar${1:foo}").
			let s:oldEndCol = s:startCol
			let s:oldVars = deepcopy(g:snipPos[s:curPos][3])
		endif
		let col = col('.') - 1

		if s:endCol != -1
			let changeLen = col('$') - s:prevLen[1]
			let s:endCol += changeLen
		else " When being updated the first time, after leaving select mode
			if a:entering | return | endif
			let s:endCol = col - 1
		endif

		" If the cursor moves outside the snippet, quit it
		if line('.') != g:snipPos[s:curPos][0] || col < s:startCol ||
					\ col - 1 > s:endCol
			unl! s:startCol s:origWordLen s:oldVars s:update
			return s:RemoveSnippet()
		endif

		call s:UpdateVars()
		let s:prevLen[1] = col('$')
	elseif exists('g:snipPos')
		if !a:entering && g:snipPos[s:curPos][2] != -1
			let g:snipPos[s:curPos][2] = -2
		endif

		let col = col('.')
		let lnum = line('.')
		let changeLine = line('$') - s:prevLen[0]

		if lnum == s:endLine
			let s:endCol += col('$') - s:prevLen[1]
			let s:prevLen = [line('$'), col('$')]
		endif
		if changeLine != 0
			let s:endLine += changeLine
			let s:endCol = col
		endif

		" Delete snippet if cursor moves out of it in insert mode
		if (lnum == s:endLine && (col > s:endCol || col < g:snipPos[s:curPos][1]))
			\ || lnum > s:endLine || lnum < g:snipPos[s:curPos][0]
			call s:RemoveSnippet()
		endif
	endif
endf

" This updates the variables in a snippet when a placeholder has been edited.
" (e.g., each "$1" in "${1:foo} $1bar $1bar")
fun! s:UpdateVars()
	let newWordLen = s:endCol - s:startCol + 1
	let newWord = strpart(getline('.'), s:startCol, newWordLen)
	if newWord == s:oldWord || empty(g:snipPos[s:curPos][3])
		return
	endif

	let changeLen = g:snipPos[s:curPos][2] - newWordLen
	let curLine = line('.')
	let startCol = col('.')
	let oldStartSnip = s:startCol
	let updateTabStops = changeLen != 0
	let i = 0

	for [lnum, col] in g:snipPos[s:curPos][3]
		if updateTabStops
			let start = s:startCol
			if lnum == curLine && col <= start
				let s:startCol -= changeLen
				let s:endCol -= changeLen
			endif
			for nPos in g:snipPos[s:curPos][3][(i):]
				" This list is in ascending order, so quit if we've gone too far.
				if nPos[0] > lnum | break | endif
				if nPos[0] == lnum && nPos[1] > col
					let nPos[1] -= changeLen
				endif
			endfor
			if lnum == curLine && col > start
				let col -= changeLen
				let g:snipPos[s:curPos][3][i][1] = col
			endif
			let i += 1
		endif

		" "Very nomagic" is used here to allow special characters.
		call setline(lnum, substitute(getline(lnum), '\%'.col.'c\V'.
						\ escape(s:oldWord, '\'), escape(newWord, '\&'), ''))
	endfor
	if oldStartSnip != s:startCol
		call cursor(0, startCol + s:startCol - oldStartSnip)
	endif

	let s:oldWord = newWord
	let g:snipPos[s:curPos][2] = newWordLen
endf

" should be moved to utils or such?
fun! snipMate#SetByPath(dict, path, value)
	let d = a:dict
	for p in a:path[:-2]
		if !has_key(d,p) | let d[p] = {} | endif
		let d = d[p]
	endfor
	let d[a:path[-1]] = a:value
endf

" reads a .snippets file
" returns list of
" ['triggername', 'name', 'contents']
" if triggername is not set 'default' is assumed
fun! snipMate#ReadSnippetsFile(file)
	let result = []
	if !filereadable(a:file) | return result | endif
	let inSnip = 0
	for line in readfile(a:file) + ["\n"]
		if inSnip && (line[0] == "\t" || line == '')
			let content .= strpart(line, 1)."\n"
			continue
		elseif inSnip
			call add(result, [trigger, name == '' ? 'default' : name, content[:-2]])
			let inSnip = 0
		endif

		if line[:6] == 'snippet'
			let inSnip = 1
			let trigger = strpart(line, 8)
			let name = ''
			let space = stridx(trigger, ' ') + 1
			if space " Process multi snip
				let name = strpart(trigger, space)
				let trigger = strpart(trigger, 0, space - 1)
			endif
			let content = ''
		endif
	endfor
	return result
endf


let s:read_snippets_cached  = {'func' : function('snipMate#ReadSnippetsFile'), 'version': 3, 'use_file_cache':1}

" adds scope aliases to list.
" returns new list
" the aliases of aliases are added recursively
fun! s:AddScopeAliases(list)
  let did = {}
  let scope_aliases = get(s:snipMate,'scope_aliases', {})
  let new = a:list
  let new2 =  []
  while !empty(new)
	for i in new
	  if i == ""
		echoe "empty filetype?"
		continue
	  endif
	  if !has_key(did, i)
		let did[i] = 1
		call extend(new2, split(get(scope_aliases,i,''),','))
	  endif
	endfor
	let new = new2
	let new2 = []
  endwhile
  return keys(did)
endf

" returns dict of
" { path: { 'type': one of 'snippet' 'snippets',
"           'exists': 1 or 0
"           " for single snippet files:
"           'name': name of snippet
"           'trigger': trigger of snippet
"         }
" }
" use trigger = '*' to match all snippet files
" use mustExist = 1 to return existing files only
"
"     mustExist = 0 is used by OpenSnippetFiles
fun! snipMate#GetSnippetFiles(mustExist, scopes, trigger)
  let result = {}
  let triggerR = substitute(a:trigger,'*','.*','g')
  let scopes = s:AddScopeAliases(a:scopes)

  " collect existing files
  for scope in scopes

	for r in split(&runtimepath,',')
	  " .snippets files (many snippets per file). cache result for
	  " performance reason
	  " assume everything is a file..
	  let glob_p = r.'/snippets/'.scope.'.snippets'
	  for snippetsF in split(glob(glob_p),"\n")
		let result[snippetsF] = {'exists': 1, 'type': 'snippets'}
	  endfor

	  if !a:mustExist && !has_key(result, glob_p)
		let result[glob_p] = {'exists': 0, 'type': 'snippets'}
	  endif
	  " == one file per snippet: ==

	  " without name snippets/<filetype>/<trigger>.snippet
	  for f in split(glob(r.'/snippets/'.scope.'/'.a:trigger.'.snippet'),"\n")
		let trigger = fnamemodify(f,':t:r')
		let result[f] = {'exists': 1, 'type': 'snippet', 'name': 'default', 'trigger': trigger}
	  endfor
	  " add /snippets/trigger/*.snippet files (TODO)

	  " with name (multi-snip) snippets/<filetype>/<trigger>/<name>.snippet
	  for f in split(glob(r.'/snippets/'.scope.'/'.a:trigger.'/*.snippet'),"\n")
		let name = fnamemodify(f,':t:r')
		let trigger = fnamemodify(f,':h:t')
		let result[f] = {'exists': 1, 'type': 'snippet', 'name': name, 'trigger': trigger}
	  endfor
	endfor
  endfor
  return result
endf


" return a dict of snippets found in runtimepath matching trigger
" scopes: list of scopes. usually this is the filetype. eg ['c','cpp']
" trigger may contain glob patterns. Thus use '*' to get all triggers
"
" TODO refactor - this should call GetSnippetFiles
fun! snipMate#GetSnippets(scopes, trigger)
	let result = {}
	let triggerR = substitute(a:trigger,'*','.*','g')
	let scopes = s:AddScopeAliases(a:scopes)
	for scope in scopes

		for r in split(&runtimepath,',')

			" .snippets files (many snippets per file). cache result for
			" performance reason
			" assume everything is a file..
			for snippetsF in split(glob(r.'/snippets/'.scope.'.snippets'),"\n")
				for [trigger, name, contents] in cached_file_contents#CachedFileContents(snippetsF, s:read_snippets_cached, 0)
					if trigger !~ triggerR | continue | endif
					call snipMate#SetByPath(result, [trigger, name], contents)
				endfor
			endfor

			for snippetsF in split(glob(r.'/snippets/'.scope.'/*.snippets'),"\n")
				for [trigger, name, contents] in cached_file_contents#CachedFileContents(snippetsF, s:read_snippets_cached, 0)
					if trigger !~ triggerR | continue | endif
					call snipMate#SetByPath(result, [trigger, name], contents)
				endfor
			endfor

			" == one file per snippet: ==

			" without name snippets/<filetype>/<trigger>.snippet
			for f in split(glob(r.'/snippets/'.scope.'/'.a:trigger.'.snippet'),"\n")
				let trigger = fnamemodify(f,':t:r')
				" lazily read files as needed
				call snipMate#SetByPath(result, [trigger, 'default'], funcref#Function('return readfile('.string(f).')'))
			endfor
			" add /snippets/trigger/*.snippet files (TODO)

			" with name (multi-snip) snippets/<filetype>/<trigger>/<name>.snippet
			for f in split(glob(r.'/snippets/'.scope.'/'.a:trigger.'/*.snippet'),"\n")
				let name = fnamemodify(f,':t:r')
				let trigger = fnamemodify(f,':h:t')
				" lazily read files as needed
				call snipMate#SetByPath(result, [trigger, name], funcref#Function('return readfile('.string(f).')'))
			endfor
		endfor
	endfor

	for F in values(g:snipMateSources)
	  call funcref#Call(F, [scopes, a:trigger, result])
	endfor
	return result
endf

" adds leading tab
" and replaces leading spaces by tabs
" see ftplugin/snippet.vim
fun! snipMate#RetabSnip() range
  let leadingTab = expand('%:e') == 'snippets'

  let lines = getline(a:firstline, a:lastline)

  " remove leading "\t"
  let allIndented = 1
  for l in lines
	if l[0] != '\t' | let allIndented = 0 | endif
  endfor

  " retab
  if allIndented
	call map(lines, 'v:val[1:]')
  endif

  let leadingSp = filter(map(copy(lines),'matchstr(v:val,"^\\s*") '),'v:val !=""')
  if !empty(leadingSp)
	" lines containing leading spaces found
	let smallestInd =  len(sort(leadingSp)[-1])
	let ind = input('retab, spaces per tab: ', smallestInd)
	for i in range(0, len(lines)-1)
	  let ml = matchlist(lines[i], '^\(\s*\)\(.*\)')
	  let lines[i] = repeat("\t", len(ml[1]) / ind)
				 \ . repeat( " ", len(ml[1]) % ind)
				 \ . ml[2]
	endfor
  endif
  " readd tab
  let tab = leadingTab ? "\t" : ""
  for i in range(0,len(lines)-1)
	call setline(a:firstline + i, tab.lines[i])
  endfor
endf

fun! snipMate#OpenSnippetFiles()
  let scopes = s:AddScopeAliases([&ft])
  let dict = snipMate#GetSnippetFiles(0, scopes, '*')
  " sort by files wether they exist - put existing files first
  let exists = []
  let notExists = []
  for [file, v] in items(dict)
	let v['file'] = file
	if v['exists']
	  call add(exists, v)
	else
	  call add(notExists, v)
	endif
  endfor
  let all = exists + notExists
  let show = map(copy(all),'(v:val["exists"] ? "exists:" : "does not exist yet:")." ".v:val["file"]')
  let select = tlib#input#List('mi', 'select files to be opened in splits', show)
  for idx in select
	exec 'sp '.all[idx - 1]['file']
  endfor
endf


" vim:noet:sw=4:ts=4:ft=vim
