%统计公共充电模式下EV信息表
function [] = printPublicEV(EV)

  
    init;%获取全局变量
    
    f = figure;%生成图窗
    sgtitle('公共充电模式EV信息');%图标题
    set(gcf,'position',[250 100 1000 600]);%设置图窗大小
    

    %绘制以15分钟为间隔计数的EV到达时刻频数分布直方图
    subplot(2,3,1);
    N = zeros(96,1);
    C = tabulate(EV.J_c(:));%对每个元素进行统计
    N(C(:,1))=N(C(:,1))+C(:,2);
    bar(1-0.5:1:96-0.5,N,1);%绘图
    
    title('EV接入时隙频数直方图');%图标题
    xlabel('Arrival time slots');%x轴单位
    ylabel('frequency ');  %y轴单位
    set(gca,'xtick',0:12:96); %x轴刻度
    
    %绘制以1小时为间隔计数的EV到达时刻的频率分布直方图,并叠加画出家庭充电模式的概率密度函数 
    subplot(2,3,2);
    
    N = histcounts(EV.t_c,0:1:24);%按照一个小时的区间计数，赋给N
    bar(0.5:1:23.5,N/sum(N),1);%显示直方图
    hold on;
    %画出公共充电模式的概率密度函数 
    x = [0.001:0.001:24];%采样密度
    y = normpdf(x,mu_2tc,sigma_2tc).*( 0<x & x<=mu_2tc+12 )+...
        normpdf(x-24,mu_2tc,sigma_2tc).*( mu_2tc+12<x & x<=24 );
    plot(x,y,"LineWidth",2,"Color","red");%画粗的红线
       
    title('EV接入时刻频率直方图');%图标题
    xlabel('Arrival time (h)');%x轴单位
    ylabel('probability');  %y轴单位
    %set(gca,'xtick',0:1:24); %x轴刻度
    legend('Collected Data','PDF');%增加图例
    legend('Location','northeast');%图例放在右上角
    %set(gca,'position',[0.41,0.55,0.28,0.37]);
       
    %绘制电池状态的频率分布直方图，并叠加画出对应概率密度函数
    subplot(2,3,[3 6]);
    scatter(1:size(EV),EV.SOC_con,'filled');
    hold on;
    scatter(1:size(EV),EV.SOC_min,'filled');
    hold on;
    scatter(1:size(EV),EV.SOC_max,'filled');
    hold on;
    
    title('EV接入时电池剩余SOC频率直方图');%图标题
    ylabel('SOC (%)'); %x轴单位
    xlabel('i-th EV');  %y轴单位
    %xlim([-10,size(EV)+10]);%对X轴设定显示范围   
    legend('con','min','max');%增加图例
    legend('Location','northwest');%图例放在左上角
    %set(gca,'position',[0.74,0.08,0.24,0.84]);
    
    %绘制以15分钟为间隔计数的EV离开时刻频数分布直方图
    subplot(2,3,4);
    N = zeros(96,1);
    C = tabulate(EV.J_dis(:));%对每个元素进行统计
    N(C(:,1))=N(C(:,1))+C(:,2);
    bar(1-0.5:1:96-0.5,N,1);%绘图
    
    title('EV离开时隙频数直方图');%图标题
    xlabel('Departure time slots');%x轴单位
    ylabel('frequency ');  %y轴单位
    set(gca,'xtick',0:12:96); %x轴刻度
    %set(gca,'position',[0.05,0.08,0.30,0.37]);
    
    %绘制以1小时为间隔计数的EV离开时刻的频率分布直方图,并叠加画出家庭充电模式的概率密度函数 
    subplot(2,3,5);
    
    N = histcounts(EV.t_dis,0:1:24);%按照一个小时的区间计数，赋给N
    bar(0.5:1:23.5,N/sum(N),1);%显示直方图
    hold on;
    %画出公共充电模式的概率密度函数 
    x = [0.01:0.01:24];
    y = normpdf(x,mu_2tdis,sigma_2tdis).*( mu_2tdis-12<x & x<=24 )+...
        normpdf(x+24,mu_2tdis,sigma_2tdis).*( 0<x & x<=mu_2tdis-12 );
    plot(x,y,"LineWidth",2,"Color","red");
      
    title('EV接入时刻频率直方图');%图标题
    xlabel('Departure time (h)');%x轴单位
    ylabel('probability');  %y轴单位
    %set(gca,'xtick',0:1:24); %x轴刻度
    legend('Collected Data','PDF');%增加图例
    legend('Location','northwest');%图例放在左上角
    %set(gca,'position',[0.41,0.08,0.28,0.37]);
    
    hold off;
    
end