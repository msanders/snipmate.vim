if !exists('loaded_snips') || exists('b:did_sh_snips')
	fini
en
let b:did_sh_snips = 1

exe "Snipp if if [[ ${1:condition} ]]; then\n\t${2:#statements}\nfi"
exe "Snipp elif elif [[ ${1:condition} ]]; then\n\t${2:#statements}"
exe "Snipp for for (( ${2:i} = 0; $2 < ${1:count}; $2++ )); do\n\t${3:#statements}\ndone"
exe "Snipp wh while [[ ${1:condition} ]]; do\n\t${2:#statements}\ndone"
exe "Snipp until [[ ${1:condition} ]]; do\n\t${2:#statements}\ndone"
exe "Snipp case case ${1:word} in\n\t${2:pattern})\n\t\t${3};;\nesac"
