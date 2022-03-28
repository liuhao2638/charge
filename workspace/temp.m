    %计算协调调度下微电网在一天96个时隙下的负载
    %YALMIP
    %定义待调度变量
    x = binvar(n,96);
    
    %定义约束条件
    %车辆未接入时的时隙应为0
    c1 = false(n,96);%陷阱矩阵c1，用于探测c1为1的点x是否为0
    for i = 1:n  
        for j = 48+1:48+96              
            %如果EV(i)在j时刻未接入电网
            if ~((EV.J_c(i) <= j) & (j <= EV.J_c(i) + mod(EV.J_dis(i)-EV.J_c(i)+96,96)))              
                  c1(i,j-48)=1;    
            end
        end
    end
    %添加此约束确保未接入时隙x对应值为0
    constraint1 = sum(c1.*x,'all')==0;
    
    %有紧急充电需求的EV，该行为定值
    %计算CUI,EV充电需求
    EV.CUI = mod(EV.J_dis-EV.J_c+96,96)*Delta_T*P_slow_EV*eta_EV-...
            (EV.SOC_min-EV.SOC_con)*Cap_bat_EV;
    %添加此约束确保紧急充电需求的EV对应x整行为定值
    constraint2 = x(EV.CUI<0,:)==~c1(EV.CUI<0,:);

    %对于所有非紧急充电需求的EV，必须SOC充到(SOC_min,SOC_max)之间
    %定义SOC_dis为所有EV最终充电SOC量
    SOC_dis = EV.SOC_con + (Delta_T*P_slow_EV*eta_EV/Cap_bat_EV)*sum(x,2);
    %判断所有非紧急充电需求的EV,SOC_min<=SOC_dis<=SOC_max   
    constraint3 = EV.SOC_min(EV.CUI>=0) <= SOC_dis(EV.CUI>=0) <= EV.SOC_max(EV.CUI>=0);
    
    %定义总约束条件
    %constraints = [constraint1,constraint2,constraint3];
    %constraints = [constraint3];
    constraints = [constraint2,constraint3];
    
    %定义目标函数使得负载高峰max(P_SOC_crd)与负载低谷min(P_SOC_crd)之间插值最小
    %P_SOC_crd(EV.CUI>=0) = P_basic_home(EV.CUI>=0) + sum(x(EV.CUI>=0).*P_slow(EV.CUI>=0),2);
    %P_SOC_crd(EV.CUI <0) = P_basic_home(EV.CUI <0) + sum(x(EV.CUI <0).*P_slow(EV.CUI <0),2);
    P_x = zeros(n,96);
    P_x(EV.CUI>=0,:) = P_x(EV.CUI>=0,:) + x(EV.CUI>=0,:).*P_slow_EV;
    P_x(EV.CUI <0,:) = P_x(EV.CUI <0,:) + x(EV.CUI <0,:).*P_fast_EV;
    
    P_SOC_crd = P_basic_home + sum(P_x,1)';
    objective = max(P_SOC_crd)-min(P_SOC_crd);
    
    %定义求解器为cplex
    ops = sdpsettings('solver','cplex');
    %求解
    solvesdp(constraints,objective,ops);
    
    x = double(x);
    P_x = zeros(n,96);
    P_x(EV.CUI>=0,:) = P_x(EV.CUI>=0,:) + x(EV.CUI>=0,:).*P_slow_EV;
    P_x(EV.CUI <0,:) = P_x(EV.CUI <0,:) + x(EV.CUI <0,:).*P_fast_EV;   
    P_SOC_crd = P_basic_home + sum(P_x,1)';