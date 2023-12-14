"======================================================================
"
" keymaps.vim - keymaps start with using <space>
"
" Created by skywind on 2016/10/12
" Last Modified: 2018/05/02 13:05
"
"======================================================================

function! s:ErrorMsg(msg)
	echohl ErrorMsg
	echom ' [ERROR]: '. a:msg
	echohl NONE
endfunc

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 替换字符串
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! TextReplace(text, old, new)
	let data = split(a:text, a:old, 1)
	return join(data, a:new)
endfunc

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 切换路径到当前文件
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! Change_DirectoryToFile()
	let l:filename = expand("%:p")
	if l:filename == "" | return | endif
	silent exec 'cd '.expand("%:p:h")
	exec 'pwd'
endfunc

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Open file in new tab if it hasn't been open, or reuse the existant tab
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! Tools_FileSwitch(how, ...)
	if a:0 == 0 | return | endif
	let l:tabcc = tabpagenr()
	let l:wincc = winnr()
	let l:filename = fnamemodify(a:{a:0}, ':p')
	let l:params = []
	for i in range(a:0 - 1)
		let l:params += [a:{i + 1}]
	endfor
	if has('win32') || has('win16') || has('win64') || has('win95')
		let l:filename = substitute(l:filename, "\\", '/', 'g')
	endif
	for i in range(tabpagenr('$'))
		let l:buflist = tabpagebuflist(i + 1)
		for j in range(len(l:buflist))
			let l:bufnr = l:buflist[j]
			if !getbufvar(l:bufnr, '&modifiable')
				continue
			endif
			let l:buftype = getbufvar(l:bufnr, '&buftype')
			if l:buftype == 'quickfix' || l:buftype == 'nofile'
				continue
			endif
			let l:name = fnamemodify(bufname(l:bufnr), ':p')
			if has('win32') || has('win16') || has('win64') || has('win95')
				let l:name = substitute(l:name, "\\", '/', 'g')
			endif
			if l:filename == l:name
				silent exec 'tabn '.(i + 1)
				silent exec ''.(j + 1).'wincmd w'
				for item in l:params
					if strpart(item, 0, 2) == '+:'
						silent exec strpart(item, 2)
					endif
				endfor
				return
			endif
		endfor
	endfor
	if (a:how == 'edit') || (a:how == 'e')
		silent exec '1wincmd w'
		exec 'e '.fnameescape(l:filename)
	elseif (a:how == 'tabedit') || (a:how == 'tabe') || (a:how == 'tabnew')
		exec 'tabe '.fnameescape(l:filename)
	elseif (a:how == 'split') || (a:how == 'sp')
		silent exec '1wincmd w'
		exec 'split '.fnameescape(l:filename)
	elseif (a:how == 'vsplit') || (a:how == 'vs')
		silent exec '1wincmd w'
		exec 'vsplit '.fnameescape(l:filename)
	elseif (a:how == 'drop')
		silent exec '1wincmd w'
		exec 'drop '.fnameescape(l:filename)
	elseif (a:how == 'pedit')
		silent exec '1wincmd w'
		exec 'pedit ' . fnameescape(l:filename)
	else
		let cmd = join([':', a.how, fnameescape(l:filename)], " ")
		call feedkeys(cmd)
		return
	endif
	for item in l:params
		if strpart(item, 1, 2) == '+:'
			silent exec strpart(item, 3)
		endif
	endfor
endfunc


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 获取选中词
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! GetVisualSelection()
	"Shamefully stolen from http://stackoverflow.com/a/6271254/794380
	" Why is this not a built-in Vim script function?!
	let [lnum1, col1] = getpos("'<")[1:2]
	let [lnum2, col2] = getpos("'>")[1:2]
	let lines = getline(lnum1, lnum2)
	let lines[-1] = lines[-1][: col2 - (&selection == 'inclusive' ? 1 : 2)]
	let lines[0] = lines[0][col1 - 1:]
	return join(lines, "\n")
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 获取选中词或单前光标下的词
" 1：选中
" 2：当前行
" 3：单词直到空白
" 默认：单词
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! GetUnderWord(mode)
	if a:mode == 1
		return GetVisualSelection()
	elseif a:mode == 2
		return getline('.')
	elseif a:mode == 3
		return expand("<cWORD>")
	endif
	return expand("<cword>")
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 和python相关函数入口操作
" 变量类型判断,不要直接使用此值，最好用含有此值的 v:t_ 变量
" 数值:     	    0  |v:t_number|
" 字符串:   	    1  |v:t_string|
" 函数引用: 	    2  |v:t_func|
" 列表:     	    3  |v:t_list|
" 字典:     	    4  |v:t_dict|
" 浮点数:   	    5  |v:t_float|
" 布尔值:   	    6  |v:t_bool| (v:false 和 v:true)
" None:     	    7  |v:t_none| (v:null 和 v:none)
" 作业:     	    8  |v:t_job|
" 通道:     	    9  |v:t_channel|
" blob:     	   10  |v:t_blob|
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! PythonQuery(query, data, extra)
	if type(a:query) == v:t_string
		let pyquery = TextReplace(a:query, "'", "''")
	else
		let pyquery = a:query
	endif
	if type(a:data) == v:t_string
		let pydata = TextReplace(a:data, "'", "''")
	else
		let pydata = a:data
	endif
	if type(a:extra) == v:t_string
		let pyextra = TextReplace(a:extra, "'", "''")
	else
		let pyextra = a:extra
	endif

python3 <<EOM
import vim
import os
import re

pyquery = vim.eval("pyquery")
pydata = vim.eval("pydata")
pyextra = vim.eval("pyextra")

def pythonQuery(query, data, extra):
	def isValidType(value, t):
		if value is None:
			return False
		if not isinstance(value, t):
			return False
		return True

	def isValidLen(value, t):
		if not isValidType(value, t):
			return False
		if len(value):
			return True
		return False

	def pathType(data, extra):
		if not isValidLen(data, str):
			return "error"
		if os.path.ismount(data):
			return "mount"
		if os.path.isdir(data):
			return "dir"
		if os.path.isfile(data):
			return "file"
		return "error"

	def normpath(data, extra):
		if not isValidLen(data, str):
			return ""
		filepath = data.strip().rstrip().rstrip('\n').strip('\n')
		filepath = os.path.normpath(filepath)
		if extra:
			if "lower" in extra:
				filepath = filepath.lower()
			elif "upper" in extra:
				filepath = filepath.upper()
			if "win" in extra:
				filepath = filepath.replace("/", "\\")
			elif "unix" in extra:
				filepath = filepath.replace("\\", "/")
		return filepath

	def substring(data, extra):
		if not isValidLen(data, str):
			return ""
		if isValidLen(extra, list) and len(extra) == 3:
			start = extra[0]
			if not start:
				start = 0
			end = extra[1]
			if not end:
				end = len(data)
			step = extra[2]
			if not step:
				step = 1
			return data[start:end:step]
		if isValidLen(extra, dict):
			start = 0
			end = len(data)
			step = 1
			if 'start' in extra.keys():
				start = extra["start"]
			if 'end' in extra.keys():
				end = extra["end"]
			if 'step' in extra.keys():
				step = extra["step"]
			sub = data[start:end:step]
			if 'lower' in extra.keys():
				sub = sub.lower()
			elif 'upper' in extra.keys():
				sub = sub.upper()
			return sub
		if isValidLen(extra, str):
			pos = data.find(extra)
			if pos > 0:
				return data[0:pos]
		if isinstance(extra, int):
			return data[0:extra]
		return ""

	def pathHeadTail(data, extra):
		filepath = normpath(data, extra)
		head, tail = os.path.split(filepath)
		if head and tail:
			return [head, tail]
		return ["", ""]

	def pathShortname(data, extra):
		if not isValidLen(data, str):
			return ""
		_, tail = pathHeadTail(data, extra)
		if not isValidLen(tail, str):
			tail = data
		if tail:
			if "." in tail:
				suffix = tail.split(".")
				return ['.'.join(suffix[0:-1]), suffix[-1]]
			return [tail, ""]
		return ""

	def pathJoin(data, extra):
		if not isValidLen(data, str):
			return ""
		if not isValidLen(extra, str):
			return ""
		filepath = os.path.join(data, extra)
		filepath = normpath(filepath, "")
		return filepath

	def filterType(data, extra):
		shortname = pathShortname(data, "")
		if not shortname or not shortname[-1]:
			return ""
		if extra == "suf":
			return shortname[-1]
		suffix = shortname[-1].lower()
		hlist = ["h", "hh", "hpp", "hxx"]
		cList = ["cxx", "c", "c++", "cpp", "ipp", "tcc", "inl", "cc"]
		if extra == "opp":
			if suffix in hlist:
				return cList
			if suffix in cList:
				return hlist
		elif extra == "like":
			if suffix in hlist:
				return hlist
			if suffix in cList:
				return cList
		elif extra == "all":
			if suffix in hlist or suffix in cList:
				suffixs = []
				for h in hlist:
					suffixs.append(h)
				for c in cList:
					suffixs.append(c)
				return suffixs
		return ""

	def fdFilterType(data, extra):
		suffix = filterType(data, extra)
		if not suffix:
			return ''
		if isValidLen(suffix, str):
			return "-e " + suffix
		if not isValidLen(suffix, list):
			return ''
		s = ""
		for suf in suffix:
			if len(s):
				s = s + " -e " + suf
			else:
				s = "-e " + suf
		return s

	def transEscape(data, extra):
		if not isValidLen(data, str):
			return ""
		_special_chars_map = [i for i in '#*/\\\t\n\r\v\f']
		for i in _special_chars_map:
			data = data.replace(i, " ")
		return ' '.join(data.split())

	def ripGrepEscape(data, extra):
		if not isValidLen(data, str):
			return ""
		pattern = data.rstrip('\n').rstrip('\r').rstrip('\n\r')
		pattern = pattern.strip()
		_special_chars_map = {i: '\\' + chr(i) for i in b'()[]{}?*+-|^$\\.&~#"\t\n\r\v\f'}
		translate = pattern.translate(_special_chars_map)
		restr = translate
		double_virgule = "\\\\"
		find_index = restr.find(double_virgule)
		if find_index >= 0:
			find_counts = []
			for f in re.finditer(r"(\\\\){1,}", translate):
				s = f.group()
				if s is not None and isinstance(s, str):
					n = int(len(s) / 2)
					if n not in find_counts:
						find_counts.append(n)
			find_counts.sort(reverse=True)
			for n in find_counts:
				repl = r"(\\)" + "{" + str(n) + "}"
				ptn = n * double_virgule
				restr = restr.replace(ptn, repl)
		return restr

	def ripGrepFilterType(data, extra):
		suffix = filterType(data, extra)
		if not suffix:
			return ''
		if isValidLen(suffix, str):
			suffix = [suffix]
		if not isValidLen(suffix, list):
			return ''
		#-g '*.{c,h}'
		s = '-g "*.{'
		s = s + ",".join(suffix)
		s = s + '}"'
		return s
	
	def rootPath(data, extra):
		if not isValidLen(data, str):
			return ""
		markers = ['.root', '.git', '.hg', '.svn', '.project']
		if extra:
			if isValidLen(data, str):
				markers = [extra]
			elif isValidLen(extra, list):
				markers = extra
			elif isValidLen(extra, dict):
				markers = extra["markers"]
		pathdir = data
		while True:
			if not pathdir:
				break
			for marker in markers:
				filepath = os.path.join(pathdir, marker)
				if pathType(filepath, "") == "dir":
					return pathdir
			headTail = pathHeadTail(pathdir, "")
			if headTail:
				pathdir = headTail[0]
			else:
				pathdir = ""
		return ""

	def searchFilename(data, extra):
		if not isValidLen(data, str):
			return ""

		def searchFilenameAppendPathType(normfile, fileList, extra):
			if not isValidLen(normfile, str):
				return

			def searchFilenameAppendFileList(normfile, startFileList):
				if normfile not in startFileList:
					startFileList.append(normfile)

			if os.path.isfile(normfile) or os.path.isdir(normfile):
				isFilter = False
				if "file" in extra:
					isFilter = True
					if os.path.isfile(normfile):
						searchFilenameAppendFileList(normfile, fileList)
						return True
				if "dir" in extra:
					isFilter = True
					if os.path.isdir(normfile):
						searchFilenameAppendFileList(normfile, fileList)
						return True
				if not isFilter:
					searchFilenameAppendFileList(normfile, fileList)
					return True

		def searchFilenameFindMount(normfile, mountFileList, extra="full"):
			if not isValidLen(normfile, str):
				return
			mountIds = [":\\"]
			for mountId in mountIds:
				if mountId not in normfile:
					continue
				#按分割符分割，只判断第一个找到的
				filePaths = normfile.split(mountId)
				# 判断在mountId前一个字符不是空
				if filePaths[0][-1] != ' ':
					#按空分割
					mountPathList = filePaths[0].split()
					#取最后一个非空分割字符。并且从最后索引到开始判断是否为mount
					mountPathtail = mountPathList[-1]
					for i in range(len(mountPathtail), 0, -1):
						mountPath = mountPathtail[i - 1:] + mountId
						if os.path.ismount(mountPath):
							if extra == "head":
								if mountPath not in mountFileList:
									mountFileList.append(mountPath)
							else:
								filePathTail = mountId.join(filePaths[1:])
								startFilename = os.path.join(mountPath, filePathTail)
								startFilename = normpath(startFilename, "")
								if not isValidLen(mountFileList, list):
									mountFileList.append(startFilename)
								else:
									for i in range(0, len(mountFileList)):
										file = mountFileList[i]
										if startFilename in file:
											if startFilename != file:
												mountFileList[i] = substring(file, startFilename)
												mountFileList.append(startFilename)

							# 查找下一个
							if len(filePaths) > 2:
								filePathTails = mountId.join(filePaths[1:])
								searchFilenameFindMount(filePathTails, mountFileList)

		def searchFilenameFindAbsolutePath(filename, fileList, extra):
			normfile = normpath(filename, "")
			mountFileList = []
			searchFilenameFindMount(normfile, mountFileList)
			if not isValidLen(mountFileList, list):
				return
			for startFilename in mountFileList:
				splitList = startFilename.split('\\')
				pathDir = '\\'.join(splitList[:-1])
				shortFilename = splitList[-1]
				for i in range(0, len(shortFilename)):
					filename = os.path.join(pathDir, shortFilename[0:len(shortFilename) - i])
					filename = normpath(filename, "")
					searchFilenameAppendPathType(filename, fileList, extra)
				if isValidLen(pathDir, str):
					searchFilenameAppendPathType(pathDir, fileList, extra)

		def searchFilenameShortFilename(filename, fileList, extra):
			normfile = normpath(filename, "")
			if not isValidLen(normfile, str):
				return

			def searchFilenameAppendShort(filename, fileList, extra):
				shortIds = ["/", "\\"]
				for ins in shortIds:
					if ins in filename:
						if filename not in fileList:
							fileList.append(filename)

			def searchFilenameUnSepcAppend(filename, fileList, extra):
				unSpecificationsFilenameCharList = [":"]
				mountList = []
				searchFilenameFindMount(filename, mountList, "head")
				for unspec in unSpecificationsFilenameCharList:
					normList = filename.split(unspec)
					for norm in normList:
						if mountList:
							for mount in mountList:
								if os.path.join(mount, norm) in filename:
									norm = os.path.join(mount, norm)
						searchFilenameAppendShort(norm, fileList, extra)

			searchFilenameUnSepcAppend(normfile, fileList, extra)

		def searchFilenameVaildFilename(filename, fileList, extra):
			if not isValidLen(filename, str):
				return ""
			normfile = normpath(filename, "")
			if not searchFilenameAppendPathType(normfile, fileList, extra):
				if "short" in extra:
					searchFilenameShortFilename(filename, fileList, extra)
				else:
					searchFilenameFindAbsolutePath(normfile, fileList, extra)

		stripInputStr = normpath(data, "")
		unSpecificationsFilenameCharList = ["|", "*", "?", "'", '"', "<", ">", "\n"]
		fileList = []
		unFilenameTodo = False
		for c in unSpecificationsFilenameCharList:
			if c in stripInputStr:
				unFilenameTodo = True
				specificationsFilenameList = stripInputStr.split(c)
				for specificationsFilename in specificationsFilenameList:
					findInputStr = specificationsFilename.strip().rstrip()
					searchFilenameVaildFilename(findInputStr, fileList, extra)
		if not unFilenameTodo:
			searchFilenameVaildFilename(stripInputStr, fileList, extra)
		if "first" in extra:
			if isValidLen(fileList, list):
				return fileList[0]
			else:
				return ""
		if "last" in extra:
			if isValidLen(fileList, list):
				return fileList[-1]
			else:
				return ""
		return fileList

	def parseInputArgs(data, extra):
		args = []
		extra = int(extra)
		for i in range(0, extra):
			args.append('')
		if not isValidLen(data, str):
			return args
		text = data.strip().rstrip()
		spacePos = text.find(' ')
		if 0 < spacePos < extra:
			for i in range(0, spacePos):
				args[i] = text[i].lower()
			args[-1] = text[spacePos + 1:].strip().rstrip()
		else:
			if len(text) < extra:
				for i in range(0, len(text)):
					args[i] = text[i].lower()
			else:
				args[-1] = text
		return args

	def tryFindFile(data, extra):
		fileList = []
		if not isValidLen(data, str):
			return fileList
		findPathList = []
		filter = "opp"
		if isValidLen(extra, str):
			findPathList.append(extra)
		if isValidLen(extra, list):
			for ex in extra:
				if ex not in findPathList:
					findPathList.append(ex)
		if isValidLen(extra, dict):
			if "filter" in extra:
				filter = extra["filter"]
			if "path" in extra:
				if isValidLen(extra["path"], str):
					findPathList.append(extra["path"])
				if isValidLen(extra["path"], list):
					for p in extra["path"]:
						if p not in findPathList:
							findPathList.append(p)
		if not isValidLen(findPathList, list):
			return fileList
		if not isValidLen(filter, str):
			return fileList

		shortPathList = searchFilename(data, "short")

		#找到可能的没有后缀的文件
		def tryFindFileShortNameList(pathList):
			rlist = []
			if isValidLen(pathList, list):
				for path in pathList:
					shortnames = pathShortname(path, "")
					if isValidLen(shortnames, list) and isValidLen(shortnames[0], str):
						if shortnames[0] not in rlist:
							rlist.append(shortnames[0])
			return rlist
		maybeShortNameList = []
		for path in shortPathList:
			maybeShortNameList.append(path)
		if not isValidLen(maybeShortNameList, list):
			maybeShortNameList.append(data)
		shortNameList = tryFindFileShortNameList(maybeShortNameList)
		if not isValidLen(shortNameList, list):
			return fileList

		# 找到可能的后缀名
		def tryFindFileFilterList(maybeShortNameList):
			filterList = []
			for shorname in maybeShortNameList:
				filters = filterType(shorname, filter)
				if isValidLen(filters, str):
					if filters not in filterList:
						filterList.append(filters)
				if isValidLen(filters, list):
					for f in filters:
						if f not in filterList:
							filterList.append(f)
			return filterList

		filterList = tryFindFileFilterList(maybeShortNameList)
		if not isValidLen(filterList, list):
			return fileList

		# 返回列表增加
		def tryFindFileAppendFile(flist, fname):
			filename = normpath(fname, "")
			if os.path.isfile(filename):
				if filename not in flist:
					flist.append(filename)

		for filedir in findPathList:
			for suffix in filterList:
				for shortname in shortNameList:
					maybeFilename = shortname + "." + suffix
					filename = os.path.join(filedir, maybeFilename)
					tryFindFileAppendFile(fileList, filename)
					if not isValidLen(shortPathList, list):
						continue
					for shortPath in shortPathList:
						pathdir = shortPath
						while True:
							if not pathdir:
								break
							absFiledir = os.path.join(filedir, pathdir)
							filename = os.path.join(absFiledir, maybeFilename)
							tryFindFileAppendFile(fileList, filename)
							headTail = pathHeadTail(pathdir, "")
							if headTail:
								pathdir = headTail[0]
							else:
								pathdir = ""
		return fileList

	callbacks = {
		"pathType": pathType,
		"transEscape": transEscape,
		"normpath": normpath,
		"substring": substring,
		"pathHeadTail": pathHeadTail,
		"pathShortname": pathShortname,
		"pathJoin": pathJoin,
		"ripGrepEscape": ripGrepEscape,
		"ripGrepFilterType": ripGrepFilterType,
		"filterType": filterType,
		"fdFilterType": fdFilterType,
		"rootPath": rootPath,
		"searchFilename": searchFilename,
		"parseInputArgs": parseInputArgs,
		"tryFindFile": tryFindFile,
	}
	if query in callbacks.keys():
		return callbacks[query](data, extra)

rgtext = pythonQuery(pyquery, pydata, pyextra)
if isinstance(rgtext, str):
	rgtext = rgtext.replace("'", "''")
	vim.command("let rgtext = '%s'"%rgtext)
else:
	vim.command("let rgtext = %s"%rgtext)
EOM

    return rgtext
endfun

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 获取查找路径
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! GetGrepPath(path)
	if len(a:path) == 0
		return fnameescape(asclib#path#get_root('%'))
	endif
	let l:filepath = expand('%:p')
	if len(l:filepath) == 0
		return fnameescape(asclib#path#get_root('%'))
	endif
	let l:currentFilePath = expand('%:p:h')
	if asclib#path#exists(l:currentFilePath) == 0
		return fnameescape(asclib#path#get_root('%'))
	endif
	if a:path == 'current'
		return fnameescape(l:currentFilePath)
	elseif a:path == 'file'
		return fnameescape(expand('%:p'))
	elseif a:path == 'parent'
		let l:parentFilePath = expand('%:p:h:h')
		if asclib#path#exists(l:parentFilePath)
			return fnameescape(l:parentFilePath)
		endif
	endif
	return fnameescape(asclib#path#get_root('%'))
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 通过命令行参数得到过滤类型
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! GetFilterType(shortFilterType)
	if len(a:shortFilterType) == 0
		return ""
	endif
	let filterStr = ''
	if a:shortFilterType == 's'
		let filterStr = 'suf'
	elseif a:shortFilterType == 'o'
		let filterStr = 'opp'
	elseif a:shortFilterType == 'l'
		let filterStr = 'like'
	elseif a:shortFilterType == 'a'
		let filterStr = 'all'
	endif
	return filterStr
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" ripgrep过滤类型
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! RipGrepFilter(shortFilterType, filename)
	let filterStr = GetFilterType(a:shortFilterType)
	if len(filterStr) == 0
		return ""
	endif
	let rgFilter = PythonQuery("ripGrepFilterType", a:filename, filterStr)
	return rgFilter
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" fd过滤类型
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! FdFilter(shortFilterType, filename)
	let filterStr = GetFilterType(a:shortFilterType)
	if len(filterStr) == 0
		return ""
	endif
	let fdFilter = PythonQuery("fdFilterType", a:filename, filterStr)
	return fdFilter
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 根据缩短的文件名类型，获取文件名
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! GetPathType(shortPathType)
	let path = ''
	if a:shortPathType == 'f'
		let path = GetGrepPath("file")
	elseif a:shortPathType == 'c'
		let path = GetGrepPath("current")
	elseif a:shortPathType == 'p'
		let path = GetGrepPath("parent")
	elseif a:shortPathType == 'h'
		let path = GetGrepPath("home")
	endif
	return PythonQuery("normpath", path, "")
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 根据缩短的字符，获取打开方式
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! GetOpenFileType(shortType)
	let openTypeFile = ""
	if a:shortType == 't'
		let openTypeFile = 'tabe'
	elseif a:shortType == 'f'
		let openTypeFile = 'drop'
	elseif a:shortType == 's'
		let openTypeFile  = 'split'
	elseif a:shortType == 'v'
		let openTypeFile = 'vsplit'
	elseif a:shortType == 'p'
		let openTypeFile = 'pedit'
	elseif a:shortType == 'e'
		let openTypeFile = 'edit'
	elseif a:shortType == 'x'
		let openTypeFile = 'explorer'
	endif
	return openTypeFile
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" rg搜索的交互
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! RgSearchInterface(args, queryType)
	let q = a:queryType
	if len(q) == 0
		let q = input("Riggrep搜索 [bfcph][sola] data：")
	endif
	let argsList = PythonQuery("parseInputArgs", q, 3)
	if len(argsList[-1]) == 0
		let argsList[-1] = a:args
	endif
	if len(argsList[0]) == 0 || argsList[0] == 'b'
		return "/" . argsList[-1]
	endif
	let path = GetPathType(argsList[0])
	let query = shellescape(PythonQuery("ripGrepEscape", argsList[-1], ""))
	let filter = RipGrepFilter(argsList[1], GetGrepPath("file"))
	if len(path) > 0
		let path = shellescape(path)
	endif
	
	let rgCommand = join(['AsyncRun -cwd=$(VIM_FILEDIR)', 'rg', '--vimgrep', filter, '--', query, path], " ")
	return rgCommand
endfunction
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" grepwin搜索的交互
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! GrepWinSearchInterface(args, queryType)
	let q = a:queryType
	if len(q) == 0
		let q = input("grepwin搜索 [fcph] data：")
	endif
	let argsList = PythonQuery("parseInputArgs", q, 2)
	if len(argsList[-1]) == 0
		let argsList[-1] = a:args
	endif
	if len(argsList[0]) == 0
		let path = GetPathType("c")
	else
		let path = GetPathType(argsList[0])
	endif
	let query = shellescape(argsList[-1])
	if len(path) > 0
		let path = shellescape(path)
	endif
	
	let rgCommand = join(['!start', 'grepwin', '/searchpath:'.path, '/searchfor:'. query])
	execute rgCommand
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" fd搜索的交互
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! FdSearchInterface(args, queryType)
	let q = a:queryType
	if len(q) == 0
		let q = input("fd搜索 [cph][sola] data：")
	endif
	let argsList = PythonQuery("parseInputArgs", q, 3)
	if len(argsList[-1]) == 0
		let argsList[-1] = a:args
	endif
	let path = GetPathType(argsList[0])
	let query = argsList[-1]
	let filter = FdFilter(argsList[1], query)
	let pathType = PythonQuery("pathType", query, "")
	if pathType == "dir"
		let path = query
		let query = "."
	elseif pathType == "file"
		let headTail = PythonQuery("pathHeadTail", query, "")
		if len(headTail) == 2
			let path = headTail[0]
			let query = headTail[1]
		endif
	else
		let shortList = PythonQuery("pathShortname", query, "")
		if len(shortList) == 2
			let query = shortList[0]
			if len(filter) == 0
				if len(shortList[1]) > 0
					let query = join(shortList, ".")
				endif
			endif
		endif
	endif
	if len(path) > 0
		let path = shellescape(path)
	endif
	if len(query) > 0
		let query = shellescape(query)
	else
		let query = shellescape(".")
	endif
	let cmd = join(['AsyncRun -cwd=$(VIM_FILEDIR) -raw=1', "fd -a",
				\ filter, query, path], ' ')
	return cmd
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" asyncrun工具使用的交互
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! AsyncRunInterface(args)
	let n = input("输入: ")
	let rgCommand = join(['AsyncRun -cwd=$(VIM_FILEDIR)', n], " ")
	return rgCommand
endif
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 如果是文件则打开文件，如果是目录则打开导航到目录
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! OpenFileOrDir(args, openType)
	let pathType = PythonQuery("pathType", a:args, "")
	if a:openType == "explorer"
		let filepath = PythonQuery('normpath', a:args, "win")
		if pathType == 'file'
			let cmd = 'silent !start explorer /e,/select,' . shellescape(filepath)
			execute cmd
			return 1
		elseif pathType == 'dir'
			let cmd = 'silent !start explorer /e,/root,' . shellescape(filepath)
			execute cmd
			return 1
		endif
	endif
	if pathType == 'file'
		call Tools_FileSwitch(a:openType, a:args)
		return 1
	elseif pathType == 'dir'
		execute "LeaderfFile " . fnameescape(a:args)
		return 1
	endif
	return 0
endfunc

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 复制交互
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! CopyInterface(args, openType)
	let q = a:openType
	if len(q) == 0
		let q = input("复制[f|c|p|h|co(m)mand]：")
	endif
	let argsList = PythonQuery("parseInputArgs", q, 2)
	if len(argsList[0]) == 0
		let argsList[0] = 'f'
	endif
	if len(argsList[-1]) == 0
		let argsList[-1] = a:args
	endif
	let pathdir = GetPathType(argsList[0])
	if len(pathdir) > 0
		let filepath = PythonQuery("normpath", pathdir, "")
		let @+ = filepath
		echo "->复制成功->  " . filepath . ""
		return
	endif
	if argsList[0] == 'm'
		let @+ = @:
		let data = @+
		echo "->复制命令成功->  " . data . ""
	endif
endfunction
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"  使用fd查询Buffer所在文件去掉后缀的文件名。
"  比如在xx.cpp找xx.h文件有用。
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! FindOpenShortPath(name, shortFilterType, shortOpenType)
	if len(a:name) == 0
		return 0
	endif
	let extraPath = [GetGrepPath("current"), GetGrepPath("home"), GetGrepPath("parent")]
	let extraFilter = GetFilterType(a:shortFilterType)
	if len(extraFilter) == 0
		let extraFilter = 'suf'
	endif
	let extraDict = {}
	let extraDict["filter"] = extraFilter
	let extraDict["path"] = extraPath
	let fileList = PythonQuery("tryFindFile", a:name, extraDict)
	if len(fileList) > 0 && len(fileList[0]) > 0
		let openType = GetOpenFileType(a:shortOpenType)
		if len(openType) == 0
			let openType = "drop"
		endif
		exec openType . ' ' . fnameescape(fileList[0])
		return 1
	endif
	return 0
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 打开当前行或args中的全路径文件名
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! FindOpenFullpath(args, shortOpenType)
	if len(a:args) == 0
		return 0
	endif
	" 确定打开类型
	let openTypeFile = GetOpenFileType(a:shortOpenType)
	if len(openTypeFile) == 0
		let openTypeFile = "tabe"
	endif
	" 查看是否完整的路径名或文件名。如果是的话，直接跳到打开
	let fullname = PythonQuery("searchFilename", a:args, "first")
	if OpenFileOrDir(fullname, openTypeFile)
		return 1
	endif
	return 0
endfunction
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 文件交互
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! FileInterface(args, openType, tryFd)
	let q = a:openType
	if len(q) == 0
		let q = input("打开文件或路径 [tfsvpedx][hfcp][sola] data：")
	endif
	let argsList = PythonQuery("parseInputArgs", q, 4)
	if len(argsList[-1]) == 0
		let argsList[-1] = a:args
	endif
	if len(argsList[0]) == 0
		let argsList[0] = 't'
	endif
	if len(argsList[2]) == 0
		let argsList[2] = 's'
	endif
	if argsList[0] == 'x'
		if FindOpenFullpath(argsList[-1], argsList[0])
			return 1
		endif
		let pathdir = GetPathType(argsList[1])
		if len(pathdir) == 0
			let pathdir = GetPathType('f')
		endif
		if OpenFileOrDir(pathdir, "explorer")
			return 1
		endif
	endif
	if argsList[2] != 'o' 
		if FindOpenFullpath(argsList[-1], argsList[0])
			return 1
		endif
		if FindOpenFullpath(GetUnderWord(2), argsList[0])
			return 1
		endif
	endif
	if FindOpenShortPath(argsList[-1], argsList[2], argsList[0])
		return 1
	endif
	if FindOpenShortPath(GetUnderWord(2), argsList[2], argsList[0])
		return 1
	endif
	if a:tryFd == 1
		" 拼接不成功，又有不完整路径。则使用fd查找
		if len(argsList[1]) == 0
			let argsList[1] = 'h'
		endif
		let fdargs = join([argsList[1], argsList[2]], '')
		let cmd = FdSearchInterface(argsList[-1], fdargs)
		call feedkeys(':'.cmd)
		return 1
	endif
	return 0
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" cscope交互
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! CscopeInterface(args, queryType)
	let q = a:queryType
	if len(q) == 0
		let q = input("[f变量符号|v[函数符号|x查找函数被调用|zCtags查询|s全部符号|g定义|c函数被调用] data：")
	endif
	let argsList = PythonQuery("parseInputArgs", q, 2)
	if len(argsList[-1]) == 0
		let argsList[-1] = a:args
	endif
	let query = argsList[-1]
	let cmd = ""
	if argsList[0] == 'f'
		let cmd = join(["Leaderf gtags -s", query, "--all"], ' ')
	elseif argsList[0] == 'v'
		let cmd = join(["Leaderf gtags -d", query, "--all"], ' ')
	elseif argsList[0] == 'x'
		let cmd = join(["Leaderf gtags -r", query, "--all"], ' ')
	elseif argsList[0] == 'z' || argsList[0] == 's' || argsList[0] == 'g' || argsList[0] == 'c'
		let cmd = join(["GscopeFind", argsList[0], query], ' ')
	endif
	if len(cmd)
		execute cmd
		return
	endif
	let cmd = join([":GscopeFind", "z", argsList[-1]], " ")
	call feedkeys(cmd)
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" LeaderF交互
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! LeaderFInterface(args, queryType)
	let q = a:queryType
	if len(q) == 0
		let q = input("LeaderF [m最近文件|r上次结果|f文件|b缓存列表|h最近命令|p函数列表][cph] data：")
	endif
	let argsList = PythonQuery("parseInputArgs", q, 3)
	if len(argsList[-1]) == 0
		let argsList[-1] = a:args
	endif
	if argsList[0] == 'r'
		let cmd = join(["Leaderf", '--recall'], ' ')
		execute cmd
		return
	endif
	let inputstr = argsList[-1]
	if len(inputstr) > 0
		let inputstr = "--input " . shellescape(inputstr)
	endif
	if argsList[0] == 'f'
		let pathdir = GetPathType(argsList[1])
		if len(pathdir) == 0
			let pathdir = GetGrepPath("current")
		endif
		if len(pathdir) > 0
			let pathdir = shellescape(pathdir)
		endif
		let cmd = join(["Leaderf file", pathdir, inputstr], ' ')
		execute cmd
		return
	endif
	if argsList[0] == 'm'
		let cmd = join(["Leaderf mru", inputstr], ' ')
		execute cmd
		return
	endif
	if argsList[0] == 'b'
		let cmd = join(["Leaderf buffer", '--all', inputstr], ' ')
		execute cmd
		return
	endif
	if argsList[0] == 'h'
		let cmd = join(["Leaderf cmdHistory", inputstr], ' ')
		execute cmd
		return
	endif
	if argsList[0] == 'p'
		let cmd = join(["Leaderf function", inputstr], ' ')
		execute cmd
		return
	endif
	if FileInterface(argsList[-1], "dhs", 0) > 0
		return
	else
		let pathdir = GetPathType('c')
		let cmd = join([":Leaderf", "file", shellescape(pathdir), inputstr], " ")
		call feedkeys(cmd)
	endif
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"  翻译文档
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! TransInterface(args, openType)
    if a:openType == "1"
	    return "TranslateX"
    endif
    if a:openType == "2"
        let n = PythonQuery("transEscape", a:args, "")
	    let cmd = join(['Translate', n], " ")
	    return cmd
    endif
	let n = PythonQuery("transEscape", a:args, "")
	let cmd = join(['TranslateW', n], " ")
	return cmd
endfunction


"----------------------------------------------------------------------
" tab switching
"----------------------------------------------------------------------
let s:array = [')', '!', '@', '#', '$', '%', '^', '&', '*', '(']
for i in range(10)
	let x = (i == 0)? 10 : i
	let c = s:array[i]
	exec "noremap <silent><M-".i."> :tabn ".x."<cr>"
	exec "inoremap <silent><M-".i."> <ESC>:tabn ".x."<cr>"
	if get(g:, 'vim_no_meta_shift_num', 0) == 0
		exec "noremap <silent><M-".c."> :tabn ".x."<cr>"
		exec "inoremap <silent><M-".c."> <ESC>:tabn ".x."<cr>"
	endif
endfor

noremap <silent><m-t> :tabnew<cr>
inoremap <silent><m-t> <ESC>:tabnew<cr>
noremap <silent><m-w> :tabclose<cr>
inoremap <silent><m-w> <ESC>:tabclose<cr>
noremap <m-s> :w<cr>
inoremap <m-s> <esc>:w<cr>


"----------------------------------------------------------------------
" window 
"----------------------------------------------------------------------
noremap <silent><space>= :resize +3<cr>
noremap <silent><space>- :resize -3<cr>
noremap <silent><space>, :vertical resize -3<cr>
noremap <silent><space>. :vertical resize +3<cr>

noremap <silent><space>hh :nohl<cr>
noremap <silent><bs> :nohl<cr>:redraw!<cr>
noremap <silent><tab>, :call Tab_MoveLeft()<cr>
noremap <silent><tab>. :call Tab_MoveRight()<cr>
noremap <silent><tab>6 :VinegarOpen leftabove vs<cr>
noremap <silent><tab>7 :VinegarOpen vs<cr>
noremap <silent><tab>8 :VinegarOpen belowright sp<cr>
noremap <silent><tab>9 :VinegarOpen tabedit<cr>
noremap <silent><tab>0 :exe "NERDTree ".fnameescape(expand("%:p:h"))<cr>
noremap <silent><tab>y :exe "NERDTree ".fnameescape(asclib#path#get_root("%"))<cr>
noremap <silent><tab>g <c-w>p

noremap <silent><space>ha :GuiSignRemove
			\ errormarker_error errormarker_warning<cr>

" replace
noremap <space>p viw"0p
noremap <space>y yiw

" fast save
noremap <C-S> :w<cr>
inoremap <C-S> <ESC>:w<cr>

noremap <silent><m-t> :tabnew<cr>
inoremap <silent><m-t> <ESC>:tabnew<cr>
noremap <silent><m-w> :tabclose<cr>
inoremap <silent><m-w> <ESC>:tabclose<cr>
noremap <silent><m-v> :close<cr>
inoremap <silent><m-v> <esc>:close<cr>
noremap <m-s> :w<cr>
inoremap <m-s> <esc>:w<cr>


"----------------------------------------------------------------------
" tasks
"----------------------------------------------------------------------


"----------------------------------------------------------------------
" Movement Enhancement
"----------------------------------------------------------------------
noremap <M-h> b
noremap <M-l> w
noremap <M-j> gj
noremap <M-k> gk
inoremap <M-h> <c-left>
inoremap <M-l> <c-right>
inoremap <M-j> <c-\><c-o>gj
inoremap <M-k> <c-\><c-o>gk
inoremap <M-y> <c-\><c-o>d$
cnoremap <M-h> <c-left>
cnoremap <M-l> <c-right>
cnoremap <M-b> <c-left>
cnoremap <M-f> <c-right>


"----------------------------------------------------------------------
" fast window switching: ALT+SHIFT+HJKL
"----------------------------------------------------------------------
noremap <m-H> <c-w>h
noremap <m-L> <c-w>l
noremap <m-J> <c-w>j
noremap <m-K> <c-w>k
inoremap <m-H> <esc><c-w>h
inoremap <m-L> <esc><c-w>l
inoremap <m-J> <esc><c-w>j
inoremap <m-K> <esc><c-w>k

if has('terminal') && exists(':terminal') == 2 && has('patch-8.1.1')
	set termwinkey=<c-_>
	tnoremap <m-H> <c-_>h
	tnoremap <m-L> <c-_>l
	tnoremap <m-J> <c-_>j
	tnoremap <m-K> <c-_>k
	tnoremap <m-q> <c-\><c-n>
	tnoremap <m-1> <c-_>1gt
	tnoremap <m-2> <c-_>2gt
	tnoremap <m-3> <c-_>3gt
	tnoremap <m-4> <c-_>4gt
	tnoremap <m-5> <c-_>5gt
	tnoremap <m-6> <c-_>6gt
	tnoremap <m-7> <c-_>7gt
	tnoremap <m-8> <c-_>8gt
	tnoremap <m-9> <c-_>9gt
	tnoremap <m-0> <c-_>10gt
elseif has('nvim')
	tnoremap <m-H> <c-\><c-n><c-w>h
	tnoremap <m-L> <c-\><c-n><c-w>l
	tnoremap <m-J> <c-\><c-n><c-w>j
	tnoremap <m-K> <c-\><c-n><c-w>k
	tnoremap <m-q> <c-\><c-n>
	tnoremap <m-1> <c-\><c-n>1gt
	tnoremap <m-2> <c-\><c-n>2gt
	tnoremap <m-3> <c-\><c-n>3gt
	tnoremap <m-4> <c-\><c-n>4gt
	tnoremap <m-5> <c-\><c-n>5gt
	tnoremap <m-6> <c-\><c-n>6gt
	tnoremap <m-7> <c-\><c-n>7gt
	tnoremap <m-8> <c-\><c-n>8gt
	tnoremap <m-9> <c-\><c-n>9gt
	tnoremap <m-0> <c-\><c-n>10gt
endif

"----------------------------------------------------------------------
" neovim system clipboard
"----------------------------------------------------------------------
if has('nvim')
	nnoremap <s-insert> "*P
	vnoremap <s-insert> "-d"*P
	inoremap <s-insert> <c-r><c-o>*
	vnoremap <c-insert> "*y
	cnoremap <s-insert> <c-r>*
endif

"----------------------------------------------------------------------
" F5 运行当前文件：根据文件类型判断方法，并且输出到 quickfix 窗口
"----------------------------------------------------------------------
function! ExecuteFile()
	let cmd = ''
	if index(['c', 'cpp', 'rs', 'go'], &ft) >= 0
		" native 语言，把当前文件名去掉扩展名后作为可执行运行
		" 写全路径名是因为后面 -cwd=? 会改变运行时的当前路径，所以写全路径
		" 加双引号是为了避免路径中包含空格
		let cmd = '"$(VIM_FILEDIR)/$(VIM_FILENOEXT)"'
	elseif &ft == 'python'
		let $PYTHONUNBUFFERED=1 " 关闭 python 缓存，实时看到输出
		let cmd = 'python "$(VIM_FILEPATH)"'
	elseif &ft == 'javascript'
		let cmd = 'node "$(VIM_FILEPATH)"'
	elseif &ft == 'perl'
		let cmd = 'perl "$(VIM_FILEPATH)"'
	elseif &ft == 'ruby'
		let cmd = 'ruby "$(VIM_FILEPATH)"'
	elseif &ft == 'php'
		let cmd = 'php "$(VIM_FILEPATH)"'
	elseif &ft == 'lua'
		let cmd = 'lua "$(VIM_FILEPATH)"'
	elseif &ft == 'zsh'
		let cmd = 'zsh "$(VIM_FILEPATH)"'
	elseif &ft == 'ps1'
		let cmd = 'powershell -file "$(VIM_FILEPATH)"'
	elseif &ft == 'vbs'
		let cmd = 'cscript -nologo "$(VIM_FILEPATH)"'
	elseif &ft == 'sh'
		let cmd = 'bash "$(VIM_FILEPATH)"'
	else
		return
	endif
	" Windows 下打开新的窗口 (-mode=4) 运行程序，其他系统在 quickfix 运行
	" -raw: 输出内容直接显示到 quickfix window 不匹配 errorformat
	" -save=2: 保存所有改动过的文件
	" -cwd=$(VIM_FILEDIR): 运行初始化目录为文件所在目录
	if has('win32') || has('win64')
		exec 'AsyncRun -cwd=$(VIM_FILEDIR) -raw -save=2 -mode=4 '. cmd
	else
		exec 'AsyncRun -cwd=$(VIM_FILEDIR) -raw -save=2 -mode=0 '. cmd
	endif
endfunc

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"  复制命令到剪贴板
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! CopyCommand()
	let @+ = @:
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"  复制全部消息到剪贴板
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! CopyMessage()
	redir => s:messages
	:messages
	redir END
	let @+ = s:messages
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"  复制查找路径到剪贴板
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! CopyFilepath(path)
	let filepath = GetGrepPath(a:path)
	let filepath = PythonQuery("normpath", filepath, "")
	let @+ = filepath
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"  自动换行和取消换行。
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! TrigerWrap()
	let l:iswrap = &wrap
	if l:iswrap
		set nowrap
		echo "nowrap"
	else
		set wrap
		echo "wrap"
	endif
endfunction

" ----------------------------------------------------------------------
"  自动打开 quickfix window ，高度为 12
let g:asyncrun_open = 8
"  任务结束时候响铃提醒
let g:asyncrun_bell = 0

" ----------------------------------------------------------------------
"  F1 调用rg搜索文件内容
" ----------------------------------------------------------------------
" 使用内置搜索
noremap <F1> :<C-U><C-R>=printf(RgSearchInterface(GetUnderWord(0), ''))<CR>
vnoremap <F1> :<C-U><C-R>=printf(RgSearchInterface(GetUnderWord(1), ''))<CR>
" 使用ripgrep搜索当前文件内容
noremap <space><F1> :<C-U><C-R>=printf(RgSearchInterface(GetUnderWord(0), 'f'))<CR>
vnoremap <space><F1> :<C-U><C-R>=printf(RgSearchInterface(GetUnderWord(1), 'f'))<CR>
" 使用grepwin搜索当前指针下的文字，搜索路径为当前打开的文件路径
noremap <M-F1> :call GrepWinSearchInterface(GetUnderWord(0), 'c')<CR><CR>
vnoremap <M-F1> :call GrepWinSearchInterface(GetUnderWord(1), 'c')<CR><CR>


" ----------------------------------------------------------------------
"  F2 LeaderF
" ----------------------------------------------------------------------
noremap <F2> :call LeaderFInterface(GetUnderWord(0), '')<CR>
vnoremap <F2> :call LeaderFInterface(GetUnderWord(1), '')<CR>
" 搜索历史打开文件
noremap <M-F2> :call LeaderFInterface('', 'm')<CR>
vnoremap <M-F2> :call LeaderFInterface('', 'm')<CR>
" 上次搜索结果
noremap <space><F2> :call LeaderFInterface("", 'r')<CR>
vnoremap <space><F2> :call LeaderFInterface("", 'r')<CR>

" ----------------------------------------------------------------------
"  F3 文件功能
" ----------------------------------------------------------------------
" 新标签打开
noremap <F3> :call FileInterface('', '', 1)<CR>
vnoremap <F3> :call FileInterface(GetUnderWord(1), '', 1)<CR>
noremap <m-f3> :<C-U><C-R>=printf(FdSearchInterface('', ''))<CR>
vnoremap <m-f3> :<C-U><C-R>=printf(FdSearchInterface(GetUnderWord(1), ''))<CR>

" ----------------------------------------------------------------------
"  F4 复制功能
" ----------------------------------------------------------------------
noremap <F4> :call CopyInterface('', '')<CR>
vnoremap <F4> :call CopyInterface('', '')<CR>

" ----------------------------------------------------------------------
"  F5 运行当前文件：根据文件类型判断方法，并且输出到 quickfix 窗口
" ----------------------------------------------------------------------
noremap <F5> :call ExecuteFile()<CR>

" ----------------------------------------------------------------------
"  F6 调用AsyncRun命令
" ----------------------------------------------------------------------
noremap <F6> :<C-U><C-R>=printf(AsyncRunInterface(GetUnderWord(0)))<CR>
vnoremap <F6> :<C-U><C-R>=printf(AsyncRunInterface(GetUnderWord(1)))<CR>
" ----------------------------------------------------------------------
"  F7
" ----------------------------------------------------------------------


" ----------------------------------------------------------------------
"  F8 cscope
" ----------------------------------------------------------------------
noremap <F8> :call CscopeInterface(GetUnderWord(0), '')<CR>
vnoremap <F8> :call CscopeInterface(GetUnderWord(1), '')<CR>

" ----------------------------------------------------------------------
"  F9 翻译交互
" ----------------------------------------------------------------------
noremap <F9> :<C-U><C-R>=printf(TransInterface(GetUnderWord(0), 0))<CR><CR>
vnoremap <F9> :<C-U><C-R>=printf(TransInterface(GetUnderWord(1), 0))<CR><CR>
noremap <c-F9> :<C-U><C-R>=printf(TransInterface(GetUnderWord(0), 2))<CR>
vnoremap <c-F9> :<C-U><C-R>=printf(TransInterface(GetUnderWord(1), 2))<CR>
noremap <space><F9> :<C-U><C-R>=printf(TransInterface("", 1))<CR>
vnoremap <space><F9> :<C-U><C-R>=printf(TransInterface("", 1))<CR>

" ----------------------------------------------------------------------
"  F10 目录菜单
" ----------------------------------------------------------------------
noremap <F10> :exec "NvimTreeToggle"<cr>
noremap <space><F10> :exec "UndotreeToggle"<cr>
" ----------------------------------------------------------------------
"  F11 打开/关闭 Quickfix 窗口
" ----------------------------------------------------------------------
nnoremap <F11> :call asyncrun#quickfix_toggle(g:asyncrun_open)<cr>

" ----------------------------------------------------------------------
"  F12 菜单栏
" ----------------------------------------------------------------------
nnoremap <silent><F12> :call quickui#menu#open()<cr>
inoremap <silent><F12> <ESC>:call quickui#menu#open()<cr>

" ----------------------------------------------------------------------
"  ALT命令
" ----------------------------------------------------------------------
" 使用 ALT+E 来选择窗口
nmap <m-e> <Plug>(choosewin)

" 与leaderf的快捷键一致
" 当前标签打开文件
noremap <m-p> :call FileInterface(GetUnderWord(2), "ph", 1)<CR>
vnoremap <m-p> :call FileInterface(GetUnderWord(1), "ph", 1)<CR>
" 新标签打开文件
noremap <m-t> :call FileInterface(GetUnderWord(2), "th", 1)<CR>
vnoremap <m-t> :call FileInterface(GetUnderWord(1), "th", 1)<CR>
" 上下打开文件
noremap <m-x> :call FileInterface(GetUnderWord(2), "sh", 1)<CR>
vnoremap <m-x> :call FileInterface(GetUnderWord(1), "sh", 1)<CR>
" 左右打开文件
noremap <m-]> :call FileInterface(GetUnderWord(2), "vh", 1)<CR>
vnoremap <m-]> :call FileInterface(GetUnderWord(1), "vh", 1)<CR>
" 当前窗口打开文件
noremap <m-f> :call FileInterface(GetUnderWord(2), "dh", 1)<CR>
vnoremap <m-f> :call FileInterface(GetUnderWord(1), "dh", 1)<CR>
" 查找与当前文件名相匹配的文件
noremap <m-o> :call FileInterface(GetGrepPath('file'), 'dho', 1)<CR>
vnoremap <m-o> :call FileInterface(GetUnderWord(1), 'dho', 1)<CR>

" ----------------------------------------------------------------------
"  空格命令
" ----------------------------------------------------------------------
" 按两下空格，只保存当前窗口
noremap <space><space> :<C-U><C-R>=printf("only")<CR><CR>
"  空格+/ 取消搜索高亮显示。
" EasyMothion 把默认的\\都简化为空格命令。
map <space>f <Plug>(easymotion-f)
map <space>j <Plug>(easymotion-j)
map <space>k <Plug>(easymotion-k)

" ----------------------------------------------------------------------
" Control 命令
" ----------------------------------------------------------------------
" 使用control-tab，把buffer列表打开
noremap <c-tab> :execute "ToggleBufExplorer"<cr>
nnoremap <silent> <leader><space>bf :BufExplorer<CR>
nnoremap <silent> <leader><space>bh :BufExplorerHorizontalSplit<CR>
nnoremap <silent> <leader><space>bv :BufExplorerVerticalSplit<CR>
