" These are the mappings for snipMate.vim. Putting it here ensures that it
" will be mapped after other plugins such as supertab.vim.
if !exists('loaded_snips') || exists('s:did_snips_mappings')
	finish
endif
let s:did_snips_mappings = 1

" This is put here in the 'after' directory in order for snipMate to override
" other plugin mappings (e.g., supertab).
"
" You can safely adjust these mappings to your preferences (as explained in
" :help snipMate-remap).
if !exists("g:snipMateTriggerSnippetKey")
    let g:snipMateTriggerSnippetKey = "<tab>"
endif

if !exists("g:snipMateBackwardSnippetKey")
    let g:snipMateBackwardSnippetKey = "<s-tab>"
endif

if !exists("g:snipMateShowAvailableSnipsKey")
    let g:snipMateShowAvailableSnipsKey = "<c-r><tab>"
endif


exe "ino <silent> ".g:snipMateTriggerSnippetKey." <c-r>=TriggerSnippet()<cr>"
exe "snor <silent> ".g:snipMateTriggerSnippetKey." <esc>i<right><c-r>=TriggerSnippet()<cr>"
exe "ino <silent> ".g:snipMateBackwardSnippetKey." <c-r>=BackwardsSnippet()<cr>"
exe "snor <silent> ".g:snipMateBackwardSnippetKey." <esc>i<right><c-r>=BackwardsSnippet()<cr>"
exe "ino <silent> ".g:snipMateShowAvailableSnipsKey." <c-r>=ShowAvailableSnips()<cr>"

" The default mappings for these are annoying & sometimes break snipMate.
" You can change them back if you want, I've put them here for convenience.
snor <bs> b<bs>
snor <right> <esc>a
snor <left> <esc>bi
snor ' b<bs>'
snor ` b<bs>`
snor % b<bs>%
snor U b<bs>U
snor ^ b<bs>^
snor \ b<bs>\
snor <c-x> b<bs><c-x>

" By default load snippets in snippets_dir
if empty(snippets_dir)
	finish
endif

call GetSnippets(snippets_dir, '_') " Get global snippets

au FileType * if &ft != 'help' | call GetSnippets(snippets_dir, &ft) | endif
" vim:noet:sw=4:ts=4:ft=vim
