"======================================================================
"
" init_leaderf.vim - 
"
" Created by skywind on 2020/03/01
" Last Modified: 2020/03/01 04:43:07
"
"======================================================================


"----------------------------------------------------------------------
" keymap
"----------------------------------------------------------------------
let g:Lf_ShortcutF = '<c-p>'
let g:Lf_ShortcutB = '<m-n>'
noremap <c-n> :cclose<cr>:Leaderf --nowrap mru --regexMode<cr>
noremap <m-p> :cclose<cr>:Leaderf! --nowrap function<cr>
noremap <m-P> :cclose<cr>:Leaderf! --nowrap buftag<cr>
noremap <m-n> :cclose<cr>:Leaderf! --nowrap buffer<cr>
noremap <m-m> :cclose<cr>:Leaderf --nowrap tag<cr>

"----------------------------------------------------------------------
" filer
"----------------------------------------------------------------------
let g:Lf_FilerShowPromptPath = 1
let g:Lf_FilerInsertMap = { '<Tab>': 'open_current', '<CR>': 'open_current',
	\ '<BS>': 'open_parent_or_backspace', '<up>': 'up', '<down>': 'down'}
let g:Lf_FilerNormalMap = {'i': 'switch_insert_mode', '<esc>': 'quit', 
	\ '~': 'goto_root_marker_dir', 'M': 'mkdir', 'T': 'create_file' }
" let g:Lf_FilerOnlyIconHighlight = 1
	
" 使用C语言库来查询，速度会快些
let g:Lf_fuzzyEngine_C = 1
" 最大历史文件保存 2048 个
let g:Lf_MruMaxFiles = 2048
let g:Lf_GtagsAutoGenerate = 0
let g:Lf_GtagsGutentags = 1
" ui 定制
let g:Lf_StlSeparator = { 'left': '', 'right': '', 'font': '' }

" 如何识别项目目录，从当前文件目录向父目录递归知道碰到下面的文件/目录
let g:Lf_RootMarkers = ['.project', '.root', '.svn', '.git']
let g:Lf_WorkingDirectoryMode = 'Ac'
let g:Lf_WindowHeight = 0.30
let g:Lf_CacheDirectory = expand('~/.vim/cache')

" 显示绝对路径
let g:Lf_ShowRelativePath = 0

" 隐藏帮助
let g:Lf_HideHelp = 1

" 模糊匹配忽略扩展名
let g:Lf_WildIgnore = {
            \ 'dir': ['.svn','.git','.hg'],
            \ 'file': ['*.sw?','~$*','*.bak','*.exe','*.o','*.so','*.py[co]']
            \ }

" MRU 文件忽略扩展名
let g:Lf_MruFileExclude = ['*.so', '*.exe', '*.py[co]', '*.sw?', '~$*', '*.bak', '*.tmp', '*.dll']
let g:Lf_StlColorscheme = 'powerline'

" 禁用 function/buftag 的预览功能，可以手动用 p 预览
let g:Lf_PreviewResult = {'Function':0, 'BufTag':0}

" 使用 ESC 键可以直接退出 leaderf 的 normal 模式
let g:Lf_NormalMap = {
            \ "File":   [["<ESC>", ':exec g:Lf_py "fileExplManager.quit()"<CR>']],
            \ "Buffer": [["<ESC>", ':exec g:Lf_py "bufExplManager.quit()"<cr>']],
            \ "Mru": [["<ESC>", ':exec g:Lf_py "mruExplManager.quit()"<cr>']],
            \ "Tag": [["<ESC>", ':exec g:Lf_py "tagExplManager.quit()"<cr>']],
            \ "BufTag": [["<ESC>", ':exec g:Lf_py "bufTagExplManager.quit()"<cr>']],
            \ "Function": [["<ESC>", ':exec g:Lf_py "functionExplManager.quit()"<cr>']],
            \ }

"----------------------------------------------------------------------
" filer
"----------------------------------------------------------------------
let g:Lf_FilerShowPromptPath = 1
let g:Lf_FilerInsertMap = { '<Tab>': 'open_current', '<CR>': 'open_current', '<BS>': 'open_parent_or_backspace', '<up>': 'up', '<down>': 'down'}
let g:Lf_FilerNormalMap = {'i': 'switch_insert_mode', '<esc>': 'quit', '~': 'goto_root_marker_dir', 'M': 'mkdir', 'T': 'create_file' }
" let g:Lf_FilerOnlyIconHighlight = 1


"----------------------------------------------------------------------
" keymap
"----------------------------------------------------------------------
nnoremap <space>ff :<c-u>Leaderf file<cr>
nnoremap <space>fe :<c-u>Leaderf filer<cr>
nnoremap <space>fb :<c-u>Leaderf buffer<cr>
nnoremap <space>fm :<c-u>Leaderf mru<cr>
nnoremap <space>fg :<c-u>Leaderf gtags<cr>
nnoremap <space>fr :<c-u>Leaderf rg<cr>
" nnoremap <space>fw :<c-u>Leaderf window<cr>
nnoremap <space>fn :<c-u>Leaderf function<cr>
nnoremap <space>ft :<c-u>Leaderf tag<cr>
nnoremap <space>fu :<c-u>Leaderf bufTag<cr>
nnoremap <space>fs :<c-u>Leaderf self<cr>
nnoremap <space>fc :<c-u>Leaderf colorscheme<cr>
nnoremap <space>fy :<c-u>Leaderf cmdHistory<cr>
" nnoremap <space>fh :<c-u>Leaderf help<cr>
nnoremap <space>fj :<c-u>Leaderf jumps<cr>
nnoremap <space>fp :<c-u>Leaderf snippet<cr>
nnoremap <space>fq :<c-u>Leaderf quickfix<cr>
nnoremap <space>fa :<c-u>Leaderf tasks<cr>

inoremap <c-x><c-x> <c-\><c-o>:Leaderf snippet<cr>

nnoremap <space>fd :exec 'Leaderf filer ' . shellescape(expand('%:p:h'))<cr>

