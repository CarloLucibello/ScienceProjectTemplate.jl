
"""
Check if a file with the name exists, if so, append a number to the name.
"""
function check_filename(filename)
    mkpath(dirname(filename))
    i = 1
    _filename = filename
    while isfile(_filename)
        i += 1
        _filename = filename * "." * string(i)
    end
    filename = _filename
    return filename
end

function cartesian_list(; kws...)
    dlist = dict_list(Dict(kws...))
    return [(; (k => d[k] for (k,_) in kws)...) for d in dlist]
end

function Base.merge(s::OrderedDict, nt::NamedTuple)
    snew = deepcopy(s)
    for (k, v) in pairs(nt)
        snew[k] = v 
    end
    return snew
end
