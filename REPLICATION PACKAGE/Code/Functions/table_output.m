function final_table = table_output(table, title, cnames, rnames, sheetname, filename, write_mode)

text_table = array2table(rnames, 'VariableNames', title);
data_table = array2table(table, 'VariableNames', cnames);
final_table = [text_table data_table];

writetable(final_table, ['.\Output\HL Results\' filename '.xlsx'], 'Sheet', sheetname, 'WriteMode', write_mode, 'WriteVariableNames', true)

end

