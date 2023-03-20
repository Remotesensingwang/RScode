[a,R]=geotiffread('D:\00BiShe\2data\1RSEIdata\yanmodata\imageToDriveExample2000.tif'); %先导入投影信息
info=geotiffinfo('D:\00BiShe\2data\1RSEIdata\yanmodata\imageToDriveExample2000.tif');
[r,c]=size(a);
cd=2020-2000+1;%时间跨度
datasum=zeros(r*c,cd)+NaN; 

%21年数据读取与存储
k=1;
for year=2000:2020 %起始年份
    filename=['D:\00BiShe\2data\1RSEIdata\yanmodata\imageToDriveExample',int2str(year),'.tif']; %int2str将整数数据转换为字符串
    data=importdata(filename);
    data=reshape(data,r*c,1);
    datasum(:,k)=data;
    k=k+1;
end

%Theil-Sen median计算
result=zeros(r,c)+NaN;
for i=1:size(datasum,1)
    data=datasum(i,:);
    if min(data)>0     %判断是否是有效值,我这里的有效值必须大于0
        valuesum=[];
        for k1=2:cd
            for k2=1:(k1-1)
                x=data(k1)-data(k2);
                j=k1-k2;
                value=x./j;
                valuesum=[valuesum;value];
            end
        end
        value=median(valuesum);
        result(i)=value;
    end
end

% 数据导出
filename=['D:\00BiShe\2data\3TheilSenmediandata\sd\sdtsm.tif'];
geotiffwrite(filename,result,R,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag)