let snippet_filetype = stridx(&ft, 'xhtml') > -1 ? 'xhtml' : 'html'
if !exists('g:loaded_snips') || exists('s:did_'.snippet_filetype.'_snips')
	fini
en
let s:did_{snippet_filetype}_snips = 1

" automatically add a closing '/' to the end of xhtml tags
let c = snippet_filetype == 'xhtml' ? ' /' : ''

" Some useful Unicode entities
" Non-Breaking Space
exe 'Snipp nbs &nbsp;'
" ←
exe 'Snipp left &#x2190;'
" →
exe 'Snipp right &#x2192;'
" ↑
exe 'Snipp up &#x2191;'
" ↓
exe 'Snipp down &#x2193;'
" ↩
exe 'Snipp return &#x21A9;'
" ⇤
exe 'Snipp backtab &#x21E4;'
" ⇥
exe 'Snipp tab &#x21E5;'
" ⇧
exe 'Snipp shift &#x21E7;'
" ⌃
exe 'Snipp control &#x2303;'
" ⌅
exe 'Snipp enter &#x2305;'
" ⌘
exe 'Snipp command &#x2318;'
" ⌥
exe 'Snipp option &#x2325;'
" ⌦
exe 'Snipp delete &#x2326;'
" ⌫
exe 'Snipp backspace &#x232B;'
" ⎋
exe 'Snipp escape &#x238B;'
" Generic Doctype
exe "Snipp! doctype \"HTML 4.01 Strict\" <!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01//EN\"\"\n\"http://www.w3.org/TR/html4/strict.dtd\">"
exe "Snipp! doctype \"HTML 4.01 Transitional\" <!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\"\"\n\"http://www.w3.org/TR/html4/loose.dtd\">"
exe "Snipp! doctype \"HTML 5\" <!DOCTYPE HTML>"
exe "Snipp! doctype \"XHTML 1.0 Frameset\" <!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\"\n\"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">"
exe "Snipp! doctype \"XHTML 1.0 Strict\" <!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\"\n\"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">"
exe "Snipp! doctype \"XHTML 1.0 Transitional\" <!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\"\n\"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">"
exe "Snipp! doctype \"XHTML 1.1\" <!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.1//EN\"\n\"http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd\">"
" HTML Doctype 4.01 Strict
exe "Snipp docts <!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01//EN\"\"\n\"http://www.w3.org/TR/html4/strict.dtd\">"
" HTML Doctype 4.01 Transitional
exe "Snipp doct <!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\"\"\n\"http://www.w3.org/TR/html4/loose.dtd\">"
" HTML Doctype 5
exe 'Snipp doct5 <!DOCTYPE HTML>'
" XHTML Doctype 1.0 Frameset
exe "Snipp docxf <!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Frameset//EN\"\n\"http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd\">"
" XHTML Doctype 1.0 Strict
exe "Snipp docxs <!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\"\n\"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">"
" XHTML Doctype 1.0 Transitional
exe "Snipp docxt <!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\"\n\"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">"
" XHTML Doctype 1.1
exe "Snipp docx <!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.1//EN\"\n\"http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd\">"
exe "Snipp html <html>\n${1}\n</html>"
exe "Snipp xhtml <html xmlns=\"http://www.w3.org/1999/xhtml\">\n${1}\n</html>"
exe "Snipp body <body>\n\t${1}\n</body>"
exe "Snipp head <head>\n\t<meta http-equiv=\"content-type\" content=\"text/html; charset=utf-8\"".c.">\n\t"
\. "<title>${1:`substitute(Filename('', 'Page Title'), '^.', '\\u&', '')`}</title>\n\t${2}\n</head>"
exe 'Snipp title <title>${1:`substitute(Filename("", "Page Title"), "^.", "\\u&", "")`}</title>${2}'
exe "Snipp script <script type=\"text/javascript\" charset=\"utf-8\">\n\t${1}\n</script>${2}"
exe "Snipp scriptsrc <script src=\"${1}.js\" type=\"text/javascript\" charset=\"utf-8\"></script>${2}"
exe "Snipp style <style type=\"text/css\" media=\"${1:screen}\">\n\t${2}\n</style>${3}"
exe 'Snipp base <base href="${1}" target="${2}"'.c.'>'
exe 'Snipp r <br'.c[1:].'>'
exe "Snipp div <div id=\"${1:name}\">\n\t${2}\n</div>"
" Embed QT Movie
exe "Snipp movie <object width=\"$2\" height=\"$3\" classid=\"clsid:02BF25D5-8C17-4B23-BC80-D3488ABDDC6B\""
\ ." codebase=\"http://www.apple.com/qtactivex/qtplugin.cab\">\n\t<param name=\"src\" value=\"$1\"".c.">\n\t<param name=\"controller\" value=\"$4\"".c
\ .">\n\t<param name=\"autoplay\" value=\"$5\"".c.">\n\t<embed src=\"${1:movie.mov}\"\n\t\twidth=\"${2:320}\" height=\"${3:240}\"\n\t\t"
\ ."controller=\"${4:true}\" autoplay=\"${5:true}\"\n\t\tscale=\"tofit\" cache=\"true\"\n\t\tpluginspage=\"http://www.apple.com/quicktime/download/\"\n\t".c[1:].">\n</object>${6}"
exe "Snipp fieldset <fieldset id=\"$1\">\n\t<legend>${1:name}</legend>\n\n\t${3}\n</fieldset>"
exe "Snipp form <form action=\"${1:`Filename('$1_submit')`}\" method=\"${2:get}\" accept-charset=\"utf-8\">\n\t${3}\n\n\t"
\."<p><input type=\"submit\" value=\"Continue &rarr;\"".c."></p>\n</form>"
exe 'Snipp h1 <h1 id="${1:heading}">${2:$1}</h1>'
exe 'Snipp input <input type="${1:text/submit/hidden/button}" name="${2:some_name}" value="${3}"'.c.'>${4}'
exe 'Snipp label <label for="${2:$1}">${1:name}</label><input type="${3:text/submit/hidden/button}" name="${4:$2}" value="${5}" id="${6:$2}"'.c.'>${7}'
exe 'Snipp link <link rel="${1:stylesheet}" href="${2:/css/master.css}" type="text/css" media="${3:screen}" charset="utf-8"'.c.'>${4}'
exe 'Snipp mailto <a href="mailto:${1:joe@example.com}?subject=${2:feedback}">${3:email me}</a>'
exe 'Snipp meta <meta name="${1:name}" content="${2:content}"'.c.'>${3}'
exe 'Snipp opt <option value="${1:option}">${2:$1}</option>${3}'
exe 'Snipp optt <option>${1:option}</option>${2}'
exe "Snipp select <select name=\"${1:some_name}\" id=\"${2:$1}\">\n\t<option value=\"${3:option}\">${4:$3}</option>\n</select>${5}"
exe "Snipp table <table border=\"${1:0}\">\n\t<tr><th>${2:Header}</th></tr>\n\t<tr><th>${3:Data}</th></tr>\n</table>${4}"
exe 'Snipp textarea <textarea name="${1:Name}" rows="${2:8}" cols="${3:40}">${4}</textarea>${5}'
