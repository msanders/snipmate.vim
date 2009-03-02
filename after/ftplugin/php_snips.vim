if !exists('loaded_snips') || exists('s:did_php_snips')
	fini
en
let s:did_php_snips = 1
let snippet_filetype = 'php'

exe "Snipp php <?php\n${1}\n?>"
exe 'Snipp ec echo "${1:string}"${2};'
exe "Snipp inc include '${1:file}';${2}"
exe "Snipp inc1 include_once '${1:file}';${2}"
exe "Snipp req require '${1:file}';${2}"
exe "Snipp req1 require_once '${1:file}';${2}"
" $GLOBALS['...']
exe "Snipp globals $GLOBALS['${1:variable}']${2: = }${3:something}${4:;}${5}"
exe "Snipp! $_ \"COOKIE['...']\" $_COOKIE['${1:variable}']${2}"
exe "Snipp! $_ \"ENV['...']\" $_ENV['${1:variable}']${2}"
exe "Snipp! $_ \"FILES['...']\" $_FILES['${1:variable}']${2}"
exe "Snipp! $_ \"Get['...']\" $_GET['${1:variable}']${2}"
exe "Snipp! $_ \"POST['...']\" $_POST['${1:variable}']${2}"
exe "Snipp! $_ \"REQUEST['...']\" $_REQUEST['${1:variable}']${2}"
exe "Snipp! $_ \"SERVER['...']\" $_SERVER['${1:variable}']${2}"
exe "Snipp! $_ \"SESSION['...']\" $_SESSION['${1:variable}']${2}"
" Start Docblock
exe "Snipp /* /**\n * ${1}\n **/"
" Class - post doc
exe "Snipp doc_cp /**\n * ${1:undocumented class}\n *\n * @package ${2:default}\n * @author ${3:`g:snips_author`}\n**/${4}"
" Class Variable - post doc
exe "Snipp doc_vp /**\n * ${1:undocumented class variable}\n *\n * @var ${2:string}\n **/${3}"
" Class Variable
exe "Snipp doc_v /**\n * ${3:undocumented class variable}\n *\n * @var ${4:string}\n **/\n${1:var} $${2};${5}"
" Class
exe "Snipp doc_c /**\n * ${3:undocumented class}\n *\n * @packaged ${4:default}\n * @author ${5:`g:snips_author`}\n **/\n${1:}class ${2:}\n{${6}\n} // END $1class $2"
" Constant Definition - post doc
exe "Snipp doc_dp /**\n * ${1:undocumented constant}\n **/${2}"
" Constant Definition
exe "Snipp doc_d /**\n * ${3:undocumented constant}\n **/\ndefine(${1}, ${2});${4}"
" Function - post doc
exe "Snipp doc_fp /**\n * ${1:undocumented function}\n *\n * @return ${2:void}\n * @author ${3:`g:snips_author`}\n **/${4}"
" Function signature
exe "Snipp doc_s /**\n * ${4:undocumented function}\n *\n * @return ${5:void}\n * @author ${6:`g:snips_author`}\n **/\n${1}function ${2}(${3});${7}"
" Function
exe "Snipp doc_f /**\n * ${4:undocumented function}\n *\n * @return ${5:void}\n * @author ${6:`g:snips_author`}\n **/\n${1}function ${2}(${3})\n{${7}\n}"
" Header
exe "Snipp doc_h /**\n * ${1}\n *\n * @author ${2:`g:snips_author`}\n * @version ${3:$Id$}\n * @copyright ${4:$2}, `strftime('%d %B, %Y')`\n * @package ${5:default}\n **/\n\n/**\n * Define DocBlock\n *//"
" Interface
exe "Snipp doc_i /**\n * ${2:undocumented class}\n *\n * @package ${3:default}\n * @author ${4:`g:snips_author`}\n **/\ninterface ${1:}\n{${5}\n} // END interface $1"
" class ...
exe "Snipp class /**\n * ${1}\n **/\nclass ${2:ClassName}\n{\n\t${3}\n\tfunction ${4:__construct}(${5:argument})\n\t{\n\t\t${6:// code...}\n\t}\n}"
" define(...)
exe "Snipp def define('${1}'${2});${3}"
" defined(...)
exe "Snipp def? ${1}defined('${2}')${3}"
exe "Snipp wh while (${1:/* condition */}) {\n\t${2:// code...}\n}"
" do ... while
exe "Snipp do do {\n\t${2:// code... }\n} while (${1:/* condition */});"
exe "Snipp if if (${1:/* condition */}) {\n\t${2:// code...}\n}"
exe "Snipp ife if (${1:/* condition */}) {\n\t${2:// code...}\n} else {\n\t${3:// code...}\n}\n${4}"
exe "Snipp else else {\n\t${1:// code...}\n}"
exe "Snipp elseif elseif (${1:/* condition */}) {\n\t${2:// code...}\n}"
" Tertiary conditional
exe "Snipp t $${1:retVal} = (${2:condition}) ? ${3:a} : ${4:b};${5}"
exe "Snipp switch switch ($${1:variable}) {\n\tcase '${2:value}':\n\t\t${3:// code...}\n\t\tbreak;\n\t${5}\n\tdefault:\n\t\t${4:// code...}\n\t\tbreak;\n}"
exe "Snipp case case '${1:value}':\n\t${2:// code...}\n\tbreak;${3}"
exe "Snipp for for ($${2:i} = 0; $$2 < ${1:count}; $$2${3:++}) {\n\t${4: // code...}\n}"
exe "Snipp foreach foreach ($${1:variable} as $${2:key}) {\n\t${3:// code...}\n}"
exe "Snipp fun ${1:public }function ${2:FunctionName}(${3})\n{\n\t${4:// code...}\n}"
" $... = array (...)
exe "Snipp array $${1:arrayName} = array('${2}' => ${3});${4}"
