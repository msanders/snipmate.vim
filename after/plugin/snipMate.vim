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

au FileType objc,cpp,cs let &ft = expand('<amatch>').'.c'

" By default load snippets in ~/.vim/snippets/<filetype>
if !exists('snippets_dir')
	let snippets_dir = $HOME.(has('win16') || has('win32') || has('win64') ?
							\ '\vimfiles\snippets\' : '/.vim/snippets/')
endif
if !isdirectory(snippets_dir) | finish | endif

if isdirectory(snippets_dir.'_')
	call ExtractSnips(snippets_dir.'_', '_')
endif
au FileType * call s:GetSnippets()
fun s:GetSnippets()
	for ft in split(&ft, '\.')
		if !exists('g:did_ft_'.ft) && isdirectory(g:snippets_dir.ft)
			call ExtractSnips(g:snippets_dir.ft, ft)
		endif
	endfor
endf
" vim:noet:sw=4:ts=4:ft=vim
