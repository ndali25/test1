%======================================================================
% x00c_Main.m
%======================================================================
% Run programs for Hounyo and Lahiri (2023) appendix section.
%======================================================================

close all;clear;clc;
vars = ["gdpAroll"; "gdpBroll"; "hicpAroll"; "hicpBroll"; "urateAroll"; "urateBroll";];
save_filename = 'HL_Tables';
cd '...\...\REPLICATION PACKAGE\' % CHANGE FILEPATH HERE
addpath '...\...\REPLICATION PACKAGE\Code' % CHANGE FILEPATH HERE
addpath '...\...\REPLICATION PACKAGE\Code\Functions' % CHANGE FILEPATH HERE
delete(['.\Output\HL Results\' save_filename '.xlsx'])

for v=1:size(vars,1)
    
    variable = char(vars(v,:));
    
    file = ['errors_' variable '_point.xlsx'];
    save_sheetname = variable;

    x19a_Points(file, save_filename, save_sheetname) % Table 1A
    x19b_Points_Restrictive(file, save_filename, save_sheetname) % Table 2A

end

for v=1:size(vars,1)
    
    variable = char(vars(v,:));
    
    file = ['errors_' variable '_density.xlsx'];
    save_sheetname = variable;

    x20a_Densities(file, save_filename, save_sheetname) % Table 3A
    x20b_Densities_Restrictive(file, save_filename, save_sheetname) % Table 4A

end


