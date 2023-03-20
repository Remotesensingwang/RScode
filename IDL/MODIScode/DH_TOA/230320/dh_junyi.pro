
pro dh_junyi,dh_toadata_noza,clouddata
;场地均一性控制
    Data0064=dh_toadata_noza[*,*,0]
    sz=dh_toadata_noza[*,*,-6]
    vz=dh_toadata_noza[*,*,-4]
    DIM = SIZE(Data0064,/DIMENSIONS)
    NS = DIM[0]
    NL = DIM[1]



    CloudData = MAKE_ARRAY(NS,NL,VALUE=1,/BYTE) ;;背景值为1
    ;设置非背景值为0
    CloudData[WHERE(Data0064 GT 0 AND Data0064 LT 1)] = 0B
    
    Data0064_std=get_std(dh_toadata_noza[*,*,0],3,3)
    Data0086_std=get_std(dh_toadata_noza[*,*,1],3,3)
    Data0046_std=get_std(dh_toadata_noza[*,*,2],3,3)
    Data0051_std=get_std(dh_toadata_noza[*,*,3],3,3)
    ;  Data0124_std=get_std(Data0124,3,3)
    ;  Data0163_std=get_std(Data0163,3,3)
    ;  Data0230_std=get_std(Data0230,3,3)

    std_nan=WHERE(~FINITE(Data0064_std) or ~FINITE(Data0086_std) or ~FINITE(Data0046_std) or ~FINITE(Data0051_std))
    CloudData[std_nan]=100B
    std_ge=WHERE(Data0064_std ge 0.05 or Data0086_std ge 0.05 or Data0046_std ge 0.05 or Data0051_std ge 0.05)
    CloudData[std_ge]=150B
    ;angle=where(sz ge 40 or vz ge 40)
    angle=where(vz ge 40)
    CloudData[angle]=200B
end