augroup skkeleton
  autocmd!
  autocmd User skkeleton :
augroup END

function! s:doautocmd() abort
  doautocmd <nomodeline> User skkeleton
endfunction

function! skkeleton#doautocmd() abort
  call timer_start(1, {id->s:doautocmd()})
  return ""
endfunction

" copied from eskk.vim
function! skkeleton#get_default_mapped_keys() abort "{{{
    return split(
                \   'abcdefghijklmnopqrstuvwxyz'
                \  .'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
                \  .'1234567890'
                \  .'!"#$%&''()'
                \  .',./;:]@[-^\'
                \  .'>?_+*}`{=~'
                \   ,
                \   '\zs'
                \) + [
                \   '<lt>',
                \   '<Bar>',
                \   '<Tab>',
                \   '<BS>',
                \   '<C-h>',
                \   '<CR>',
                \   '<Space>',
                \   '<C-q>',
                \   '<C-y>',
                \   '<C-e>',
                \   '<PageUp>',
                \   '<PageDown>',
                \   '<Up>',
                \   '<Down>',
                \   '<C-n>',
                \   '<C-p>',
                \   '<C-j>',
                \   '<C-g>',
                \   '<Esc>',
                \]
endfunction "}}}

function! skkeleton#map() abort
  for c in skkeleton#get_default_mapped_keys()
    execute printf('lnoremap <buffer> <expr> %s denops#request("skkeleton", "handleKey", ["%s"]) .. skkeleton#doautocmd()', c, c)
  endfor
endfunction

function! skkeleton#unmap() abort
  for c in skkeleton#get_default_mapped_keys()
    execute printf('lunmap <buffer> %s', c)
  endfor
endfunction

function! skkeleton#get_key_notations() abort
  let keys = {}
  let keys["<nul>"] = "\<nul>"
  let keys["<bs>"] = "\<bs>"
  let keys["<tab>"] = "\<tab>"
  let keys["<nl>"] = "\<nl>"
  let keys["<ff>"] = "\<ff>"
  let keys["<cr>"] = "\<cr>"
  let keys["<return>"] = "\<return>"
  let keys["<enter>"] = "\<enter>"
  let keys["<esc>"] = "\<esc>"
  let keys["<space>"] = "\<space>"
  let keys["<lt>"] = "\<lt>"
  let keys["<bslash>"] = "\<bslash>"
  let keys["<bar>"] = "\<bar>"
  let keys["<del>"] = "\<del>"
  let keys["<csi>"] = "\<csi>"
  let keys["<xcsi>"] = "\<xcsi>"
  let keys["<eol>"] = "\<eol>"
  let keys["<ignore>"] = "\<ignore>"
  let keys["<nop>"] = "\<nop>"
  let keys["<up>"] = "\<up>"
  let keys["<down>"] = "\<down>"
  let keys["<left>"] = "\<left>"
  let keys["<right>"] = "\<right>"
  let keys["<s-up>"] = "\<s-up>"
  let keys["<s-down>"] = "\<s-down>"
  let keys["<s-left>"] = "\<s-left>"
  let keys["<s-right>"] = "\<s-right>"
  let keys["<c-left>"] = "\<c-left>"
  let keys["<c-right>"] = "\<c-right>"
  let keys["<help>"] = "\<help>"
  let keys["<undo>"] = "\<undo>"
  let keys["<insert>"] = "\<insert>"
  let keys["<home>"] = "\<home>"
  let keys["<end>"] = "\<end>"
  let keys["<pageup>"] = "\<pageup>"
  let keys["<pagedown>"] = "\<pagedown>"
  let keys["<kup>"] = "\<kup>"
  let keys["<kdown>"] = "\<kdown>"
  let keys["<kleft>"] = "\<kleft>"
  let keys["<kright>"] = "\<kright>"
  let keys["<khome>"] = "\<khome>"
  let keys["<kend>"] = "\<kend>"
  let keys["<korigin>"] = "\<korigin>"
  let keys["<kpageup>"] = "\<kpageup>"
  let keys["<kpagedown>"] = "\<kpagedown>"
  let keys["<kdel>"] = "\<kdel>"
  let keys["<kplus>"] = "\<kplus>"
  let keys["<kminus>"] = "\<kminus>"
  let keys["<kmultiply>"] = "\<kmultiply>"
  let keys["<kdivide>"] = "\<kdivide>"
  let keys["<kpoint>"] = "\<kpoint>"
  let keys["<kcomma>"] = "\<kcomma>"
  let keys["<kequal>"] = "\<kequal>"
  let keys["<kenter>"] = "\<kenter>"
  for i in range(1, 12)
    execute printf('let keys["<f%s>"] = "\<f%s>"', i, i)
    execute printf('let keys["<s-f%s>"] = "\<s-f%s>"', i, i)
  endfor
  for i in range(0, 9)
    execute printf('let keys["<k%s>"] = "\<k%s>"', i, i)
  endfor
  for i in range(26)
    let c = nr2char(i + 97)
    execute printf('let keys["<s-%s>"] = "\<s-%s>"', c, c)
    execute printf('let keys["<c-%s>"] = "\<c-%s>"', c, c)
    execute printf('let keys["<m-%s>"] = "\<m-%s>"', c, c)
    execute printf('let keys["<a-%s>"] = "\<a-%s>"', c, c)
    execute printf('let keys["<d-%s>"] = "\<d-%s>"', c, c)
  endfor
  return keys
endfunction

let s:windows = []

function! s:popup(candidates) abort
  if has('nvim')
    let buf = nvim_create_buf(v:false, v:true)
    call nvim_buf_set_lines(buf, 0, -1, v:true, a:candidates)
    let opts = {
          \ 'relative': 'cursor',
          \ 'width': max(map(copy(a:candidates), 'strwidth(v:val)')),
          \ 'height': len(a:candidates),
          \ 'col': 0,
          \ 'row': 1,
          \ 'anchor': 'NW',
          \ 'style': 'minimal'
          \ }
    let win = nvim_open_win(buf, 0, opts)
    call add(s:windows, win)
  else
    let id = popup_create(a:candidates, {
          \ "pos": 'topleft',
          \ "line": 'cursor+1',
          \ "col": 'cursor',
          \ })
    call add(s:windows, id)
  endif
  autocmd User skkeleton ++once call s:close()
endfunction

function s:close()
  if has('nvim')
    for i in s:windows
      call nvim_win_close(i, v:true)
    endfor
  else
    for i in s:windows
      call popup_close(i)
    endfor
  endif
  let s:windows = []
endfunction

function! skkeleton#show_candidates(candidates) abort
  let s:candidates = a:candidates
  autocmd User skkeleton ++once call s:popup(s:candidates)
endfunction

function! skkeleton#close_candidates() abort
  autocmd User skkeleton ++once call s:close()
endfunction

function! skkeleton#getchar(msg) abort
  echo a:msg
  return getchar()
endfunction