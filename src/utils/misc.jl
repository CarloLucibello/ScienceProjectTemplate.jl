
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

function DrWatson.dict_list(od::OrderedDict)
    d = Dict(od)
    dlist = dict_list(d)
    return [OrderedDict((k => d[k] for k in keys(od))...) for d in dlist]
end

