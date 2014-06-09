if exists('g:loadedProjectPal')
	finish
endif

let g:loadedProjectPal = 1
let g:asyncStatusList = []
let g:asyncStatusInProgress = 0

command! -nargs=0 InitProject call s:initProject()
command! -nargs=0 GenerateTags call s:generateTags()
" experimental
command! -nargs=0 XGenerateJSTags call s:generateJSTags()

function! CreateProject(...)
	if a:0 < 2
		let path = input('project path: ')
	else 
		let path = a:2
	endif
	if a:0 < 1
		let name = input('project name: ')
	else
		let name = a:1
	endif
	let code=[
	\ "let g:proot=fnameescape('" . path . "')", 
	\ "let g:buildProjectCommand='pack'", 
	\ "let g:ptags = ['.']",
	\ "GenerateTags"
	\]  
	echo code
	exe '!mkdir ' . g:proj . name
	let settingsPath = g:proj . name . '/settings.vim'
	exe '!rm ' . settingsPath
	for s in code
		exe '!echo "' . s . '" >> ' . settingsPath		
	endfor
endfunction

function! AsyncStatus(cmd)
	if g:asyncStatusInProgress
		call add(g:asyncStatusList, a:cmd)
	else	
		let g:asyncStatusInProgress = 1
		exe 'set statusline=STARTED:\ ' . substitute(a:cmd, ' ', '\\ ', 'g')
		call asynccommand#run(a:cmd, s:asyncStatusCallback(a:cmd))
	endif
endfunction

function! BuildProject(...)
	if a:0 < 1
		let args = input('args: ')
	else 
		let args = a:1
	end
	exe 'cd ' . g:proot
	hi StatusLine guibg=DimGray
	exe 'call AsyncStatus("' . g:buildProjectCommand . ' ' . args . '")'
endfunction 

function! s:asyncStatusCallback(cmd)
    let env = {'cmd': a:cmd}
    function env.get(file_name)
        exe 'set statusline=COMPLETED:\ ' . substitute(self.cmd, ' ', '\\ ', 'g')
		let g:asyncStatusInProgress = 0
		if len(g:asyncStatusList)
			call AsyncStatus(remove(g:asyncStatusList, 0))
		endif
    endfunction
    return asynccommand#tab_restore(env)
endfunction



function! s:initProject()
	hi StatusLine guibg=DimGray
	let pname = input('Project Name: ')
	let g:currentProject = pname
	let g:fdbInitPath =  g:proj . g:currentProject . '/fdbinit.txt'
	"TODO: had to comment this out. VIM is not dealing with ~ paths correctly.
	"see http://stackoverflow.com/questions/15256706/how-to-pass-a-single-literal-tilde-in-runtimepath-as-pattern-to-substitute-i
	"if !filereadable(g:fdbInitPath)
	"	FDBReset
	"endif
	exe 'source ' . g:proj . pname . '/settings.vim'
endfunction

function! s:generateTags()
	let projPath = g:proj . g:currentProject . '/tags'
	exe 'silent !rm ' . projPath
	let args = '-Rf'
	let ctags = exists('g:ctagsPath') ? g:ctagsPath : 'ctags'
	for t in g:ptags
		exe 'call AsyncStatus("' . ctags . ' ' . args . ' ' . projPath . ' ' . shellescape(g:proot . t) . '")'
		let args = '-Raf'
	endfor
	exe 'set' . ' tags=' . projPath	
endfunction

"EXPERIMENTAL
function! s:generateJSTags()
	let projPath = g:proj . g:currentProject . '/tags'
	exe 'silent !rm ' . projPath
	for t in g:ptags
		exe 'call AsyncStatus("jstags ' . g:proot . t . ' >> ' . projPath . '")'
	endfor
	exe 'call AsyncStatus("sort ' . projPath . ' | uniq -ud > temp.txt ; mv temp.txt ' . projPath . '")'
	exe 'set' . ' tags=' . projPath
endfunction
" use: set tags+=tags
