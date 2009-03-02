if !exists('loaded_snips') || exists('s:did_tex_snips')
	fini
en
let s:did_tex_snips = 1
let snippet_filetype = 'tex'

" \begin{}...\end{}
exe "Snipp begin \\begin{${1:env}}\n\t${2}\n\\end{$1}"
" Tabular
exe "Snipp tab \\begin{${1:tabular}}{${2:c}}\n${3}\n\\end{$1}"
" Align(ed)
exe "Snipp ali \\begin{align${1:ed}}\n\t${2}\n\\end{align$1}"
" Gather(ed)
exe "Snipp gat \\begin{gather${1:ed}}\n\t${2}\n\\end{gather$1}"
" Equation
exe "Snipp eq \\begin{equation}\n\t${1}\n\\end{equation}"
" Unnumbered Equation
exe "Snipp \\ \\\\[\n\t${1}\n\\\\]"
" Enumerate
exe "Snipp enum \\begin{enumerate}\n\t\\item ${1}\n\\end{enumerate}"
" Itemize
exe "Snipp item \\begin{itemize}\n\t\\item ${1}\n\\end{itemize}"
" Description
exe "Snipp desc \\begin{description}\n\t\\item[${1}] ${2}\n\\end{description}"
" Matrix
exe "Snipp mat \\begin{${1:p/b/v/V/B/small}matrix}\n\t${2}\n\\end{$1matrix}"
" Cases
exe "Snipp cas \\begin{cases}\n\t${1:equation}, &\\text{ if }${2:case}\\\\\n\t${3}\n\\end{cases}"
" Split
exe "Snipp spl \\begin{split}\n\t${1}\n\\end{split}"
" Part
exe "Snipp part \\part{${1:part name}} % (fold)\n\\label{prt:${2:$1}}\n${3}\n% part $2 (end)"
" Chapter
exe "Snipp cha \\chapter{${1:chapter name}} % (fold)\n\\label{cha:${2:$1}}\n${3}\n% chapter $2 (end)"
" Section
exe "Snipp sec \\section{${1:section name}} % (fold)\n\\label{sec:${2:$1}}\n${3}\n% section $2 (end)"
" Sub Section
exe "Snipp sub \\subsection{${1:subsection name}} % (fold)\n\\label{sub:${2:$1}}\n${3}\n% subsection $2 (end)"
" Sub Sub Section
exe "Snipp subs \\subsubsection{${1:subsubsection name}} % (fold)\n\\label{ssub:${2:$1}}\n${3}\n% subsubsection $2 (end)"
" Paragraph
exe "Snipp par \\paragraph{${1:paragraph name}} % (fold)\n\\label{par:${2:$1}}\n${3}\n% paragraph $2 (end)"
" Sub Paragraph
exe "Snipp subp \\subparagraph{${1:subparagraph name}} % (fold)\n\\label{subp:${2:$1}}\n${3}\n% subparagraph $2 (end)"
exe 'Snipp itd \item[${1:description}] ${2:item}'
exe 'Snipp figure ${1:Figure}~\ref{${2:fig:}}${3}'
exe 'Snipp table ${1:Table}~\ref{${2:tab:}}${3}'
exe 'Snipp listing ${1:Listing}~\ref{${2:list}}${3}'
exe 'Snipp section ${1:Section}~\ref{${2:sec:}}${3}'
exe 'Snipp page ${1:page}~\pageref{${2}}${3}'
