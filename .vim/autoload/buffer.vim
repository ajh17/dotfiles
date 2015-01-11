" Opens the buffer in the arrangement specified.
function! buffer#switchBySplitting(arrangement)
  let moreThanOneBuffer = len(filter(map(range(bufnr('$')), 'buflisted(v:val)'), 'v:val == 1')) > 1
  if a:arrangement ==? "horizontally"
    return moreThanOneBuffer ? ":buffer \<C-z>\<S-Tab>" : ":buffer "
  elseif a:arrangement ==? "vertically"
    return moreThanOneBuffer ? ":vertical sbuffer \<C-z>\<S-Tab>" : ":vertical sbuffer "
  endif
endfunction

" Get the names of buffers as a string separated by a space.
function! buffer#list()
  let buflist = []
  for i in range(1, bufnr('$'))
    if bufexists(i)
      let buflist += [bufname(i)]
    endif
  endfor
  return join(map(buflist, 'escape(v:val, " ")'), ' ')
endfunction

" Opens the buffer with the specified arrangement. For buffer#alternate()
function! s:buffer_open(filename, arrangement)
  let edit_command = "edit "
  if a:arrangement ==? "v"
    let edit_command = "vsplit "
  elseif a:arrangement ==? "s"
    let edit_command = "split "
  endif

  if filereadable(a:filename) || bufexists(a:filename)
    execute bufwinnr(a:filename) == -1 ? edit_command . a:filename : "sbuffer " . a:filename
    return 1
  endif
  return 0
endfunction

" A dead simple header/source alternator.
" Without installing a 400+ plugin or having to write some stupid json file.
function! buffer#alternate(arrangement)
  let file_name = expand("%:t:r")
  let extension = expand("%:t:e")

  let source_list = ["cpp", "c", "cc", "cxx"]
  let header_list = ["h", "hpp", "hh", "hxx"]
  let is_source = index(source_list, extension) >= 0
  let is_header = index(header_list, extension) >= 0

  if is_source
    for header in header_list
      let success = s:buffer_open(file_name . "." . header, a:arrangement)
      if success
        return
      endif
    endfor
    echohl ErrorMsg | echo "Header file not found in path!" | echohl None
  elseif is_header
    for l:source in source_list
      let success = s:buffer_open(file_name . "." . l:source, a:arrangement)
      if success
        return
      endif
    endfor
    echohl ErrorMsg | echo "Source file not found in path!" | echohl None
  endif
endfunction