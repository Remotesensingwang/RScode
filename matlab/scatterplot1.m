
tic;
clear;clc;close all;
load 'D:\Experiment_5\AERONET\result\global\inconstant\original_global.mat';
load 'D:\Experiment_5\AERONET\mat\inversion_measurement\station14\invesion_measurement_14.mat';
load 'D:\Experiment_5\AERONET\mat\inversion_measurement\station14\invesion_measurement_adj_colname.mat';
load 'D:\Experiment_5\AERONET\mat\inversion_measurement\station14\all_valid_stations_14.mat';
%����վ��
rtm=original_global{14};%!!!!!
st=invesion_measurement_14{14}(:,20);%!!!!!
mer=[rtm,st];
mer1=mer(find(mer(:,1)<999),:);
%����վ��Ͳ�
rtm=[];
st=[];
for i=1:9
 rtm=[rtm;original_global{i}];
 st=[st;invesion_measurement_14{i}(:,20)]; 
end
for i=11:14
 rtm=[rtm;original_global{i}];
 st=[st;invesion_measurement_14{i}(:,20)]; 
end
mer=[rtm,st];
aa=mer(find(mer(:,1)>999),:);
%%
 tic;
 clear;clc;close all;
accur=[];
accur=mer;
accur=accur(find(accur(:,1)<999),:);

%%
[a,b]=find(isnan(accur));   %去除站点异常�?(缺测�?
accur(a,:)=[];
[data_m,~] = size(accur);
    x = accur(:,2); % x��aeronet���ڶ���
    y = accur(:,1); % y��RTM,��һ��
    xmax = max(accur(:,2));  % adjust according to the situation
    ymax = max(accur(:,1));
    xmin = 44;  % adjust according to the situation
    ymin = 39;
    if xmax>ymax
        max = xmax-mod(xmax,100)+100;
    else
        max = ymax-mod(ymax,100)+100; 
    end
    if xmin<ymin
        min = xmin-mod(xmin,10);
    else
        min = ymin-mod(ymin,10); 
    end
    hold on
    scatplot(x,y,'circles',sqrt((range(x)/30)^2 + (range(y)/30)^2),100,5,1,10);
    p = polyfit(x,y,1); % obtain the fitting coefficient after fitting
    x1 = x;
    y1 = polyval(p,x1);
    plot(x1,y1,'color',[0.8039 0 0],'LineWidth',1)
% drawing 1:1 line
     x2 = linspace(0,max,max/10);
     y2 = x2;
     plot(x2,y2,'k','LineWidth',1)
% X- and Y-axis label text and image title
    xlabel('AERONET (W m^{-2})','fontsize',11,'fontname','Times New Roman');
    ylabel('RTM (W m^{-2})','fontsize',11,'fontname','Times New Roman');
    title('XiangHe');
% 统计指标
    x_mean=mean(x); %站点
    y_mean=mean(y); %模拟
    R = (sum((y-y_mean).*(x-x_mean)))./(sqrt(sum((y-y_mean).^2).*sum((x-x_mean).^2))); 
    R2 = R*R; 
    RMSE = sqrt((sum((x-y).^2))/data_m);
    RMSPE = sqrt((sum(((x-y)./x).^2))/data_m)*100; %RMSPE
    MAE = sum(abs(y-x))/data_m; %MAE
    MAPE = sum(abs((y-x)./x))/data_m*100; %MPE
% adjust legend
    text(max-1.05*xmax,max-0.25*ymax,[sprintf('Fit:Y=%0.2fX+%0.2f\n',p(1),p(2)),...
                                sprintf('N=%d     ',data_m),sprintf('R^2=%0.4f\n',R2),...
                                sprintf('RMSE=%0.2f (%0.2f%%)\n',RMSE,RMSPE),...
                                sprintf('MAE=%0.2f (%0.2f%%)\n',MAE,MAPE)],...
                                'fontsize',11,'fontname','Times New Roman')
    set(gca,'xlim',[min,max],'ylim',[min,max])
%保存图片
%     save_Path=strcat('C:\Users\Lenovo\Desktop\code_accuracy\aodcot_daily\accur\','scatterplot_double','.tif');
%     print(figure(1),save_Path,'-dtiff','-r1000');
%  
% disp('end');
% toc;
