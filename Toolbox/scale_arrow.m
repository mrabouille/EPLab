function pos_globale = scale_arrow(hx, pos_locale)
% hx = gca;
% pos_locale =  [30,40;100,75]

axe_pos = get(hx,'Position');
lim_x = get(hx,'XLim');
lim_y = get(hx,'YLim');

% axes units
x_locale = pos_locale(:,1)';
y_locale = pos_locale(:,2)';

if any(x_locale<lim_x(1)) || any(x_locale>lim_x(2)) || any(y_locale<lim_y(1)) || any(y_locale>lim_y(2))
    x_locale
    y_locale
    lim_x
    error('over scale')
end

x_unit = (x_locale - lim_x(1) )/diff(lim_x);
y_unit = (y_locale - lim_y(1) )/diff(lim_y);

% normalized figure units
x_globale = axe_pos(1) + x_unit*axe_pos(3);
y_globale = axe_pos(2) + y_unit*axe_pos(4);


pos_globale = [x_globale;y_globale];

end
