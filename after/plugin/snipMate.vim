" These are the mappings for snipMate.vim. Putting it here ensures that it
" will be mapped after other plugins such as supertab.vim.
if !exists('loaded_snips') || exists('s:did_snips_mappings')
	finish
endif
let s:did_snips_mappings = 1
" save and reset 'cpo'
let s:save_cpo = &cpo
set cpo&vim

" This is put here in the 'after' directory in order for snipMate to override
" other plugin mappings (e.g., supertab).
"
" To adjust the tirgger key see (:h snipMate-trigger)
"
if !exists('g:snips_trigger_key')
  let g:snips_trigger_key = '<tab>'
endif

if !exists('g:snips_trigger_key_backwards')
  let g:snips_trigger_key_backwards = '<s-' . substitute(g:snips_trigger_key, '[<>]', '', 'g') . '>'
endif

exec 'ino <silent> ' . g:snips_trigger_key . ' <c-r>=snipMate#TriggerSnippet()<cr>'
exec 'snor <silent> ' . g:snips_trigger_key . ' <esc>i<right><c-r>=snipMate#TriggerSnippet()<cr>'
exec 'ino <silent> ' . g:snips_trigger_key_backwards . ' <c-r>=snipMate#BackwardsSnippet()<cr>'
exec 'snor <silent> ' . g:snips_trigger_key_backwards . ' <esc>i<right><c-r>=snipMate#BackwardsSnippet()<cr>'
exec 'ino <silent> <c-r>' . g:snips_trigger_key . ' <c-r>=snipMate#ShowAvailableSnips()<cr>'

" maybe there is a better way without polluting registers ?
exec 'xnoremap ' . g:snips_trigger_key. ' s<c-o>:let<space>g:snipmate_content_visual=getreg('1')<cr>'

" FIXME: Without this map, <BS> in select mode deletes the current selection and
" returns to normal mode. This doesn't update placeholders. Ideally there's some
" way to update the placeholders without this otherwise useless map.
snor <bs> b<bs><Esc>

" By default load snippets in snippets_dir
if empty(snippets_dir)
	finish
endif

" restore 'cpo'
let &cpo = s:save_cpo

" vim:noet:sw=4:ts=4:ft=vim
