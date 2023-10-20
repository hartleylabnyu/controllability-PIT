function [simulated_data, model_results] = run_param_recoverability_params_as_input(n_simulations,simulated_params,models)


%This function simulates data and fits models to the simulated data. 
%The function takes three input arguments:
%"n_simulations": the number of simulations to run.
%"simulated_params": a structure containing the simulated model parameters to use as input.
%"models": a vector of integers specifying which models to use.


%The function sets up a task structure for each simulation, which involves 
%setting up a stimulus type and block for each trial type. Then, for each 
%model specified in "models", the function simulates data using the 
%corresponding model function ("sim_adaptive", "sim_adaptive_gng_sameconf", etc.)
%and the simulated parameters provided in "simulated_params".
%The simulated data is stored in the output variable "simulated_data". 
%Finally, the function fits each model to 
%the simulated data using the "fit_models" function and stores the results 
%in the output variable "model_results".
%The commented-out code at the end of the function suggests that the function may have been designed to
%calculate correlations between the simulated and fitted parameters, but 




    % Conditions:
    % 1: GotoWin
    % 2: GotoAvoid
    % 3: NoGotoWin
    % 4: NoGotoAvoid
    simfuns = { 'sim_adaptive' 'sim_adaptive_gng_samemeanconf' 'sim_adaptive_gng_samemeanconfwinit2'}
        %'sim_adaptive_gng_samemeanconffreewinit2'};

    %set up task structure
    for s = 1:n_simulations
            
            % set up stimulus type
            TrialTypeLearning = [];
            RandTrialTypeLearning = [];
            for blocks = 1:6 %distribute trial types evenly across 3 blocks (each block 60 trials)
                TrialTypeLearning1=repmat([1 2 3 4],[1,15]);  % 1 go reward; 2 go punishment; 3 no-go reward; 4 no-go punishment;
                TrialTypeLearning=[TrialTypeLearning TrialTypeLearning1];
                RandTrialTypeLearning1=TrialTypeLearning1(randperm(size(TrialTypeLearning1,2)));
                RandTrialTypeLearning = [RandTrialTypeLearning RandTrialTypeLearning1];
            end  
  
            taskstructure(s).s = RandTrialTypeLearning;
            taskstructure(s).N = 360;
            
            if rand(1) < .5
                taskstructure(s).block = [ones(taskstructure(s).N/2,1)*5050;ones(taskstructure(s).N/2,1)*8020];
            else
                taskstructure(s).block = [ones(taskstructure(s).N/2,1)*8020;ones(taskstructure(s).N/2,1)*5050];
            end
            
            taskstructure(s).R = [0.2 0.8; 0.2 0.8; 0.8 0.2; 0.8 0.2];
    end

    disp(['...simulating data']);
    for mi = 1:length(models)
        m = models(mi);

%         %sample params from uniform distribution b/n empirical min and
%         %empirical max
%         n_params = size(results(m).x,2);
%         for n = 1:n_params
%             simulated_params(m).x(:,n) = unifrnd(min(results(m).x(:,n)),max(results(m).x(:,n)),[n_simulations 1]);
%         end
        
         
        for s = 1:n_simulations
            
            %simulate data
            switch simfuns{m}
                
                case 'sim_adaptive'
                    simulated_data(m).behavior(s) = sim_adaptive(simulated_params(m).x(s,:),taskstructure(s));
                case 'sim_adaptive_gng_samemeanconf'
                    simulated_data(m).behavior(s) = sim_adaptive_gng_samemeanconf(simulated_params(m).x(s,:),taskstructure(s));
%sim_adaptive_gng_samemeanconfwinit2
               case 'sim_adaptive_gng_samemeanconfwinit2'
                    simulated_data(m).behavior(s) = sim_adaptive_gng_samemeanconfwinit2(simulated_params(m).x(s,:),taskstructure(s));
            end     
        end
        %fit model to simulated_data
        temp = fit_models(simulated_data(m).behavior,models);
        model_results(m).model = temp;

    end
    