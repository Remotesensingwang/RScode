;coding=GB2312
;+
;  《IDL程序设计》
;   -数据可视化与ENVI二次开发
;
; 示例代码
;
; 作者: 董彦卿
;
; 联系方式：sdlcdyq@sina.com
;-
PRO ENVI_Report_Ex
  ;ENVI进度条
  ENVI,/restore_base_save_files
  ENVI_BATCH_INIT
  ;初始化进度条
  ENVI_REPORT_INIT, '数据处理中...', $
    title="ENVI进度条示例", $
    base=base ,/INTERRUPT
  ENVI_REPORT_INC, base, 100 ;百分数
  FOR i=0,29 DO BEGIN
    ENVI_REPORT_STAT,base, i, 90, CANCEL=cancelvar  ;要一致29 29
    ;判断是否点击取消
    IF cancelVar EQ 1 THEN BEGIN
      tmp = DIALOG_MESSAGE('点击了取消'+STRING(i)+'%',/info)
      ENVI_REPORT_INIT, base=base, /finish
      BREAK
    ENDIF
    WAIT,0.1
  ENDFOR
  ENVI_REPORT_INIT, base=base, /finish
  ENVI_BATCH_EXIT
END