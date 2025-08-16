% 参数初始化
alpha = [0.2194, 0.0719, -0.3347, -0.3264, 0.3418, 0.4191, 0.0346, 0.2588];  % 假设值
beta = [-0.0499, -0.1163, 0.2017, 0.4622, -0.0418, -0.2373, 0.3795, 0.1223];  % 假设值
C = [11.0746, 12.4969, 10.8886, 11.2106, 10.4325, 9.4972, 10.9627, 10.7991];  % 假设值
K0 = [0.125, 0.125, 0.125,0.125, 0.125,0.125,0.125, 0.125];  % 初始资本投入
L = [438.5, 4268.1, 1638.1, 782.4, 767.9, 288.4, 692.4, 509.4];  % 劳动投入（常量）
Delta_K_sum = 1;  % 总资本增量

% 假设各个部门的利润 P（可以根据实际数据进行调整）
P = [0.1, 0.05, 0.3, 0.1, 0.15, 0.05, 0.05, 0.05];  % 各个部门的利润 P

% 目标函数：最大化 GDP 增量和总利润
objective_GDP = @(x) -sum(exp(alpha .* log(K0 + x) + beta .* log(L) + C) - exp(alpha .* log(K0) + beta .* log(L) + C));  % 最大化 GDP 增量
objective_profit = @(x) -sum((x / Delta_K_sum) .* P);  % 最大化总利润

% 总目标函数：加权和
objective = @(x, w1, w2) w1 * objective_GDP(x) + w2 * objective_profit(x);

% 约束：资本增量总和为 Delta_K_sum
constraint = @(x) sum(x) - Delta_K_sum; 

% 设置遗传算法参数
nvars = 8;  % 变量数量，即资本增量的维度（每个行业一个资本增量）
lb = zeros(1, nvars);  % 资本增量不能为负
ub = [];  % 没有上界
options = optimoptions('ga', 'Display', 'iter', 'PopulationSize', 100, 'MaxGenerations', 100);

% 选择目标函数权重
w1 = 0.5;  % GDP 权重
w2 = 0.5;  % 总利润权重

% 调用遗传算法函数求解
[x_opt, fval] = ga(@(x) objective(x, w1, w2), nvars, [], [], [], [], lb, ub, @(x) deal([], constraint(x)), options);

% 计算最优的 GDP 增量和利润
GDP_j1 = exp(alpha .* log(K0 + x_opt) + beta .* log(L) + C);  % 计算每个行业的新 GDP
GDP_j0 = exp(alpha .* log(K0) + beta .* log(L) + C);  % 计算每个行业的初始 GDP
Delta_GDP = GDP_j1 - GDP_j0;  % 每个行业的 GDP 增量

% 输出每个行业的 GDP 增量
disp('每个行业的 GDP 增量：');
disp(Delta_GDP);

% 计算每个行业的利润
P_j = (x_opt / Delta_K_sum) .* P;  % 每个行业的利润
disp('每个行业的利润：');
disp(P_j);

% 输出每个行业的 GDP 增量和利润的加权和
disp('总 GDP 增量：');
disp(sum(Delta_GDP));  % 总 GDP 增量
disp('总利润：');
disp(sum(P_j));  % 总利润

% 输出最优资本增量
disp('最优资本增量：');
disp(x_opt);

% 输出优化后的 GDP 增量和总利润的加权和
disp('优化后的 GDP 增量和总利润的加权和：');
disp(-fval);  % 由于目标函数是负值，输出时再取负值

% 输出每个行业的投资额分配（即每个行业的资本增量占总资本增量的比例）
investment_share = (x_opt / Delta_K_sum) * 100;  % 转换为百分比
disp('每个行业的投资额分配（百分比）：');
disp(investment_share);  % 输出每个行业的投资百分比

% 绘制每个行业的投资额分配（即每个行业的资本增量相对于总投资额的比例）
figure;
pie(investment_share, {'行业1', '行业2', '行业3', '行业4', '行业5', '行业6', '行业7', '行业8'});
title('每个行业的投资额分配');
