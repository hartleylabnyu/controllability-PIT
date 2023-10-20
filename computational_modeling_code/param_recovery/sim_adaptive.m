function data = sim_adaptive(param,data)
    
    % Likelihood function for the Adaptive Bayesian model from Dorfman & Gershman (2019, Nature Communications).
    %
    % USAGE: [lik, latents] = lik_adaptive(param,data)
    %
    % INPUTS:
    %   param - parameter vector
    %   data - a data structure for a single subject, including information about the stimuli, choices, and rewards for each trial.
    %
    % OUTPUTS:
    %   lik - log likelihood
    %   latents - structure containing latent variables
    %
    % Sam Gershman, May 2020
    
    % Noam:
    %The function computes the log likelihood of the data given the model parameters using the Adaptive Bayesian model.
    %The model assumes that the subject uses a weighted combination of instrumental and Pavlovian learning to make decisions. 
    %On each trial, the subject estimates the value of
    %each option based on the previous outcomes and the prior beliefs about the mean and confidence of the values. 
    %The subject then chooses the option with the higher value with a probability that depends on the inverse temperature parameter. 
    %The model also includes a lapse rate parameter to account for
    %errors in responding and an optional bias term to account for differences in response rates between the two options.

    %The function computes the log likelihood by iterating over each trial 
    %in the data and computing the probability of each choice based on the model.
    %It also updates the estimates of the value of each option and the confidence in those estimates based on the outcomes of each trial. The function returns the log likelihood and a structure containing the latent variables for each trial,
    %including the estimated values, the confidence in those estimates, and the weight assigned to each component (instrumental or Pavlovian) in the decision-making process.




    
    bt = param(1);   % inverse temperature
    mq = param(2);   % prior mean, instrumental
    pq = param(3);   % prior confidence, instrumental
    mv = param(4);   % prior mean, Pavlovian
    pv = param(5);   % prior confidence, Pavlovian
    
    if nargin > 5
        lapse = param(6);
    else
        lapse = 0;
    end
    
    if nargin > 6
        b = param(7);
    else
        b = 0;
    end
    
    u = unique(data.s);
    S = length(u);
    
    %controllability of environment changes
    condition_change = find(diff(data.block)~=0) + 1;
    
    
    
    
    for n = 1:data.N
        if n == 1 || n == condition_change
            v = zeros(S,1) + mv;
            q = zeros(S,2) + mq;
            Mv = zeros(S,1) + pv;
            Mq = zeros(S,2) + pq;
            w0 = 0.5;
            L = log(w0) - log(1-w0);
        end
        
        s = data.s(n);  % stimulus
        w = 1./(1+exp(-L));
        d = (1-w)*q(s,1) - (1-w)*q(s,2) - b - w*v(s);
        P = 1./(1+exp(-bt*d)); % probability of NoGo
        
        if rand < (1-lapse)*P + lapse/2
            a = 1;
        else
            a = 2;
        end
        
        if data.block(n) > 5050
            r = double(rand < data.R(data.s(n),a));
        elseif data.block(n) == 5050
            r = double(rand < .5);
        end
        
        if data.s(n)==2 || data.s(n)==4; r = r-1; end
        data.r(n,1) = r;
        data.a(n,1) = a;
        data.w(n,1) = w;
        
        if r == 0
            L = L + log(1-abs(v(s))) - log(1-abs(q(s,a)));
        else
            L = L + log(abs(v(s))) - log(abs(q(s,a)));
        end
        
        Mv(s) = Mv(s) + 1;
        Mq(s,a) = Mq(s,a) + 1;
        v(s) = v(s) + (r-v(s))/Mv(s);
        q(s,a) = q(s,a) + (r-q(s,a))/Mq(s,a);
        
    end