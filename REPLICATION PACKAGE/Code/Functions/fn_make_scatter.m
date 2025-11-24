function fig = fn_make_scatter(var1,var2,var1label,var2label,title_in,xline_on,yline_on)
% fn_make_scatter.m 
% function that uses fn_getxy_new to find matching ID numbers and lines
% them up so that I can generate a scatter plot using an x,y pair for each
% forecaster
% inputs:   var1: nx1 numeric array 
%           var2: nx1 numeric array
%           var1label: string label for xaxis
%           var2label: string label for yaxis 
%           title_in: chart title 
%           xline_on & yline_on: 1 if we want dashed red lines, 0 if not 

[x,y] = fn_getxy_new(var1,var2); % get the matched values for each forecaster

figure
fig = scatter(x,y,'filled') % want to start w/ a filled scatter plot
title(title_in) % title 
xlabel(var1label)  % xaxis
ylabel(var2label) % yaxis 
r = corrcoef(x,y); % generate the correl coef 
r = round(r,2)
str=['R = ',num2str(r(1,2))]; % make a string of the correl coef to add to the chart
T = text(min(get(gca, 'xlim')), max(get(gca, 'ylim')), str); % find the location of the corner of the chart, name it T 
set(T, 'fontsize', 14, 'verticalalignment', 'top', 'horizontalalignment', 'left'); % put the correl coef in the corner 
l = lsline; % make a least squares/line of best fit on the chart as well 
l.Color = 'k'; % make sure it is a black line 
if xline_on == 1 & yline_on == 1  % if we decided to use dotted red lines
    xline(0,'--r')
    yline(1,'--r')
end


end