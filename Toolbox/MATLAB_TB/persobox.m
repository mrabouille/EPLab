function selection = persobox( string)

selection = [];
fig = figure('name', 'uiarray', 'numbertitle', 'off');
figPos = get(gcf, 'pos');

m = size(string,1); %lignes
n = 1; %colonnes
border = 20; spacing = 5; height = 15;


panelh=height*(m)+spacing*(m-1)+border*2;


bigFramePos = [0 0 figPos(3) panelh];

panelh = panelh+height+spacing;


style = 'check';
callback = 'disp([''This is a '' get(gco, ''style'')])';



panel = uipanel('Parent',1);
set(panel,'Units','normalized','Position',[0 1-panelh/figPos(4) 1 panelh/figPos(4)]);


[handle, pos] = uiarray(bigFramePos, m, n, border, spacing, style, callback, string,panel);

loc = pos(1,:);
loc(2) = loc(2)+spacing+height;

s = uicontrol('Style','pushbutton',...
            'Parent',panel,...
            'Position',[pos(1,1) pos(1,2)+spacing+height (pos(1,3)-border)/2 pos(1,4)],...   
            'String', 'OK',...
            'Value',1,...
            'Callback','selection = cell2mat(get(handle,''value''))' );

s = uicontrol('Style','pushbutton',...
            'Parent',panel,...
            'Position',[pos(1,1)+(pos(1,3)+border)/2 pos(1,2)+spacing+height (pos(1,3)-border)/2 pos(1,4)],...   
            'String', 'Annuler',...
            'Value',1,...
            'Callback','error(''Arret par l''utilisateur'')');

s = uicontrol('Style','Slider',...
            'Parent',gcf,...
            'Position',[bigFramePos(3)-border bigFramePos(2) border figPos(4)],...   
            'Value',1,...
            'Callback',@(hObject,callbackdata)(set(panel,'Position',[0 (1-panelh/figPos(4))*(get(hObject,'Value')) 1 panelh/figPos(4)])  ) );
         

waitfor(fig)


if isempty(selection)
    error('pas bon')
end


% 'Callback',@(hObject,callbackdata)( set(gcf,'Position',[0 -get(hObject,'Value') 1 2]) ));
            



function [handle, pos] = ...
    uiarray(bigFramePos, m, n, border, spacing, style, callback, string, h)
% UIARRAY creates an array (or matrix)  of UI buttons.
%   UIARRAY(POS, M, N, BORDER, SPACING, STYLE, CALLBACK, STRING) creates
%   an M*N UI controls positioned as M by N array within POS. BORDER
%   specifies the spacing between UI's and the enclosing big frame;
%   SPACING specifies the spacing between UI's. STYLE, CALLBACK and
%   STRING are string matrices (with row dimension M*N) specifying the
%   styles, callbacks and strings, respectively, for the M*N UI controls.
%   If row dimension of these arguments are less then M*N, the last row
%   will be repeated as many times as necessary.
%
%   This function is used primarily for creating UI controls of demos
%   of the toolbox.
%
%   For example:
%
%   figure('name', 'uiarray', 'numbertitle', 'off');
%   figPos = get(gcf, 'pos');
%   bigFramePos = [0 0 figPos(3) figPos(4)];
%   m = 4; n = 3;
%   border = 20; spacing = 10;
%   style = str2mat('push', 'slider', 'radio', 'popup', 'check');
%   callback = 'disp([''This is a '' get(gco, ''style'')])';
%   string = str2mat('one', 'two', 'three', 'four-1|four-2|four-3', 'five');
%   uiarray(bigFramePos, m, n, border, spacing, style, callback, string);

%   J.-S. Roger Jang, 6-28-93.
%   Copyright 1994-2002 The MathWorks, Inc. 

% set defaults
if nargin <= 3, border = bigFramePos(3)/10; end
if nargin <= 4, spacing = border; end
if nargin <= 5, style = 'frame'; end
if nargin <= 6, callback = ' '; end
if nargin <= 7, string = ' '; end
if nargin <= 8, scroll = false; end

% correct wrong arguments
if isempty(style), style = ' ', end
if isempty(callback), callback = ' ', end
if isempty(string), string = ' ', end

framecolor = 192/255*[1 1 1];
smallFrameW = (bigFramePos(3) - 3*border - (n-1)*spacing)/n;
smallFrameH = (bigFramePos(4) - 2*border - (m-1)*spacing)/m;

% fill style if it's not long enough
if size(style, 1) < m*n,
    len = size(style, 1);
    tmp = style(len, :);
    tmp = tmp(ones(m*n-len, 1), :);
    style = [style; tmp];
end
% fill callback if it's not long enough
if size(callback, 1) < m*n,
    len = size(callback, 1);
    tmp = callback(len, :);
    tmp = tmp(ones(m*n-len, 1), :);
    callback = [callback; tmp];
end
% fill string if it's not long enough
if size(string, 1) < m*n,
    len = size(string, 1);
    tmp = string(len, :);
    tmp = tmp(ones(m*n-len, 1), :);
    string = [string; tmp];
end


handle = zeros(m*n,1);
pos = zeros(m*n, 4);

for i = 1:m,
    for j = 1:n,
        count = (i-1)*n+j;
        x = bigFramePos(1)+(j-1)*(smallFrameW+spacing)+border; 
        y = bigFramePos(2)+(m-i)*(smallFrameH+spacing)+border;
        pos(count, :) = [x y smallFrameW smallFrameH];
        handle(count) = uicontrol( ...
                'parent',h,...
                'Style',deblank(style(count,:)), ...
                'String', [' ' deblank(string(count,:))], ...
                'Callback',deblank(callback(count,:)), ...
                'Units','pixel', ...
                'Position',pos(count,:), ...
                'BackgroundColor',framecolor);
    end
end


