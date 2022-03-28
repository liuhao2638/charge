function [EV] = getHomeEV(n)

    init;%获取全局变量
    
    t_c = randn([n 1]);
    t_c = t_c*sigma_1tc + mu_1tc;
    t_c = t_c.*(mu_1tc-12<t_c & t_c<=24)+(t_c-24).*(24<t_c & t_c<=mu_1tc+12);
       
    t_dis = randn([n 1]);
    t_dis = t_dis*sigma_1tdis + mu_1tdis;
    t_dis = t_dis.*(0<t_dis & t_dis<=mu_1tdis+12)+(t_dis+24).*(mu_1tdis-12<t_dis & t_dis<=0);
    
    J_c = ceil(t_c/Delta_T);%向上取整
    J_c(J_c==0) = 96;%0时隙就是昨天的96
    J_dis = floor(t_dis/Delta_T);%向下取整
    J_dis(J_dis==0) = 96;%0时隙就是昨天的96
    
    SOC_con = unifrnd(SOC_con_a,SOC_con_b,n,1);%产生均匀分布的随机数
    SOC_min = unifrnd(SOC_min_a,SOC_min_b,n,1);
    SOC_max = unifrnd(SOC_max_a,SOC_max_b,n,1);
    
    EV = table(t_c,t_dis,J_c,J_dis,SOC_con,SOC_min,SOC_max);  

%     init;%获取全局变量
% 
%     EV = table();  
%     
%     EV.t_c = randn([100000 1]);%保存产生的标准二项分布的随机数样本
%     EV.t_c = EV.t_c*sigma_1tc + mu_1tc;%标准正态分布转为指定正态分布
%     
%     EV.t_dis = randn([100000 1]);%保存产生的标准二项分布的随机数样本
%     EV.t_dis = EV.t_dis*sigma_1tdis + mu_1tdis;%标准正态分布转为指定正态分布
% 
%     %进行数据修正
%     EV(0<EV.t_c)
%     
%     SOC_con = unifrnd(SOC_con_a,SOC_con_b,n,1);%产生均匀分布的随机数
%     SOC_min = unifrnd(SOC_min_a,SOC_min_b,n,1);
%     SOC_max = unifrnd(SOC_max_a,SOC_max_b,n,1);
%     
%     J_c = ceil(EV.t_c/Delta_T);%向上取整
%     J_c(J_c==0) = 96;%0时隙就是昨天的96
%     J_dis = floor(EV.t_dis/Delta_T);%向下取整
%     J_dis(J_dis==0) = 96;%0时隙就是昨天的96
end