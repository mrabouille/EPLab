function save_fig(hFig,filename)

saveas(hFig,filename)

if strcmpi( get(hFig, 'Visible'), 'off')
    map = load(filename,'-mat');
    names = fieldnames(map);
    for j = 1:numel(names)
        map.(names{j}).properties.Visible = 'on';
    end
    save(filename,'-struct','map');
end
