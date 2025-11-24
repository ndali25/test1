%======================================================================
% x09_Simulations.m
%======================================================================
% Use regression output (vector of coefficients & vcv matrix) to produce 
% simulated alphas & lambdas for each target variable. Use those simulated 
% pairs to test for a forecaster persistence in an alpha/lambda quadrant.
%======================================================================

close all;clear;clc;
addpath '...\...\REPLICATION PACKAGE\Code' % CHANGE FILEPATH HERE
addpath '...\...\REPLICATION PACKAGE\Code\Functions' % CHANGE FILEPATH HERE
addpath '...\...\REPLICATION PACKAGE\Output\Simulations' % CHANGE FILEPATH HERE
format shortG
vars = {'gdp','hicp','urate'}; 
horizons = {'Aroll','Broll'};
nums = {'50'};
metrics = {'pfa','arps'};

for num = 1:size(nums,2)
    directory = '...\...\REPLICATION PACKAGE\Output\Regressions\'; % CHANGE FILEPATH HERE
    outputpath = '...\...\REPLICATION PACKAGE\Output\Simulations\Individual Forecasters\'; % CHANGE FILEPATH HERE
    for var = 1:size(vars,2)
        for horizon = 1:size(horizons,2)
            for metric = 1:size(metrics,2)
                disp(strcat(vars{var},horizons{horizon},nums{num},metrics{metric}))
                name_ph = strcat(vars{var},horizons{horizon},nums{num},metrics{metric});
                
                [mu,ids,mu_ids] = xlsread(strcat(directory,'pesaran_',metrics{metric},'_',vars{var},horizons{horizon},'_coefs_',nums{num},'_newey_joint.xlsx'));
                mu_ids = mu_ids';
                mu_ids = mu_ids(2:end,:);
                mu_ids = fn_idsplit(mu_ids);
                vcv = xlsread(strcat(directory,'pesaran_',metrics{metric},'_',vars{var},horizons{horizon},'_cov_',nums{num},'_newey_joint.xlsx'));
                
                rng(2) % For reproducibility
                
                mu_sim_v1 = mvnrnd(mu,vcv,1000);
                L = cholcov(vcv); % Check
                
                mu_sim_v2 = randn(1000,size(mu,2))*L + mu;
                
                alphas_sim = mu_sim_v1(:,1:size(mu_sim_v1,2)/2);
                lambdas_sim = mu_sim_v1(:,(size(mu_sim_v1,2)/2)+1:end);
                
                GA = {1,2,4,5,15,16,20,22,23,24,26,29,31,33,36,37,38,39,42,52,54,56,61,85,88,89,93,94,95,96,98};
                GB = {1,2,4,5,15,16,20,22,23,24,26,29,31,33,36,37,38,39,52,54,56,85,88,89,90,93,94,95,98};
                HA = {1,2,4,5,15,16,20,22,23,24,26,29,31,33,36,37,38,39,42,47,52,54,56,85,88,89,90,91,92,93,94,95,96,98};
                HB = {1,2,4,5,15,16,20,22,23,24,26,29,31,33,36,37,38,39,42,52,54,56,85,88,89,90,91,93,94,95,98};
                UA = {1,2,4,5,15,16,20,22,23,24,26,29,31,33,36,37,38,39,42,52,54,56,89,91,94,95,96,98};
                UB = {1,2,4,5,15,16,20,22,23,24,26,31,33,36,37,38,39,52,54,89,91,94,95,98};
                
                all_pers_quad = [];
                for pers = 1:size(alphas_sim,2)
                    
                    x = alphas_sim(:,pers);
                    mean(x);
                    y = lambdas_sim(:,pers);
                    mean(y);
    
                    % Collect the paired alpha and lambda for each
                    % forecaster
                    pers_paired = [x,y];
                    
                     if strcmp(cell2mat(horizons(horizon)),'Aroll') && strcmp(cell2mat(vars(var)),'gdp')  
                        fileName = append('simulations_', num2str(cell2mat(GA(pers))), '_', cell2mat(vars(var)), '_', cell2mat(horizons(horizon)), '_', cell2mat(metrics(metric)), '.xlsx');
                        fpath_out = append(outputpath, fileName); 

                        writematrix(pers_paired, fpath_out);
                        
                    elseif strcmp(cell2mat(horizons(horizon)),'Broll') && strcmp(cell2mat(vars(var)),'gdp') 
                        fileName = append('simulations_', num2str(cell2mat(GB(pers))), '_', cell2mat(vars(var)), '_', cell2mat(horizons(horizon)), '_', cell2mat(metrics(metric)), '.xlsx');
                        fpath_out = append(outputpath, fileName); 

                        writematrix(pers_paired, fpath_out);
                        
                    elseif strcmp(cell2mat(horizons(horizon)),'Aroll') && strcmp(cell2mat(vars(var)),'hicp') 
                        fileName = append('simulations_', num2str(cell2mat(HA(pers))), '_', cell2mat(vars(var)), '_', cell2mat(horizons(horizon)), '_', cell2mat(metrics(metric)), '.xlsx');
                        fpath_out = append(outputpath, fileName); 

                        writematrix(pers_paired, fpath_out);
                        
                    elseif strcmp(cell2mat(horizons(horizon)),'Broll') && strcmp(cell2mat(vars(var)),'hicp')
                        fileName = append('simulations_', num2str(cell2mat(HB(pers))), '_', cell2mat(vars(var)), '_', cell2mat(horizons(horizon)), '_', cell2mat(metrics(metric)), '.xlsx');
                        fpath_out = append(outputpath, fileName); 

                        writematrix(pers_paired, fpath_out);
                        
                    elseif strcmp(cell2mat(horizons(horizon)),'Aroll') && strcmp(cell2mat(vars(var)),'urate') 
                        fileName = append('simulations_', num2str(cell2mat(UA(pers))), '_', cell2mat(vars(var)), '_', cell2mat(horizons(horizon)), '_', cell2mat(metrics(metric)), '.xlsx');
                        fpath_out = append(outputpath, fileName); 

                        writematrix(pers_paired, fpath_out);
                        
                    elseif strcmp(cell2mat(horizons(horizon)),'Broll') && strcmp(cell2mat(vars(var)),'urate') 
                        fileName = append('simulations_', num2str(cell2mat(UB(pers))), '_', cell2mat(vars(var)), '_', cell2mat(horizons(horizon)), '_', cell2mat(metrics(metric)), '.xlsx');
                        fpath_out = append(outputpath, fileName); 

                        writematrix(pers_paired, fpath_out);
                    end
                    
                    q1 = NaN(size(alphas_sim,1),2); q2 = NaN(size(pers_paired,1),2); q3 = NaN(size(pers_paired,1),2); q4 = NaN(size(pers_paired,1),2);
                    
                    for i = 1:size(pers_paired,1)
                            % Quadrant 1
                        if pers_paired(i,1) < 0 && pers_paired(i,2) > 1
                            q1(i,:) = pers_paired(i,:);
                            % Quadrant 2
                        elseif pers_paired(i,1) > 0 && pers_paired(i,2) > 1
                            q2(i,:) = pers_paired(i,:);
                            % Quadrant 3
                        elseif pers_paired(i,1) < 0 && pers_paired(i,2) < 1
                            q3(i,:) = pers_paired(i,:);
                            % Quadrant 4
                        elseif pers_paired(i,1) > 0 && pers_paired(i,2) < 1
                            q4(i,:) = pers_paired(i,:);
                        end
                    end
                    % Remove missing observations
                    q1 = rmmissing(q1);  q2 = rmmissing(q2);  q3 = rmmissing(q3);  q4 = rmmissing(q4);
                    
                    % Simulation outcomes falling in each quadrant 
                    q1freq = size(q1,1); q2freq = size(q2,1);
                    q3freq = size(q3,1); q4freq = size(q4,1);
                    all_quad = [q1freq q2freq q3freq q4freq];
                    all_pers_quad(pers,:) = [mu_ids(pers,1),all_quad];
                end
                all_pers_metrics{:,metric} = all_pers_quad;
            end
            all_pers_horizons{:,horizon} = all_pers_metrics;
        end
        all_pers_vars{:,var} = all_pers_horizons;
    end
    all_pers_50{:,num} = all_pers_vars;
    
end
for var = 1:size(vars,2)
    for horizon = 1:size(horizons,2)
        for metric = 1:size(metrics,2)
            eval(sprintf('%s = all_pers_vars{1,var}{1,horizon}{1,metric}', strcat(vars{var},metrics{metric},horizons{horizon})));
        end
    end
end
% Get list of all possible ID's
all_ids = [gdppfaAroll(:,1);gdppfaBroll(:,1) ;gdparpsAroll(:,1) ; gdparpsBroll(:,1) ; ...
    hicppfaAroll(:,1) ; hicppfaBroll(:,1); hicparpsAroll(:,1); hicparpsBroll(:,1); ...
    uratepfaAroll(:,1); uratepfaBroll(:,1); uratearpsAroll(:,1); uratearpsBroll(:,1) ];
% Get forecaster ID's
unique_ids = unique(all_ids);
% Find simulation outcomes for each forecaster (to be used in deviation
% analysis)
x = {}; % Reset 
x2 = {};
for id = 1:size(unique_ids,1)
    idnum = unique_ids(id,1);
    for var = 1:size(vars,2)
        for horizon = 1:size(horizons,2)
            for metric = 1:size(metrics,2)
                [C,ib,ic] = intersect(all_pers_vars{1,var}{1,horizon}{1,metric}(:,1),idnum); % Find each forecaster's data, if it exists 
                x{var}{horizon}{metric} = all_pers_vars{1,var}{1,horizon}{1,metric}(ib,:);
            end
            x2{id,1} = x;
        end
    end 
end

x3 = horzcat(x2{:}); % Combine all of the data stored in the above loop 
x4 = vertcat(x3{:});
x5 = horzcat(x4{:})';

% Retrieve data for each forecaster
blocks = size(x5,1)/(size(unique_ids,1)*2); % Forecasters as columns 
x6 = reshape(x5,blocks,[]); % Target variables as rows 
x7 = x6(:,1:(size(x6,2)/2)); % PFA data 
x8 = x6(:,(size(x6,2)/2)+1:end); % ARPS data

for ii = 1:size(x7,2) % Loop through columns for each performance metric's forecaster data 
    
    % Pull the data for an individual forecaster and make it numeric instead 
    % of cell; do for both metric arrays
    pfa_persx = cell2mat(x7(:,ii)); arps_persx = cell2mat(x8(:,ii));
    
    % Cut off the ID number from this array for both metrics
    pfa_persx2 = pfa_persx(:,2:5); 
    arps_persx2 = arps_persx(:,2:5);

    pfa_persx3{ii,1} = pfa_persx(:,2:5); 
    arps_persx3{ii,1} = arps_persx(:,2:5);
    
    quad1barpfa = mean(pfa_persx2(:,1));
    quad2barpfa = mean(pfa_persx2(:,2));
    quad3barpfa = mean(pfa_persx2(:,3));
    quad4barpfa = mean(pfa_persx2(:,4));
    
    quad1bararps = mean(arps_persx2(:,1));
    quad2bararps = mean(arps_persx2(:,2));
    quad3bararps = mean(arps_persx2(:,3));
    quad4bararps = mean(arps_persx2(:,4));

    % Sum of squared deviations from the average of the quad1-quad3 totals
    % Simulations across the 6 target variables, for PFA measure 
    ssd1_pfa(ii,:) = sum(((pfa_persx2(:,1) - quad1barpfa).^2)/quad1barpfa);
    ssd2_pfa(ii,:) = sum(((pfa_persx2(:,2) - quad2barpfa).^2)/quad2barpfa);
    ssd3_pfa(ii,:) = sum(((pfa_persx2(:,3) - quad3barpfa).^2)/quad3barpfa);
    
    % Get the critical value at the 5% significance level using # of rows*3
    % for degrees of freedom 
    crtival_id_pfa(ii,:) = chi2inv(0.95,(size(pfa_persx,1)-1)*3); 

    % Same as above but for ARPS measure
    ssd1_arps(ii,:) = sum(((arps_persx2(:,1) - quad1bararps).^2)/quad1bararps);
    ssd2_arps(ii,:) = sum(((arps_persx2(:,2) - quad2bararps).^2)/quad2bararps);
    ssd3_arps(ii,:) = sum(((arps_persx2(:,3) - quad3bararps).^2)/quad3bararps);
    
    critval_id_arps(ii,:) = chi2inv(0.95,(size(arps_persx,1)-1)*3);     
   
end

outputpath2 = '...\...\REPLICATION PACKAGE\Output\Simulations\'; % CHANGE FILEPATH HERE

writematrix(gdparpsAroll, strcat(outputpath2,'gdp_arps_Aroll.xlsx'))
writematrix(gdparpsBroll, strcat(outputpath2,'gdp_arps_Broll.xlsx'))
writematrix(gdppfaAroll, strcat(outputpath2,'gdp_pfa_Aroll.xlsx'))
writematrix(gdppfaBroll, strcat(outputpath2,'gdp_pfa_Broll.xlsx'))

writematrix(hicparpsAroll, strcat(outputpath2,'hicp_arps_Aroll.xlsx'))
writematrix(hicparpsBroll, strcat(outputpath2,'hicp_arps_Broll.xlsx'))
writematrix(hicppfaAroll, strcat(outputpath2,'hicp_pfa_Aroll.xlsx'))
writematrix(hicppfaBroll, strcat(outputpath2,'hicp_pfa_Broll.xlsx'))

writematrix(uratearpsAroll, strcat(outputpath2,'urate_arps_Aroll.xlsx'))
writematrix(uratearpsBroll, strcat(outputpath2,'urate_arps_Broll.xlsx'))
writematrix(uratepfaAroll, strcat(outputpath2,'urate_pfa_Aroll.xlsx'))
writematrix(uratepfaBroll, strcat(outputpath2,'urate_pfa_Broll.xlsx'))


