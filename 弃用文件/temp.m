% 参数初始化
alpha = [0.2194 , 0.0719, -0.3347, -0.3264,  0.3418 , 0.4191, 0.0346, 0.2588]; % 假设值
beta = [ -0.0499, -0.1163, 0.2017,  0.4622,-0.0418 ,  -0.2373, 0.3795  , 0.1223];  % 假设值
C = [11.0746, 12.4969, 10.8886, 11.2106,  10.4325,  9.4972, 10.9627, 10.7991];      % 假设值
K0 = [1250,1250,1250,1250,1250,1250,1250,1250];      % 初始资本投入
L = [438.5, 4268.1, 1638.1, 782.4, 767.9, 288.4, 692.4, 509.4];            % 劳动投入（常量）
Delta_K_sum = 10000;                                       % 总资本增量

% 决策变量：Delta_K
n = length(K0); % 行业数量

% 定义最小资本增量
min_increment = Delta_K_sum / n * 0.1; % 每个行业至少获得总增量的10%

% 初始化线性约束矩阵和右端值
A = []; 
b = []; 
lb = min_increment * ones(n, 1); % 决策变量下界（每个行业至少获得最小增量）
ub = []; 

% 定义非线性目标函数
objective = @(Delta_K) -sum(arrayfun(@(j) ...
    exp(alpha(j) * log(K0(j) + Delta_K(j)) + beta(j) * log(L(j)) + C(j)) ...
    - exp(alpha(j) * log(K0(j)) + beta(j) * log(L(j)) + C(j)), ...
    1:n));

% 定义线性约束（总资本增量约束）
Aeq = ones(1, n);
beq = Delta_K_sum;

% 求解非线性规划问题
options = optimoptions('fmincon', 'Display', 'iter', 'Algorithm', 'sqp');
Delta_K_opt = fmincon(objective, lb, A, b, Aeq, beq, lb, ub, [], options);

% 输出结果
disp('最优资本增量分配：');
disp(Delta_K_opt);

% 计算各行业的 GDP 增量
Delta_GDP = arrayfun(@(j) ...
    exp(alpha(j) * log(K0(j) + Delta_K_opt(j)) + beta(j) * log(L(j)) + C(j)) ...
    - exp(alpha(j) * log(K0(j)) + beta(j) * log(L(j)) + C(j)), ...
    1:n);

disp('各行业的 GDP 增量：');
disp(Delta_GDP);

disp('总 GDP 增量：');
disp(sum(Delta_GDP));