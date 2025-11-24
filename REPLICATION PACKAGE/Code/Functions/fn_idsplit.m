function clean_array = fn_idsplit(array)
% fn_id_split.m
% fn that takes in an nx2 cell array of forecaster data, where column 1 is
% the forecaster id label from stata output and column 2 is a numeric value
% from the regression
% outputs an nx2 numeric array where col 1 is the forecast ID# and col 2 is
% the fixed effect etc. from the regression output 
array_to_clean = array(:,1);
    for i = 1:size(array_to_clean,1)
        ids{i,:} = split(array_to_clean{i,1}, '.');
    end
    for i = 1:size(ids,1)
        check_pers = ids{i,1};
        check = strcmp(check_pers(1,1),'1bn'); % set this way for the current way that i export the data from stata, sometimes changes to ib??? 
        if check == 1
            ids{i,1}{1,1} = '1';
        end
    end
    for i = 1:size(ids,1)
        id = ids{i,1}{1,1}; 
        id_num = str2double(id);
        id_nums(i,1) = id_num; 
    end
    array_num = cell2mat(array(:,2)); 
    clean_array = [id_nums, array_num];
    
end

    