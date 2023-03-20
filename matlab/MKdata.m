clear;
[a,R]=geotiffread('D:\00BiShe\2data\1RSEIdata\yanmodata\imageToDriveExample2000.tif'); %先导入投影信息
info=geotiffinfo('D:\00BiShe\2data\1RSEIdata\yanmodata\imageToDriveExample2000.tif');
[r,c]=size(a);
cd=21;       %21年，时间跨度  
datasum=zeros(r*c,cd)+NaN; 
k=1;
for year=2000:2020
    filename=['D:\00BiShe\2data\1RSEIdata\yanmodata\imageToDriveExample',int2str(year),'.tif'];
    data=importdata(filename);
    data=reshape(data,r*c,1);
    datasum(:,k)=data;         
    k=k+1;
end
sresult=zeros(r,c)+NaN;
for i=1:size(datasum,1)        
    data=datasum(i,:);
    if min(data)>0       % 有效格点判定，我这里有效值在0以上
        sgnsum=[];  
        for k=2:cd
            for j=1:(k-1)
                sgn=data(k)-data(j);
                if sgn>0
                    sgn=1;
                else
                    if sgn<0
                        sgn=-1;
                    else
                        sgn=0;
                    end
                end
                sgnsum=[sgnsum;sgn];
            end
        end  
        add=sum(sgnsum);
        sresult(i)=add; 
    end
end
vars=cd*(cd-1)*(2*cd+5)/18;
zc=zeros(r,c)+NaN;
sy=find(sresult==0);
zc(sy)=0;
sy=find(sresult>0);
zc(sy)=(sresult(sy)-1)./sqrt(vars);
sy=find(sresult<0);
zc(sy)=(sresult(sy)+1)./sqrt(vars);
filename=['D:\00BiShe\2data\3TheilSenmediandata\mkdata\sdmk.tif'];
geotiffwrite(filename,zc,R,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag); 
