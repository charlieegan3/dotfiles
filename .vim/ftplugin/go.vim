let g:go_fmt_command = "goimports"
let g:go_fmt_autosave = 1
let g:go_metalinter_autosave = 1
let g:go_doc_keywordprg_enabled = "0"

setlocal colorcolumn=0
setlocal noexpandtab tabstop=4 shiftwidth=4 softtabstop=4

set nolist
nnoremap tt :! clear; go test<cr>
nnoremap tr :GoAlternate<cr>
inoremap <tab> <C-x><C-o>