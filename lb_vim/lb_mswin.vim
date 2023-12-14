" Bail out if this isn't wanted.
if exists("g:skip_loading_mswin") && g:skip_loading_mswin
  finish
endif

" set the 'cpoptions' to its Vim default
if 1	" only do this when compiled with expression evaluation
  let s:save_cpo = &cpoptions
endif
set cpo&vim


if has("clipboard")
    vnoremap <C-Insert> "+y
    map <S-Insert> "+gP
    cmap <S-Insert> <C-R>+
endif

map  <S-Insert> "+gP
exe 'inoremap <script> <S-Insert> <C-G>u' . paste#paste_cmd['i']
exe 'vnoremap <script>  <S-Insert> ' . paste#paste_cmd['v']

" restore 'cpoptions'
set cpo&
if 1
  let &cpoptions = s:save_cpo
  unlet s:save_cpo
endif
