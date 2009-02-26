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
" NOTE: I need to make sure this works on Windows
if isdirectory($HOME.'/.vim/snippets')
	if isdirectory($HOME.'/.vim/snippets/_')
		call ExtractSnips($HOME.'/.vim/snippets/_', '_')
	endif
	au FileType * if !exists('s:did_'.&ft) && 
					\ isdirectory($HOME.'/.vim/snippets/'.&ft)
				\| cal ExtractSnips($HOME.'/.vim/snippets/'.&ft, &ft) | en
endif
