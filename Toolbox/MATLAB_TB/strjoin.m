function joinedStr = strjoin(c, aDelim)
%SAME AS R2014 JUST FOR BACKWARD COMPATIBILITY OF MATLAB OLDER THAN R2013a !!!!
%STRJOIN  Join cell array of strings into single string
%   S = STRJOIN(C) constructs the string S by linking each string within
%   cell array of strings C together with a space.
%
%   S = STRJOIN(C, DELIMITER) constructs S by linking each element of C
%   with the elements of DELIMITER. DELIMITER can be either a string or a
%   cell array of strings having one fewer element than C.
%
%   If DELIMITER is a string, then STRJOIN forms S by inserting DELIMITER
%   between each element of C. DELIMITER can include any of these escape
%   sequences:
%       \\   Backslash
%       \0   Null
%       \a   Alarm
%       \b   Backspace
%       \f   Form feed
%       \n   New line
%       \r   Carriage return
%       \t   Horizontal tab
%       \v   Vertical tab
%
%   If DELIMITER is a cell array of strings, then STRJOIN forms S by
%   interleaving the elements of DELIMITER and C. In this case, all
%   characters in DELIMITER are inserted as literal text, and escape
%   characters are not supported.
%
%   Examples:
%
%       c = {'one', 'two', 'three'};
%
%       % Join with space.
%       strjoin(c)
%       % 'one two three'
%
%       % Join as a comma separated list.
%       strjoin(c, ', ')
%       % 'one, two, three'
%
%       % Join with a cell array of strings DELIMITER.
%       strjoin(c, {' + ', ' = '})
%       % 'one + two = three'
%
%   See also STRCAT, STRSPLIT.

%   Copyright 2012 The MathWorks, Inc.

narginchk(1, 2);

% Check input arguments.
if ~isCellString(c)
    error(message('MATLAB:strjoin:InvalidCellType'));
end
if nargin < 2
    aDelim = ' ';
end

% Allocate a cell to join into - the first row will be C and the second, D.
numStrs = numel(c);
joinedCell = cell(2, numStrs);
joinedCell(1, :) = reshape(c, 1, numStrs);
if isString(aDelim)
    if numStrs < 1
        joinedStr = '';
        return;
    end
    escapedDelim = strescape(aDelim);
    joinedCell(2, 1:numStrs-1) = {escapedDelim};
elseif isCellString(aDelim)
    numDelims = numel(aDelim);
    if numDelims ~= numStrs - 1
        error(message('MATLAB:strjoin:WrongNumberOfDelimiterElements'));
    end
    joinedCell(2, 1:numDelims) = aDelim(:);
else
    error(message('MATLAB:strjoin:InvalidDelimiterType'));
end

% Join.
joinedStr  = [joinedCell{:}];




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


end

