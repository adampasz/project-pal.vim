function! InitProject()
	call InitAS3Syntax()
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

function! GenerateTags()
	let projPath = g:proj . g:currentProject . '/tags'
	exe 'silent !rm ' . projPath
	let args = '-Rf'
	for t in g:ptags
		exe 'call AsyncStatus("ctags ' . args . ' ' . projPath . ' ' . shellescape(g:proot . t) . '")'
		let args = '-Raf'
	endfor
	exe 'set' . ' tags=' . projPath	
endfunction

let g:asyncStatusList = []
let g:asyncStatusInProgress = 0

function! AsyncStatus(cmd)
	if g:asyncStatusInProgress
		call add(g:asyncStatusList, a:cmd)
	else	
		let g:asyncStatusInProgress = 1
		exe 'set statusline=STARTED:\ ' . substitute(a:cmd, ' ', '\\ ', 'g')
		call asynccommand#run(a:cmd, AsyncStatusCallback(a:cmd))
	endif
endfunction

function! AsyncStatusCallback(cmd)
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