function [x,y] = fn_getxy_new(var1,var2)
% function that 

newvar1 = fn_idsplit(var1)
newvar2 = fn_idsplit(var2)
[C, ia, ib] = intersect(newvar1(:,1), newvar2(:,1),'stable'); % indices will be same for all Aroll metrics

for i = 1:size(newvar1,1)
    for j = 1:size(ia,1)
        row = newvar1(ia(j),:);  % These loops ensure that we are pulling from both var1 and var2 only what the intersection of the 2 sets
        var1keep(j,:) = row;
    end
end
for i = 1:size(newvar2,1)
    for j = 1:size(ib,1)
        row = newvar2(ib(j),:);
        var2keep(j,:) = row;
    end
end

% x = cell2mat(var1keep(:,2)); y = cell2mat(var2keep(:,2));
x = var1keep(:,2); 
y = var2keep(:,2); 


end
