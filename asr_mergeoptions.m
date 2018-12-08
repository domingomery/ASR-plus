% FASR: Face Recognition by Adaptive Sparse Representations
% =========================================================
%
% asr_loadoptions.m : load default options (opdef) into options of the
% experiments (options) and update them with new options (op).
%
% Example:
%
% opdef =          op =              options =
%
%    var1: 2            var1: 1                 var1: 1
%    var2: 22           var2: 11                var2: 11
%    var3: 222          var5: 11111             var3: 222
%    var4: 2222                                 var4: 2222
%                                               var5: 11111
% (c) Domingo Mery - PUC (2013), ND (2014)



function options = asr_mergeoptions(op,opdef)

options = opdef;


if ~isempty(op)
    x=fieldnames(op);
    
    for i=1:length(x)
        st = [ 'options.' x{i} ' = op.' x{i} ';'];
        eval(st);
    end
end