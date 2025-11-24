%======================================================================
% x08_Significance_Testing_and_Charts.m
%======================================================================
% Take regression coefficients and VCV matrices to compute a chi-squared 
% statistic for each metric/variable/horizon combination. Make some 
% preliminary scatterplots and histograms. This program produces the
% material for Tables 1 and 2.
%======================================================================

close all;clear;clc;
addpath '...\...\REPLICATION PACKAGE\Code' % CHANGE FILEPATH HERE
addpath '...\...\REPLICATION PACKAGE\Code\Functions' % CHANGE FILEPATH HERE
format shortG
vars = {'gdp', 'hicp', 'urate'};            % Variables
horizons = {'Aroll', 'Broll'};              % Horizons
nums = {'50'};                              % Participation Criterion
metrics = {'pfa', 'arps'};                  % Performance Measures
directory = '...\...\REPLICATION PACKAGE\Output\Regressions'; % CHANGE FILEPATH HERE

%==========================================================================
% Test statistics
%==========================================================================
outputpath = '...\...\REPLICATION PACKAGE\Output\Statistical Tests'; % CHANGE FILEPATH HERE

for num = 1:size(nums,2)
    for var = 1:size(vars,2) % Do this for each variable specified
        for horizon = 1:size(horizons,2) % For each horizon
            for metric = 1:size(metrics,2) % For each performance measure
                
                current = strcat(vars{var},horizons{horizon},'_', metrics{metric});
                dof = 'Degrees of Freedom';
                crit5 = 'Crit. Val. at 5% Level';
                crit1 = 'Crit. Val. at 1% Level';
                disp(strcat(vars{var},horizons{horizon},'_', metrics{metric}));
                
                % JOINT TEST
                % Read in fixed-effects and lambdas coefficients to use in joint test
                [num_coefs_joint,labels_joint,coefs_joint] = xlsread(strcat(directory,'\pesaran_',metrics{metric},'_',vars{var},horizons{horizon},'_coefs_',nums{num},'_newey_joint.xlsx'));
                
                % Then the covariance matrix for joint test
                [num_mat_joint, ~, cov_joint] = xlsread(strcat(directory,'\pesaran_',metrics{metric},'_',vars{var},horizons{horizon},'_cov_',nums{num},'_newey_joint.xlsx'));
                num_coefs_joint = num_coefs_joint'; % Transpose to get column vector
                coefs_joint2 = coefs_joint(:,2:end);
                
                % Then for the joint test, find interaction term but in different format
                % Lambda joint start is thus
                lambda_joint_start = size(num_coefs_joint,1)/2+1;
                lambdas = num_coefs_joint(lambda_joint_start:end, 1);
                
                fe_start = 1; fe_end = lambda_joint_start-1; % Fixed effects are read in first; lambdas are second
                fixed_effects = num_coefs_joint(fe_start:fe_end, 1); % Now grab FE's and store
                
                fes_toplot{metric,1} = fixed_effects; % Store these by horizon in a cell array
                lambdas_toplot{metric,1} = lambdas; % Same for the lambdas
                
                coefs_joint2 = coefs_joint2';
                fe_data = coefs_joint2(fe_start:fe_end,:); % Store data with ID's for matching later
                lambda_data =  coefs_joint2(lambda_joint_start:end,:);
                fe_data_met{metric,1} = fe_data;
                lambda_data_met{metric,1} = lambda_data;
                participation_count{horizon,1} = size(fixed_effects,1); % Won't change depending on the metric, only the var or horizon
                
                % Lastly, use the model output in which each coefficient is estimated directly 
                % for the alphas and the lambdas in order to do the joint test
                lambdas_test = lambdas - 1;
                all_joint = cat(1, fixed_effects, lambdas_test);
                num_mat_joint_test = inv(num_mat_joint); % invert the joint matrix
                chi2_joint{metric,1} = current;
                chi2_joint{metric,2} = all_joint'*(num_mat_joint_test*all_joint);
                chi2_joint{metric+1,1} = dof;
                chi2_joint{metric+2,1} = crit5;
                chi2_joint{metric+3,1} = crit1;
                chi2_joint{metric+1,2} = participation_count{horizon,1}*2;
                chi2_joint{metric+2,2} = chi2inv(0.95,((participation_count{horizon,1})*2));
                chi2_joint{metric+3,2} = chi2inv(0.99,((participation_count{horizon,1})*2));
                
                % Test whether all of the alphas are equal to 0; partion the vcv matrix
                fe_mat_new = num_mat_joint(1:size(fixed_effects,1),1:size(fixed_effects,1));
                fe_mat_new_inv = inv(fe_mat_new);
                chi2_alphas{metric,1} = current;
                chi2_alphas{metric,2} = fixed_effects'*(fe_mat_new_inv*fixed_effects);
                chi2_alphas{metric+1,1} = dof;
                chi2_alphas{metric+2,1} = crit5;
                chi2_alphas{metric+3,1} = crit1;
                chi2_alphas{metric+1,2} = participation_count{horizon,1};
                chi2_alphas{metric+2,2} = chi2inv(0.95,participation_count{horizon,1});
                chi2_alphas{metric+3,2} = chi2inv(0.99,participation_count{horizon,1});
                
                % Test whether all of the lambdas are equal to 1; partition
                % the vcv matrix (NOT USED IN PAPER)
                lambda_mat_new = num_mat_joint(lambda_joint_start:end,lambda_joint_start:end);
                lambda_mat_new_inv = inv(lambda_mat_new);
                chi2_lambdas_one{metric,1} = current;
                chi2_lambdas_one{metric,2} = lambdas_test'*(fe_mat_new_inv*lambdas_test);
                chi2_lambdas_one{metric+1,1} = dof;
                chi2_lambdas_one{metric+2,1} = crit5;
                chi2_lambdas_one{metric+3,1} = crit1;
                chi2_lambdas_one{metric+1,2} = participation_count{horizon,1}-1;
                chi2_lambdas_one{metric+2,2} = chi2inv(0.95,participation_count{horizon,1}-1);
                chi2_lambdas_one{metric+3,2} = chi2inv(0.99,participation_count{horizon,1}-1);
                
                % EQUALITY TESTS: THE LAMBDAS
                % Now do the individual tests of the alphas and the lambdas
                % for equality; need to use the 'alpha hats' and 'lambda hats' for this
                % Like before, read in coefs
                [num_coefs_hats,labels_hats,coefs_hats] = xlsread(strcat(directory,'\pesaran_',metrics{metric},'_',vars{var},horizons{horizon},'_coefs_',nums{num},'_newey_hats.xlsx'));
                % Then read in vcv matrix
                [num_mat_hats,labels_cov_hats,covmat_hats] = xlsread(strcat(directory,'\pesaran_',metrics{metric},'_',vars{var},horizons{horizon},'_cov_',nums{num},'_newey_hats.xlsx'));
                
                find0 = [];
                for i = 1:size(num_coefs_hats,2)
                    if num_coefs_hats(1,i) == 0
                        find0(1,i) = 1;
                    end
                end
                inds_sep = find(find0);
                fehat_start = inds_sep(1,1)+1; fehat_end = inds_sep(1,2)-1; % Needs to be +1 and -1 because; don't want to include the 0s
                lambdahat_start = inds_sep(1,2)+1; lambdahat_end = size(num_coefs_hats,2)-2; % Needs to be -2 because of the two constants at the end of the coefficient output
                
                fe_hats = num_coefs_hats(1,fehat_start:fehat_end)';
                lambda_hats = num_coefs_hats(1,lambdahat_start:lambdahat_end)';
                
                % Now take the partitions of the vcv matrices
                fecovmat = num_mat_hats(fehat_start:fehat_end, fehat_start:fehat_end);
                fecovmat_test = inv(fecovmat);
                lambdacovmat = num_mat_hats(lambdahat_start:lambdahat_end,lambdahat_start:lambdahat_end);
                lambdacovmat_test = inv(lambdacovmat);
                
                % Test for equality of fixed effects (NOT USED IN PAPER):
                chi2_alphas2{metric,1} = fe_hats'*(fecovmat_test*fe_hats);
                
                % Test for equality of slope coefficients:
                chi2_lambdas{metric,1} = current;
                chi2_lambdas{metric,2} = lambda_hats'*(lambdacovmat_test*lambda_hats);
                chi2_lambdas{metric+1,1} = dof;
                chi2_lambdas{metric+2,1} = crit5;
                chi2_lambdas{metric+3,1} = crit1;
                chi2_lambdas{metric+1,2} = participation_count{horizon,1}-1;
                chi2_lambdas{metric+2,2} = chi2inv(0.95,participation_count{horizon,1}-1);
                chi2_lambdas{metric+3,2} = chi2inv(0.99,participation_count{horizon,1}-1);
                
            end % End metric loop

            sheetname = strcat(vars{var},horizons{horizon});
            writecell(chi2_joint,strcat(outputpath,'\distributional_homogeneity.xlsx'),'Sheet',sheetname)
            writecell(chi2_alphas,strcat(outputpath,'\normalization_approach.xlsx'),'Sheet',sheetname)
            writecell(chi2_lambdas,strcat(outputpath,'\time_fixed_effects.xlsx'),'Sheet',sheetname)

            chi2_joint_horz{horizon,1} = chi2_joint;
            lambda_data_horz{horizon,1} = lambda_data_met;
            fe_data_horz{horizon,1} = fe_data_met;
            chi2_alphas_horz{horizon,1} = chi2_alphas;
            chi2_lambdas_one_horz{horizon,1} = chi2_lambdas_one;
            chi2_lambdas_horz{horizon,1} = chi2_lambdas;
            fes_toplot_horz{horizon,1} = fes_toplot; % Now store these by horizon in a cell array
            lambdas_toplot_horz{horizon,1} = lambdas_toplot;
            
            % Compute critical value for the chi2 distr by # of degrees of
            % freedom, which depends on the test
            crit_val_alphas5{horizon} = chi2inv(0.95,participation_count{horizon,1});
            crit_val_lambdas5{horizon} = chi2inv(0.95,participation_count{horizon,1}-1);
            crit_val_alphas1{horizon} = chi2inv(0.99,participation_count{horizon,1});
            crit_val_lambdas1{horizon} = chi2inv(0.99,participation_count{horizon,1}-1);
            crit_val_joint5{horizon} = chi2inv(0.95,((participation_count{horizon,1})*2));
            crit_val_joint1{horizon} = chi2inv(0.99,((participation_count{horizon,1})*2));
            
        end % End horizon loop

        % Now store the horizons by variable
        table_joint_horz{var,1} = table(horizons', chi2_joint_horz);
        table_alphas_horz{var,1} = table(horizons', chi2_alphas_horz);
        table_lambdas_one_horz{var,1} = table(horizons', chi2_lambdas_one_horz);
        table_lambdas_horz{var,1} = table(horizons', chi2_lambdas_horz);
        
        all_fes{var,1} = fe_data_horz; % Store Aroll and Broll fixed effects for each var
        all_lambdas{var,1} = lambda_data_horz; % Store Aroll and Broll lambdas for each var
        
        % Keep track of how many forecasters get through participation filter 
        part_count{var,1} = participation_count;
        
        % Also store critical values by var
        critval_horz_joint{var,1} = crit_val_joint5;
        critval_horz_joint{var,2} = crit_val_joint1;
        critval_alphas_horz{var,1} = crit_val_alphas5;
        critval_alphas_horz{var,2} = crit_val_alphas1;
        critval_lambdas_horz{var,1} = crit_val_lambdas5;
        critval_lambdas_horz{var,2} = crit_val_lambdas1;

    end % End var loop

    part_count_num{num,1} = part_count; % Store that count by cutoff num

end % End participation count loop

% Generate the variable names using loops
for var = 1:size(vars,2)
    for horizon = 1:size(horizons,2)
        for metric = 1:size(metrics,2)
            eval(sprintf('%s = all_fes{var,1}{horizon,1}{metric,1}', strcat(vars{var},'_fe_',metrics{metric},'_',horizons{horizon})));
            eval(sprintf('%s = all_lambdas{var,1}{horizon,1}{metric,1}', strcat(vars{var},'_lambda_',metrics{metric},'_',horizons{horizon})));
        end
    end
end


