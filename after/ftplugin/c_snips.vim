if !exists('g:loaded_snips') || exists('b:did_c_snips')
	fini
en
let b:did_c_snips = 1

" main()
exe "Snipp main int main (int argc, char const* argv[])\n{\n\t${1}\n\treturn 0;\n}"
" #include <...>
exe 'Snipp inc #include <${1:stdio}.h>${2}'
" #include "..."
exe 'Snipp Inc #include "${1:`Filename("$1.h")`}"${2}'
" #ifndef ... #define ... #endif
exe "Snipp def #ifndef $1\n#define ${1:SYMBOL} ${2:value}\n#endif${3}"
" Header Include-Guard
" (the randomizer code is taken directly from TextMate; I don't know how to do
" it in vim script, it could probably be cleaner)
exe "Snipp once #ifndef ${1:`toupper(Filename('', 'UNTITLED').'_'.system(\"/usr/bin/ruby -e 'print (rand * 2821109907455).round.to_s(36)'\"))`}\n"
	\ ."#define $1\n\n${2}\n\n#endif /* end of include guard: $1 */"
" Read File Into Vector
exe "Snipp readfile std::vector<char> v;\nif (FILE *${2:fp} = fopen(${1:\"filename\"}, \"r\")) {\n\tchar buf[1024];\n\twhile (size_t len = "
	\ ."fread(buf, 1, sizeof(buf), $2))\n\t\tv.insert(v.end(), buf, buf + len);\n\tfclose($2);\n}${3}"
" If Condition
exe "Snipp if if (${1:/* condition */}) {\n\t${2:/* code */}\n}"
exe "Snipp el else {\n\t${1}\n}"
" Tertiary conditional
exe 'Snipp t ${1:/* condition */} ? ${2:a} : ${3:b}'
" Do While Loop
exe "Snipp do do {\n\t${2:/* code */}\n} while (${1:/* condition */});"
" While Loop
exe "Snipp wh while (${1:/* condition */}) {\n\t${2:/* code */}\n}"
" For Loop
exe "Snipp for for (${2:i} = 0; $2 < ${1:count}; $2${3:++}) {\n\t${4:/* code */}\n}"
" Custom For Loop
exe "Snipp forr for (${1:i} = 0; ${2:$1 < 5}; $1${3:++}) {\n\t${4:/* code */}\n}"
" Function
exe "Snipp fun ${1:void} ${2:function_name} (${3})\n{\n\t${4:/* code */}\n}"
" Typedef
exe 'Snipp td typedef ${1:int} ${2:MyCustomType};'
" Struct
exe "Snipp st struct ${1:`Filename('$1_t', 'name')`} {\n\t${2:/* data */}\n}${3: /* optional variable list */};${4}"
" Typedef struct
exe "Snipp tds typedef struct {\n\t${2:/* data */}\n} ${1:`Filename('$1_t', 'name')`};"
" Class
exe "Snipp cl class ${1:`Filename('$1_t', 'name')`} {\npublic:\n\t$1 (${2:arguments});\n\tvirtual ~$1 ();\n\nprivate:\n\t${3:/* data */}\n};"
" Namespace
exe "Snipp ns namespace ${1:`Filename('', 'my')`} {\n\t${2}\n} /* $1 */"
" std::map
exe "Snipp map std::map<${1:key}, ${2:value}> map${3};"
" std::vector
exe "Snipp vector std::vector<${1:char}> v${2};"
" printf
" unfortunately version this isn't as nice as TextMates's, given the lack of a
" dynamic `...`
exe 'Snipp pr printf("${1:%s}\n"${2});${3}'
" fprintf (again, this isn't as nice as TextMate's version, but it works)
exe 'Snipp fpr fprintf(${1:stderr}, "${2:%s}\n"${3});${4}'
