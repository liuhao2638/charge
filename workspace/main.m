clear;
%显示生成的EV车的分布情况
EV = getHomeEV(1000000);printHomeEV(EV);%家庭充电模式
EV = getPublicEV(1000000);printPublicEV(EV);%公共充电模式

%家庭充电模式下的调度模拟(一行为一个实验)
EV = getHomeEV(100);homeChargingPattern3(EV);
EV = getHomeEV(200);homeChargingPattern3(EV);
EV = getHomeEV(300);homeChargingPattern3(EV);
EV = getHomeEV(1000);homeChargingPattern3(EV);
%公共充电模式下的调度模拟
EV = getPublicEV(100);publicChargingPattern(EV);
EV = getPublicEV(200);publicChargingPattern(EV);
EV = getPublicEV(300);publicChargingPattern(EV);
EV = getPublicEV(1000);publicChargingPattern(EV);