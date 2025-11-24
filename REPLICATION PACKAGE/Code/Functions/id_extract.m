function id_extract(file, score, remove_ids, save_path, data_path, name)
% Pulls digits from frist row of spreadsheet (assuming Excel file)
% and uses them to create, and export, a csv with the associated score
% vector

ids = readtable([data_path, file],'Range', '1:1');
ids = ids.Properties.VariableNames(2:end);
ids = regexp(ids, '\d*', 'match');
ids = str2double([ids{:}])';

% Remove ids contained in remove_ids variable
ids(remove_ids) = [];

id_scores = array2table([ids, score],'VariableNames', ["ID"; "Score"]);
writetable(id_scores, [save_path, name, '.xlsx']);

end