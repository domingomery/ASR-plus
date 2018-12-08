function x = asr_defvalue(options,str_field,val)

if ~isfield(options,str_field) % border not considered
    x = val;
else
    x = getfield(options,str_field);
end
