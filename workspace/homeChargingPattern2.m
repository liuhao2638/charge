%FOR循环运算为主，进行求解,排除了起止时间不在调度时间的EV
function [] = homeChargingPattern2(n)

    init;%获取所有参数

    EV = getHomeEV(n);%生成家庭充电模式下EV信息
    %printHomeEV(EV);%显示EV的统计信息
     
    P_basic_home = [P_basic(49:96,1);P_basic(1:48,1)];%家庭模式下以12点作为调度起点,36点作为调度终点
    EV.J_dis=EV.J_c + mod(EV.J_dis-EV.J_c+96,96);%到达时间早于出发时间，视作第二天到达
    EV(EV.J_c<=48 | EV.J_dis>=49+96,:)=[];
    [n,~]=size(EV);
    
    
    %计算非协调调度下微电网在一天96个时隙下的负载
    
    P_SOC_min = P_basic_home;%初始化电网负荷
    P_SOC_max = P_basic_home;
    SOC_dis = EV.SOC_con;%保存当前SOC值
    for j = 1:96%家庭充电模式的调度从第一天12点到次日12点    
        for i = 1:n             
            %如果EV(i)在j时刻接入电网
            if EV.J_c(i) <= j+48 && j+48<= EV.J_dis(i)               
                if (SOC_dis(i) < EV.SOC_min(i))%如果电池SOC_con没到SOC_min
                    %P_SOC_min在j时隙增加一个负载
                    P_SOC_min(j,1) = P_SOC_min(j,1) + P_mid_EV;
                end
                if (SOC_dis(i) < EV.SOC_max(i))%如果电池SOC_con没到SOC_max
                    %P_SOC_max在j时隙增加一个负载
                    P_SOC_max(j,1) = P_SOC_max(j,1) + P_mid_EV;
                    %EV(i)在j时隙充电
                    SOC_dis(i) = SOC_dis(i) + Delta_T*eta_EV*P_mid_EV/Cap_bat_EV;
                end                       
            end
        end
    end
    
    
    
    %计算协调调度下微电网在一天96个时隙下的负载
    %YALMIP   
    x = binvar(n,96);%定义求解变量
    constraints = [];%定义约束条件     
    P_SOC_crd = P_basic_home;%调度总负载
    %计算EV的充电需求
    EV.CUI = (EV.J_dis-EV.J_c)*Delta_T*P_slow_EV*eta_EV-...
        (EV.SOC_min-EV.SOC_con)*Cap_bat_EV;
    for i = 1:n  
        ev = EV(i,:);%取出EV(i)的信息
        for j = 1:96              
            %如果EV(i)在j时刻未接入电网,则EV(i)在j时隙的x值应为0
            if ~(ev.J_c <= j+48 && j+48 <= ev.J_dis)          
                  constraints = [constraints,x(i,j)==0];    
            end         
        end
        
        %如果EV(i)有紧急充电需求
        if EV.CUI(i)<0
            %计算紧急充电需求的充电结束时刻，J_end
            J_end = min(ev.J_dis,ev.J_c+floor(((ev.SOC_max-ev.SOC_con)*Cap_bat_EV)/(P_fast_EV*eta_EV*Delta_T)));
            for j = 1:96
                if ev.J_c<=j+48 && j+48 <= J_end
                    constraints = [constraints,x(i,j)==1];
                else
                    constraints = [constraints,x(i,j)==0];
                end  
            end
            %将其加入总负载
            P_SOC_crd = P_SOC_crd + P_fast_EV * x(i,:)';
        %如果EV(i)有非紧急充电需求
        else
            SOC_dis = ev.SOC_con + (Delta_T*P_slow_EV*eta_EV/Cap_bat_EV) * sum(x(i,:),'all');
            constraints = [constraints,ev.SOC_min <= SOC_dis <= ev.SOC_max];
            
            %将其加入总负载
            P_SOC_crd = P_SOC_crd + P_slow_EV * x(i,:)';            
        end
    end
    
    %定义目标函数使得负载高峰max(P_SOC_crd)与负载低谷min(P_SOC_crd)之间插值最小
    objective = max(P_SOC_crd)-min(P_SOC_crd);
    
    %定义求解器为cplex
    options = sdpsettings('solver','cplex');
    %求解
    result = solvesdp(constraints,objective,options);
    
    result.info
    yalmiperror(result.problem)
    
    x = double(x);
    P_SOC_crd = double(P_SOC_crd);

    
    %显示
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