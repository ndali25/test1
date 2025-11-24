function [q1,q2,q3,q4] = fn_getquad_ids(var1,var2)
% var2 always needs to be the lambda vector -- otherwise this needs to
% become a conditional 
for i = 1:size(var2,1)
    splits =  strsplit(var2{i,1}, '#'); % have to do this for the lambdas
    newvar2{i,1} = splits{1,1};
end

newvar2 = [newvar2 var2(:,2)];

newvar1keep = fn_idsplit(var1); newvar2keep = fn_idsplit(newvar2);
% arrays already sorted, now just concatenate
allvar_keep = [newvar1keep newvar2keep(:,2)]; % this should match up for each person what their alpha and lambda is (in that order)

q1 = NaN(size(allvar_keep,1),3); q2 = NaN(size(allvar_keep,1),3); q3 = NaN(size(allvar_keep,1),3); q4 = NaN(size(allvar_keep,1),3);

for i = 1:size(allvar_keep,1)
    % quadrant 1
    if allvar_keep(i,2) < 0 && allvar_keep(i,3) > 1
        q1(i,:) = allvar_keep(i,:);
        % quad 2
    elseif allvar_keep(i,2) > 0 && allvar_keep(i,3) > 1
        q2(i,:) = allvar_keep(i,:);
        % quad 3
    elseif allvar_keep(i,2) < 0 && allvar_keep(i,3) < 1
        q3(i,:) = allvar_keep(i,:);
        % quad 4
    elseif allvar_keep(i,2) > 0 && allvar_keep(i,3) < 1
        q4(i,:) = allvar_keep(i,:);
    end
end
% now remove the missing obs 
 q1 = rmmissing(q1);  q2 = rmmissing(q2);  q3 = rmmissing(q3);  q4 = rmmissing(q4);   
 
end

