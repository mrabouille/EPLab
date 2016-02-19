function Non_Intrusive_PCE_disabled()
warning('off','MATLAB:oldPfileVersion')

evalin('caller', 'Non_Intrusive_PCE()' ); 
end

function clc()
end
    
function varargout=disp(varargin)
end 

function varargout=fprintf(varargin)
end