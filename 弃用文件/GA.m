% 参数初始化
alpha = [0.2194, 0.0719, -0.3347, -0.3264, 0.3418, 0.4191, 0.0346, 0.2588];  % 假设值
beta = [-0.0499, -0.1163, 0.2017, 0.4622, -0.0418, -0.2373, 0.3795, 0.1223];  % 假设值
C = [11.0746, 12.4969, 10.8886, 11.2106, 10.4325, 9.4972, 10.9627, 10.7991];  % 假设值
K0 = [1250, 1250, 1250, 1250, 1250, 1250, 1250, 1250];  % 初始资本投入
L = [438.5, 4268.1, 1638.1, 782.4, 767.9, 288.4, 692.4, 509.4];  % 劳动投入（常量）
Delta_K_sum = 10000;  % 总资本增量

% 假设各个部门的利润 P（可以根据实际数据进行调整）
P = rand(1, 8);  % 随机生成部门利润 P，实际中应根据数据提供

% 目标函数：最大化 GDP 增量和总利润
% 使用加权和的方法，权重可以调整
objective_GDP = @(x) -sum(exp(alpha .* log(K0 + x) + beta .* log(L) + C) - exp(alpha .* log(K0) + beta .* log(L) + C));  % 最大化 GDP 增量
objective_profit = @(x) -sum((x / Delta_K_sum) .* P);  % 最大化总利润

% 总目标函数：加权和
objective = @(x, w1, w2) w1 * objective_GDP(x) + w2 * objective_profit(x);

% 约束：资本增量总和为 Delta_K_sum
constraint = @(x) sum(x) - Delta_K_sum; 

% 初始猜测：假设所有资本增量为 0
x0 = zeros(1, 8);

% 设置约束和边界条件
lb = zeros(1, 8);  % 资本增量不能为负
ub = [];  % 没有上界

% 使用 fmincon 求解优化问题
options = optimoptions('fmincon', 'Display', 'iter', 'Algorithm', 'sqp');
[w1, w2] = deal(0.5, 0.5);  % 设置目标函数的权重

% 调用 fmincon 求解
[x_opt, fval] = fmincon(@(x) objective(x, w1, w2), x0, [], [], [], [], lb, ub, @(x) deal([], constraint(x)), options);

% 输出结果
disp('最优资本增量：');
disp(x_opt);
disp('优化后的 GDP 增量和总利润的加权和：');
disp(-fval);  % 由于目标函数是负值，输出时再取负值
