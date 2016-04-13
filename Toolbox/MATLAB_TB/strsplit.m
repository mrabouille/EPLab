function [c, matches] = strsplit(str, aDelim, varargin)
%STRSPLIT  Split string at delimiter
%   C = STRSPLIT(S) splits the string S at whitespace into the cell array
%   of strings C.
%
%   C = STRSPLIT(S, DELIMITER) splits S at DELIMITER into C. DELIMITER can
%   be a string or a cell array of strings. If DELIMITER is a cell array of
%   strings, STRSPLIT splits S along the elements in DELIMITER, in the
%   order in which they appear in the cell array.
%
%   C = STRSPLIT(S, DELIMITER, PARAM1, VALUE1, ... PARAMN, VALUEN) modifies
%   the way in which S is split at DELIMITER.
%   Valid parameters are:
%     'CollapseDelimiters' - If true (default), consecutive delimiters in S
%       are treated as one. If false, consecutive delimiters are treated as
%       separate delimiters, resulting in empty string '' elements between
%       matched delimiters.
%     'DelimiterType' - DelimiterType can have the following values:
%       'Simple' (default) - Except for escape sequences, STRSPLIT treats
%         DELIMITER as a literal string.
%       'RegularExpression' - STRSPLIT treats DELIMITER as a regular
%         expression.
%       In both cases, DELIMITER can include the following escape
%       sequences:
%           \\   Backslash
%           \0   Null
%           \a   Alarm
%           \b   Backspace
%           \f   Form feed
%           \n   New line
%           \r   Carriage return
%           \t   Horizontal tab
%           \v   Vertical tab
%
%   [C, MATCHES] = STRSPLIT(...) also returns the cell array of strings
%   MATCHES containing the DELIMITERs upon which S was split. Note that
%   MATCHES always contains one fewer element than C.
%
%   Examples:
%
%       str = 'The rain in Spain stays mainly in the plain.';
%
%       % Split on all whitespace.
%       strsplit(str)
%       % {'The', 'rain', 'in', 'Spain', 'stays',
%       %  'mainly', 'in', 'the', 'plain.'}
%
%       % Split on 'ain'.
%       strsplit(str, 'ain')
%       % {'The r', ' in Sp', ' stays m', 'ly in the pl', '.'}
%
%       % Split on ' ' and on 'ain' (treating multiple delimiters as one).
%       strsplit(str, {' ', 'ain'})
%       % ('The', 'r', 'in', 'Sp', 'stays',
%       %  'm', 'ly', 'in', 'the', 'pl', '.'}
%
%       % Split on all whitespace and on 'ain', and treat multiple
%       % delimiters separately.
%       strsplit(str, {'\s', 'ain'}, 'CollapseDelimiters', false, ...
%                     'DelimiterType', 'RegularExpression')
%       % {'The', 'r', '', 'in', 'Sp', '', 'stays',
%       %  'm', 'ly', 'in', 'the', 'pl', '.'}
%
%   See also REGEXP, STRFIND, STRJOIN.

%   Copyright 2012 The MathWorks, Inc.

narginchk(1, Inf);

% Initialize default values.
collapseDelimiters = true;
delimiterType = 'Simple';

% Check input arguments.
if nargin < 2
    delimiterType = 'RegularExpression';
    aDelim = '\s';
end
if ~isString(str)
    error(message('MATLAB:strsplit:InvalidStringType'));
end
if isString(aDelim)
    aDelim = {aDelim};
elseif ~isCellString(aDelim)
    error(message('MATLAB:strsplit:InvalidDelimiterType'));
end
if nargin > 2
    funcName = mfilename;
    p = inputParser;
    p.FunctionName = funcName;
    p.addParamValue('CollapseDelimiters', collapseDelimiters);
    p.addParamValue('DelimiterType', delimiterType);
    p.parse(varargin{:});
    collapseDelimiters = verifyScalarLogical(p.Results.CollapseDelimiters, ...
        funcName, 'CollapseDelimiters');
    delimiterType = validatestring(p.Results.DelimiterType, ...
        {'RegularExpression', 'Simple'}, funcName, 'DelimiterType');
end

% Handle DelimiterType.
if strcmp(delimiterType, 'Simple')
    % Handle escape sequences and translate.
    aDelim = strescape(aDelim);
    aDelim = regexptranslate('escape', aDelim);
else
    % Check delimiter for regexp warnings.
    regexp('', aDelim, 'warnings');
end

% Handle multiple delimiters.
aDelim = strjoin(aDelim, '|');

% Handle CollapseDelimiters.
if collapseDelimiters
    aDelim = ['(?:', aDelim, ')+'];
end

% Split.
[c, matches] = regexp(str, aDelim, 'split', 'match');

end
%--------------------------------------------------------------------------
function tf = verifyScalarLogical(tf, funcName, parameterName)

if isscalar(tf) && isnumeric(tf) && any(tf == [0, 1])
    tf = logical(tf);
else
    validateattributes(tf, {'logical'}, {'scalar'}, funcName, parameterName);
end

end



function tf = isCellString(x)
%ISCELLSTRING  True for a cell array of strings.
%   ISSTRING(C) returns true if C is a cell array containing only row
%   character arrays and false otherwise.
%
%   See also ISSTRING.

%   Copyright 2012 The MathWorks, Inc.

tf = iscell(x) && ( isrow(x) || isequal(x, {}) ) && ...
     all(cellfun(@isString, x));

end


function tf = isString(x)
%ISSTRING  True for a character string.
%   ISSTRING(S) returns true if S is a row character array and false
%   otherwise.
%
%   See also ISCELLSTRING.

%   Copyright 2012 The MathWorks, Inc.

tf = ischar(x) && ( isrow(x) || isequal(x, '') );

end



function escapedStr = strescape(str)
%STRESCAPE  Escape control character sequences in a string.
%   STRESCAPE(STR) converts the escape sequences in a string to the values
%   they represent.
%
%   Example:
%
%       strescape('Hello World\n')
%
%   See also SPRINTF.

%   Copyright 2012 The MathWorks, Inc.

escapeFcn = @escapeChar;                                        %#ok<NASGU>
escapedStr = regexprep(str, '\\(.|$)', '${escapeFcn($1)}');

function c = escapeChar(c)
    switch c
    case '0'  % Null.
        c = char(0);
    case 'a'  % Alarm.
        c = char(7);
    case 'b'  % Backspace.
        c = char(8);
    case 'f'  % Form feed.
        c = char(12);
    case 'n'  % New line.
        c = char(10);
    case 'r'  % Carriage return.
        c = char(13);
    case 't'  % Horizontal tab.
        c = char(9);
    case 'v'  % Vertical tab.
        c = char(11);
    case '\'  % Backslash.
    case ''   % Unescaped trailing backslash.
        c = '\';
    otherwise
        warning(message('MATLAB:strescape:InvalidEscapeSequence', c, c));
    end
end
end


