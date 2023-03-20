tic;
clear;clc;close all;
accur=[];%第一列是你计算的，第二列是站点

%%
[a,b]=find(isnan(accur));   %鍘婚櫎绔欑偣寮傚父鍊?(缂烘祴锛?
accur(a,:)=[];
[data_m,~] = size(accur);
    x = accur(:,2); % x是aeronet，第二列
    y = accur(:,1); % y是RTM,第一列
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
% 缁熻鎸囨爣
    x_mean=mean(x); %绔欑偣
    y_mean=mean(y); %妯℃嫙
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
%淇濆瓨鍥剧墖
%     save_Path=strcat('C:\Users\Lenovo\Desktop\code_accuracy\aodcot_daily\accur\','scatterplot_double','.tif');
%     print(figure(1),save_Path,'-dtiff','-r1000');
%  
% disp('end');
% toc;
