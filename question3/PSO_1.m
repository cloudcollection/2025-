% Parameters Initialization
alpha = [0.2194, 0.0719, -0.3347, -0.3264, 0.3418, 0.4191, 0.0346, 0.2588];
beta = [-0.0499, -0.1163, 0.2017, 0.4622, -0.0418, -0.2373, 0.3795, 0.1223];
C = [11.0746, 12.4969, 10.8886, 11.2106, 10.4325, 9.4972, 10.9627, 10.7991];
K0 = [1250, 1250, 1250, 1250, 1250, 1250, 1250, 1250];
L = [438.5, 4268.1, 1638.1, 782.4, 767.9, 288.4, 692.4, 509.4];
Delta_K_sum = 10000;

% Problem Dimensions
n = length(alpha); % Number of sectors


% 定义最小资本增量
min_increment = Delta_K_sum / n * 0.05; % 每个行业至少获得总增量的5%

% Objective Function with Penalty
objFun = @(w) computeObjectiveWithPenalty(w, alpha, beta, C, K0, L, Delta_K_sum);

% PSO Setup
lb = zeros(n, 1); % Lower bound (0)
ub = ones(n, 1);  % Upper bound (1)

% PSO Options
options = optimoptions('particleswarm', 'Display', 'iter', 'SwarmSize', 100, 'MaxIterations', 200);

% Solve using Particle Swarm Optimization
[w_opt, fval] = particleswarm(objFun, n, lb, ub, options);

% Compute Detailed Results
[delta_gdp_per_sector, total_delta_gdp] = computeDeltaGDP(w_opt, alpha, beta, C, K0, L, w_opt .* Delta_K_sum / sum(w_opt));

% Display Results
disp('Optimal selection of sectors (w):');
disp(w_opt);
disp('Capital allocated to each sector (Delta_K):');
disp(w_opt .* Delta_K_sum / sum(w_opt));
disp('GDP change per sector (Delta_GDP):');
disp(delta_gdp_per_sector);
disp('Total GDP change:');
disp(total_delta_gdp);

% Objective Function with Penalty
function penalty = computeObjectiveWithPenalty(w, alpha, beta, C, K0, L, Delta_K_sum)
    % Compute ΔGDP
    [~, total_delta_gdp] = computeDeltaGDP(w, alpha, beta, C, K0, L, w .* Delta_K_sum / sum(w));
    
    % Total penalty
    penalty = -total_delta_gdp; % Minimize negative ΔGDP
end

% Compute ΔGDP for each sector
function [delta_gdp_per_sector, total_delta_gdp] = computeDeltaGDP(w, alpha, beta, C, K0, L, delta_k)
    n = length(w); % Number of sectors
    delta_gdp_per_sector = zeros(1, n); % Preallocate ΔGDP per sector
    total_delta_gdp = 0; % Initialize total ΔGDP
    
    for j = 1:n
        if w(j) > 0
            K1 = K0(j) + delta_k(j); % New capital after allocation
            GDP1 = exp(alpha(j) * log(K1) + beta(j) * log(L(j)) + C(j)); % GDP after allocation
            GDP0 = exp(alpha(j) * log(K0(j)) + beta(j) * log(L(j)) + C(j)); % Original GDP
            delta_gdp_per_sector(j) = GDP1 - GDP0; % Change in GDP for sector j
            total_delta_gdp = total_delta_gdp + delta_gdp_per_sector(j); % Accumulate total ΔGDP
        end
    end
end

% Plotting function (defined after all script code)
function drawPlots(w_opt, delta_gdp_per_sector, Delta_K_sum)
    % Create a figure for plotting
    figure;

    % Bar chart for capital allocation per sector
    subplot(2, 1, 1); % Create a subplot in the first row
    bar(w_opt .* Delta_K_sum / sum(w_opt)); % Draw bar chart for Delta_K
    title('Capital Allocated to Each Sector');
    xlabel('Sector Index');
    ylabel('Capital Allocation');

    % Bar chart for GDP change per sector
    subplot(2, 1, 2); % Create a subplot in the second row
    bar(delta_gdp_per_sector); % Draw bar chart for Delta_GDP
    title('GDP Change Per Sector');
    xlabel('Sector Index');
    ylabel('GDP Change');

    % Adjust layout to prevent overlap
    tight_layout;
end

