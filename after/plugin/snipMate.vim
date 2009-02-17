" These are the mappings for snipMate.vim. Putting it here ensures that it 
" will be mapped after other plugins such as supertab.vim.
if exists('s:did_snips_mappings') || &cp || version < 700
	fini
en
let s:did_snips_mappings = 1

ino <tab> <c-r>=ExpandSnippet()<cr>
snor <tab> <esc>i<right><c-r>=ExpandSnippet()<cr>
snor <bs> b<bs>
snor ' b<bs>'
snor <right> <esc>a
snor <left> <esc>bi
