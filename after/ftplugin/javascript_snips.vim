if !exists('loaded_snips') || exists('s:did_js_snips')
	fini
en
let s:did_js_snips = 1
let snippet_filetype = 'javascript'

" Prototype
exe "Snipp proto ${1:class_name}.prototype.${2:method_name} =\nfunction(${3:first_argument}) {\n\t${4:// body...}\n};"
" Function
exe "Snipp fun function ${1:function_name} (${2:argument}) {\n\t${3:// body...}\n}"
" Anonymous Function
exe 'Snipp f function(${1}) {${2}};'
" if
exe 'Snipp if if (${1:true}) {${2}};'
" if ... else
exe "Snipp ife if (${1:true}) {${2}}\nelse{${3}};"
" tertiary conditional
exe 'Snipp t ${1:/* condition */} ? ${2:a} : ${3:b}'
" switch
exe "Snipp switch switch(${1:expression}) {\n\tcase '${3:case}':\n\t\t${4:// code}\n\t\tbreak;\n\t${5}\n\tdefault:\n\t\t${2:// code}\n}"
" case
exe "Snipp case case '${1:case}':\n\t${2:// code}\n\tbreak;\n${3}"
" for (...) {...}
exe "Snipp for for (var ${2:i} = 0; $2 < ${1:Things}.length; $2${3:++}) {\n\t${4:$1[$2]}\n};"
" for (...) {...} (Improved Native For-Loop)
exe "Snipp forr for (var ${2:i} = ${1:Things}.length - 1; $2 >= 0; $2${3:--}) {\n\t${4:$1[$2]}\n};"
" while (...) {...}
exe "Snipp wh while (${1:/* condition */}) {\n\t${2:/* code */}\n}"
" do...while
exe "Snipp do do {\n\t${2:/* code */}\n} while (${1:/* condition */});"
" Object Method
exe "Snipp :f ${1:method_name}: function(${2:attribute}) {\n\t${4}\n}${3:,}"
" setTimeout function
exe 'Snipp timeout setTimeout(function() {${3}}${2}, ${1:10};'
" Get Elements
exe "Snipp get getElementsBy${1:TagName}('${2}')${3}"
" Get Element
exe "Snipp gett getElementBy${1:Id}('${2}')${3}"
