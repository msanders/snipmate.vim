if !exists('g:loaded_snips') || exists('s:did_cpp_snips')
	 finish
endif
let s:did_cpp_snips = 1

" Read File Into Vector
exe "Snipp readfile std::vector<char> v;\nif (FILE *${2:fp} = fopen(${1:\"filename\"}, \"r\")) {\n\tchar buf[1024];\n\twhile (size_t len = "
	\ ."fread(buf, 1, sizeof(buf), $2))\n\t\tv.insert(v.end(), buf, buf + len);\n\tfclose($2);\n}${3}"
" std::map
exe "Snipp map std::map<${1:key}, ${2:value}> map${3};"
" std::vector
exe "Snipp vector std::vector<${1:char}> v${2};"
" Namespace
exe "Snipp ns namespace ${1:`Filename('', 'my')`} {\n\t${2}\n} /* $1 */"
" Class
exe "Snipp cl class ${1:`Filename('$1_t', 'name')`} {\npublic:\n\t$1 (${2:arguments});\n\tvirtual ~$1 ();\n\nprivate:\n\t${3:/* data */}\n};"
