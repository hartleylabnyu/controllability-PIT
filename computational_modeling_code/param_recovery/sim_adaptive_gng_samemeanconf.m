function data = sim_adaptive_gng_samemeanconf(param,data)
    
    % Likelihood function for the Adaptive Bayesian model from Dorfman & Gershman (2019, Nature Communications).
    %
    % USAGE: [lik, latents] = lik_adaptive(param,data)
    %
    % INPUTS:
    %   param - parameter vector
    %   data - data structure for single subject
    %
    % OUTPUTS:
    %   lik - log likelihood
    %   latents - structure containing latent variables
    %
    % Sam Gershman, May 2020
    
    bt = param(1);   % inverse temperature
    mvq = param(2);   % prior mean, Pav & instrumental
    pvq = param(3);   % prior confidence, Pav & instrumental
    
    %if nargin > 5
    %    lapse = param(6);
    %else
    lapse = 0;
    %end
    
    if nargin == 6
        b = param(6);
        b2 = b;
    elseif nargin > 6
        b = param(6);
        b2 = param(7);
    else
        b = 0;
        b2 = b;
    end
    
    u = unique(data.s);
    S = length(u);
    
    %controllability of environment changes
    condition_change = find(diff(data.block)~=0) + 1;
    
    w0 = 0.5;
    
    for n = 1:data.N
        
        if n == 1 || n == condition_change

            % initialize data structures
            v = zeros(S,1) + mvq;
            q = zeros(S,2) + mvq;
            Mv = zeros(S,1) + pvq; % same for confidence
            Mq = zeros(S,2) + pvq;
            L = log(w0) - log(1-w0); %initialize L, L is odds of being in uncontrollable environment; if w0=0.5, then L0=0
            if n == condition_change
                b = b2;
            end
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

        %%%%added by noam feb 7 2023%%%%%

            latents.q_diff(n,1) = q(s,1) - q(s,2);	
            latents.q(n,:) = q(s,:);	
            latents.v(n,1) = v(s);	
            latents.w(n,1) = w;	
            latents.d(n,1) = d;	
            latents.P(n,1) = P;	
            latents.L(n,1) = L;
        
    end