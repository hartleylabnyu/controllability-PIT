function [lik, latents] = lik_adaptive_gng_samemeanconf(param,data)
    
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
    
    lik = 0;
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
        c = data.a(n);
        r = data.r(n);
        %P = (1-lapse)*P + lapse/2;
        
        if c==1
            lik = lik + safelog(P);
        else
            lik = lik + safelog(1-P);
        end
        
        if nargout > 1
            latents.q_diff(n,1) = q(s,1) - q(s,2);
            latents.q(n,:) = q(s,:);
            latents.v(n,1) = v(s);
            latents.w(n,1) = w;
            latents.d(n,1) = d;
            latents.P(n,1) = P;
            latents.L(n,1) = L;
            if s > 2
                latents.acc(n,1) = P;
            else
                latents.acc(n,1) = 1-P;
            end
        end
        
        if r == 0
            L = L + log(1-abs(v(s))) - log(1-abs(q(s,c))); 

            %ticket taker: v = .1 and q = -.2
            %log(.9)-log(.8) = .11 pos; more uncontrollable   
        else
            L = L + log(abs(v(s))) - log(abs(q(s,c)));
        end   
            %ticket taker: v = .1 and q = -.2
            %log(.1)-log(abs(-.2)) = -.6, %neg value reflects more
            %controllable even though in this example it should provide
            %evidence of uncontrollability
            
            
            %How is Pav bias expressed for ticket taker when in the
            %positive value domain?
            %Let's say v(s) = .8 and q(s,c)=.6 and r = 0
                %log(1-abs(v(s))) - log(1-abs(q(s,c))
                %log(1-abs(.8)) - log(1-abs(.6)
                %log(.2) - log(.4) = -.69 neg; more controllable
                %When L is more negative, w will be smaller, promoting instrumental behavior.
                %d = (1-w)*q(s,1) - (1-w)*q(s,2) - b - w*v(s);
                %Greater reliance on q values; if q(s,1)>q(s,2), then more likely to no go
                %(no go when d is positive) BUT the positive v(s), even
                %though it's a ticket taker, will take away from that no go
                % and make it more likely to go (even though ticket taker, 
                %the positive v value is contributing to a greater tendency to go
        
        Mv(s) = Mv(s) + 1;
        Mq(s,c) = Mq(s,c) + 1;
        v(s) = v(s) + (r-v(s))/Mv(s);
        q(s,c) = q(s,c) + (r-q(s,c))/Mq(s,c);
        
    end