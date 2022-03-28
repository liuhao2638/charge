%以矩阵运算为主，进行求解
function [] = homeChargingPattern(n)  

    init;%获取所有参数
    EV = getHomeEV(n);%生成家庭充电模式下EV信息
    printHomeEV(EV);%显示EV的统计信息
     
    P_basic_home = [P_basic(49:96,1);P_basic(1:48,1)];%家庭模式下以12点作为调度起点,36点作为调度终点
    EV.J_dis=EV.J_c + mod(EV.J_dis-EV.J_c+96,96);%到达时间早于出发时间，视作第二天到达
    EV.J_dis(EV.J_c<=48)=EV.J_dis(EV.J_c<=48)+96;%第一天的1~48时隙视作第二天1~48时隙
    EV.J_c(EV.J_c<=48)=EV.J_c(EV.J_c<=48)+96;%第一天的1~48时隙视作第二天1~48时隙   
    EV.J_dis(EV.J_dis>=49+96)=48+96;%离开时间超出调度时间视作在调度截止前离开
    
    %计算非协调调度下微电网在一天96个时隙下的负载   
    x_min = false(n,96);%保存调度结果
    x_max = false(n,96);
    %计算每个EV满足SOC_max电量和SOC_min电量的结束充电时刻
    J_min_end = min(EV.J_dis,EV.J_c+floor(((EV.SOC_min-EV.SOC_con)*Cap_bat_EV)/(P_mid_EV*eta_EV*Delta_T)));
    J_max_end = min(EV.J_dis,EV.J_c+floor(((EV.SOC_max-EV.SOC_con)*Cap_bat_EV)/(P_mid_EV*eta_EV*Delta_T)));
    for i=1:n
        x_min(i,(EV.J_c(i)-48):(J_min_end(i)-48))=1;
        x_max(i,(EV.J_c(i)-48):(J_max_end(i)-48))=1;
    end
    P_SOC_min = P_basic_home + P_mid_EV*sum(x_min,1)';
    P_SOC_max = P_basic_home + P_mid_EV*sum(x_max,1)';
  
    %计算协调调度下微电网在一天96个时隙下的负载
    %YALMIP建模
    %定义待调度变量
    x = binvar(n,96);
    %计算EV的充电需求
    EV.CUI = (EV.J_dis-EV.J_c)*Delta_T*P_slow_EV*eta_EV-...
        (EV.SOC_min-EV.SOC_con)*Cap_bat_EV;
    P_SOC_crd = P_basic_home;%调度总负载
    SOC_dis = EV.SOC_con;%最终充电量
    %定义约束条件
    c1 = false(n,96);%约束比较矩阵c1，记录x中为定值的点的值为c1中的值
    c2 = false(n,96);%约束矩阵c2，x中为定值的点在c2中为1
    for i = 1:n 
        ev = EV(i,:);%取出EV(i)的信息
        if ev.CUI<0%如果ev为紧急充电需求（第i行为定值，）
            %计算紧急充电需求的充电结束时刻，J_end
            J_end = min(ev.J_dis,ev.J_c+floor(((ev.SOC_max-ev.SOC_con)*Cap_bat_EV)/(P_fast_EV*eta_EV*Delta_T)));
            c1(i,ev.J_c-48:J_end-48)=1;
            c2(i,:)=1;           
            %将其加入总负载
            P_SOC_crd = P_SOC_crd + P_fast_EV * x(i,:)';
        else%如果ev为非紧急充电需求
            c2(i,[1:ev.J_c-48-1 ev.J_dis-48+1:96])=1;
            %将其加入总负载
            P_SOC_crd = P_SOC_crd + P_slow_EV * x(i,:)';
            %表示ev的最终充电量
            SOC_dis(i) = ev.SOC_con + (Delta_T*P_slow_EV*eta_EV/Cap_bat_EV)*sum(x(i,:),2);
        end           
    end
    %添加此约束确保c2矩阵中为1的点的值为c1
    constraint1 = c2.*x==c1;
    %添加此约束确保非紧急充电需求下SOC_dis在SOC_min和SOC_max之间
    constraint2 = EV.SOC_min(EV.CUI>=0)<=SOC_dis(EV.CUI>=0)<=EV.SOC_min(EV.CUI>=0);
        
    %定义目标函数使得负载高峰max(P_SOC_crd)与负载低谷min(P_SOC_crd)之间插值最小
    objective = max(P_SOC_crd)-min(P_SOC_crd);
    
    %定义求解器为cplex
    options = sdpsettings('solver','cplex');
    %求解
    result = solvesdp([constraint1 constraint2],objective,options);
    
    result.info
    yalmiperror(result.problem)
    
    x = double(x);
    P_SOC_crd = double(P_SOC_crd);
    
  
    
    %显示
    f=figure;
    
    bar(12+0.125:0.25:36-0.125,P_basic_home,1);
    hold on;
    stairs(12+0.125:0.25:36-0.125,P_SOC_min);
    hold on;
    stairs(12+0.125:0.25:36-0.125,P_SOC_max);
    hold on;
    stairs(12+0.125:0.25:36-0.125,P_SOC_crd);
    
    set(gca,'xtick',12:2:36); %x轴刻度
    
    %
    
end