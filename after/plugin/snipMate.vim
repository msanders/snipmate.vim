" These are the mappings for snipMate.vim. Putting it here ensures that it
" will be mapped after other plugins such as supertab.vim.
if exists('s:did_snips_mappings') || &cp || version < 700
	finish
endif
let s:did_snips_mappings = 1

ino <silent> <tab> <c-r>=TriggerSnippet()<cr>
snor <silent> <tab> <esc>i<right><c-r>=TriggerSnippet()<cr>
snor <bs> b<bs>
snor ' b<bs>'
snor <right> <esc>a
snor <left> <esc>bi

" By default load snippets in ~/.vim/snippets/<filetype>
if !exists('snippets_dir')
	let snippets_dir = finddir('snippets', &rtp).'/'
endif
if empty(snippets_dir) | finish | endif

if isdirectory(snippets_dir.'_')
	call ExtractSnips(snippets_dir.'_', '_')
endif
if filereadable(snippets_dir.'_.snippets')
	call ExtractSnipsFile(snippets_dir.'_.snippets')
endif

au FileType * call GetSnippets(g:snippets_dir)
fun GetSnippets(dir)
	for ft in split(&ft, '\.')
		if !exists('g:did_ft_'.ft)
			if isdirectory(a:dir.ft)
				call ExtractSnips(a:dir.ft, ft)
			endif
			if filereadable(a:dir.ft.'.snippets')
				call ExtractSnipsFile(a:dir.ft.'.snippets')
			endif
		endif
		let g:did_ft_{ft} = 1
	endfor
endf
" vim:noet:sw=4:ts=4:ft=vim
