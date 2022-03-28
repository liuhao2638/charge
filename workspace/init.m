 
%为全局提供所有需要的参数
mu_1tc = 18;    sigma_1tc = 3.3;%论文中EV四个正态分布的参数 
mu_1tdis = 8;   sigma_1tdis = 3.24;    
mu_2tc = 8.5;   sigma_2tc = 3.3;
mu_2tdis = 17.5;sigma_2tdis = 3.24; 

Delta_T = 0.25;        %时隙(四分之一个小时)

SOC_con_a = 0.1; SOC_con_b = 0.3;%EV汽车电量服从均匀分布的参数
SOC_min_a = 0.4; SOC_min_b = 0.6;
SOC_max_a = 0.8; SOC_max_b = 1.0;

P_slow_EV = 3.5;       %慢速充电功率KW
P_mid_EV = 3.5;          %非协调充电策略充电功率KW
P_fast_EV = 10;        %快速充电功率KW

Cap_bat_EV = 30;       %EV电池容量(KW/H)
eta_EV = 0.9;          %充电效率

P_basic = xlsread('basicLoadData.xls');%96个时隙的基本负载数据
