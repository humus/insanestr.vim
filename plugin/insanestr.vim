let s:expr = '\v"\zs([^"])@=([^"\\]|(\\\\)+|\\[utn"])+\ze"'
fun! Insane_unescape_str() "{{{
  let a_line = getline(line('.'))
  let escaped_str = matchstr(a_line, s:expr)
  if escaped_str == ""
    return
  endif
  let unescaped_str = substitute(escaped_str, '\v\\(")@=', '', 'g')
  let unescaped_str = substitute(unescaped_str, '\v\\\\', '\\', 'g')
  call setline(line('.'), a_line . ' //	' . unescaped_str)
  let pos = getpos('.')
  call setpos('.', [pos[0], pos[1], len(getline(pos[1])), 0])
endfunction "}}}

fun! Insane_reescape_str()
  let a_line = getline(line('.'))

  "Using replace from getline('.') could cause undesirable effects
  "using match and matchend with slicing seems to be a better approach

  let first_index = match(a_line, s:expr) - 1
  let last_index = matchend(a_line, s:expr)
  let before_replacement = a_line[ : first_index]
  let after_replacement = a_line[last_index : ]
  let raw_str = matchstr(getline(line('.')), '\v//	\zs.{-}$')
  let escaped_str = Insane_escape_str(raw_str)
  let escaped_line = before_replacement . escaped_str . after_replacement
  let escaped_line = substitute(escaped_line, '\v\s//.{-}$', '', '')
  call setline(line('.'), escaped_line)
endfunction

fun! Insane_escape_str(raw_str) "{{{
  let raw_str = substitute(a:raw_str, '\v\\(["tnu])@!', '\\\\', 'g')
  return substitute(raw_str, '\v"', '\\&', 'g')
endfunction "}}}

command! Insaneunescape call Insane_unescape_str()
command! Insanereescape call Insane_reescape_str()
