function [results, bms_results] = fit_models(data,models,results)
    
   likfuns = {'lik_adaptive_gng' 'lik_adaptive_gng_samemeanconf' 'lik_adaptive_gng_samemeanconffreewinit2' };
      
        
    if nargin < 2; models = 1:length(likfuns); end % check, do I have input argument 2 (models)
    
    pmin = 0.01;
    %pmax = 80;
    %btmax = 30;
    pmax = 100;
    btmin = 1e-3;
    btmax = 50;
    
    for mi = 1:length(models)
        m = models(mi);
        disp(['... fitting model ',num2str(m)]);
        fun = str2func(likfuns{m});
        
        switch likfuns{m}
            
%               
            case 'lik_adaptive_gng'
                
                param(1) = struct('name','invtemp','logpdf',@(x) 0,'lb',btmin,'ub',btmax);
                param(2) = struct('name','mq','logpdf',@(x) 0,'lb',-0.999,'ub',0.999);
                param(3) = struct('name','pq','logpdf',@(x) 0,'lb',pmin,'ub',pmax);
                param(4) = struct('name','mv','logpdf',@(x) 0,'lb',-0.999,'ub',0.999);
                param(5) = struct('name','pv','logpdf',@(x) 0,'lb',pmin,'ub',pmax);
                
  
            case 'lik_adaptive_gng_samemeanconf'
                param(1) = struct('name','invtemp','logpdf',@(x) 0,'lb',btmin,'ub',btmax);
                param(2) = struct('name','mvq','logpdf',@(x) 0,'lb',-0.999,'ub',0.999);
                param(3) = struct('name','pvq','logpdf',@(x) 0,'lb',pmin,'ub',pmax);
                                
            case 'lik_adaptive_gng_samemeanconffreewinit2'
                param(1) = struct('name','invtemp','logpdf',@(x) 0,'lb',btmin,'ub',btmax);
                param(2) = struct('name','mvq','logpdf',@(x) 0,'lb',-0.999,'ub',0.999);
                param(3) = struct('name','pvq','logpdf',@(x) 0,'lb',pmin,'ub',pmax);
                param(4) = struct('name','w02','logpdf',@(x) 0,'lb',0.001,'ub',0.999);
                
              

    end
        
    
        results(m) = mfit_optimize(fun,param,data); % this fits parameters to data with defined function
        clear param
    end
    
    % Bayesian model selection
    if nargout > 1
        bms_results = mfit_bms(results,1);
    end