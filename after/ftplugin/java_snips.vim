if !exists('loaded_snips') || exists('s:did_java_snips')
	fini
en
let s:did_java_snips = 1
let snippet_filetype = 'java'

exe "Snipp main public static void main (String [] args)\n{\n\t${1:/* code */}\n}"
exe 'Snipp pu public'
exe 'Snipp po protected'
exe 'Snipp pr private'
exe 'Snipp st static'
exe 'Snipp fi final'
exe 'Snipp ab abstract'
exe 'Snipp re return'
exe 'Snipp br break;'
exe "Snipp de default:\n\t${1}"
exe 'Snipp ca catch(${1:Exception} ${2:e}) ${3}'
exe 'Snipp th throw '
exe 'Snipp sy synchronized'
exe 'Snipp im import'
exe 'Snipp j.u java.util'
exe 'Snipp j.i java.io.'
exe 'Snipp j.b java.beans.'
exe 'Snipp j.n java.net.'
exe 'Snipp j.m java.math.'
exe 'Snipp if if (${1}) ${2}'
exe 'Snipp el else '
exe 'Snipp elif else if (${1}) ${2}'
exe 'Snipp wh while (${1}) ${2}'
exe 'Snipp for for (${1}; ${2}; ${3}) ${4}'
exe 'Snipp fore for (${1} : ${2}) ${3}'
exe 'Snipp sw switch (${1}) ${2}'
exe "Snipp cs case ${1}:\n\t${2}\n${3}"
exe 'Snipp tc public class ${1:`Filename()`} extends ${2:TestCase}'
exe 'Snipp t public void test${1:Name}() throws Exception ${2}'
exe 'Snipp cl class ${1:`Filename("", "untitled")`} ${2}'
exe 'Snipp in interface ${1:`Filename("", "untitled")`} ${2:extends Parent}${3}'
exe 'Snipp m ${1:void} ${2:method}(${3}) ${4:throws }${5}'
exe 'Snipp v ${1:String} ${2:var}${3: = null}${4};${5}'
exe 'Snipp co static public final ${1:String} ${2:var} = ${3};${4}'
exe 'Snipp cos static public final String ${1:var} = "${2}";${3}'
exe 'Snipp as assert ${1:test} : "${2:Failure message}";${3}'
