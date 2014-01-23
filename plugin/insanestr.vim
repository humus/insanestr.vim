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
endfunction "}}}

fun! Insane_reescape_str()
  let a_line = getline(line('.'))

  "Using replace from getline could create undesirable effects
  "for now using match and matchend with slicing represents a
  "better approach

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
  let raw_str = substitute(a:raw_str, '\v\\(["u])@!', '\\\\', 'g')
  return substitute(raw_str, '\v"', '\\&', 'g')
endfunction "}}}
