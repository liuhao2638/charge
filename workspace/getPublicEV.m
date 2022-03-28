function [EV] = getPublicEV(n)  

    init;%获取全局变量
    
    t_c = randn([n 1]);
    t_c = t_c*sigma_2tc + mu_2tc;
    t_c = t_c.*(0<t_c & t_c<=mu_2tc+12)+(t_c+24).*(mu_2tc-12<t_c & t_c<=0);
    
    t_dis = randn([n 1]);
    t_dis = t_dis*sigma_2tdis + mu_2tdis;
    t_dis = t_dis.*(mu_2tdis-12<t_dis & t_dis<=24)+(t_dis-24).*(24<t_dis & t_dis<=mu_2tdis+12);
    
    J_c = ceil(t_c/Delta_T);%向上取整
    J_c(J_c==0) = 96;%0时隙就是昨天的96
    J_dis = floor(t_dis/Delta_T);%向下取整
    J_dis(J_dis==0) = 96;%0时隙就是昨天的96
    
    SOC_con = unifrnd(SOC_con_a,SOC_con_b,n,1);%产生均匀分布的随机数
    SOC_min = unifrnd(SOC_min_a,SOC_min_b,n,1);
    SOC_max = unifrnd(SOC_max_a,SOC_max_b,n,1);
    
    EV = table(t_c,t_dis,J_c,J_dis,SOC_con,SOC_min,SOC_max);   
   
end
    