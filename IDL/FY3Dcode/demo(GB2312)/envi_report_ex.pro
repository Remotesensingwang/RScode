;coding=GB2312
;+
;  ��IDL������ơ�
;   -���ݿ��ӻ���ENVI���ο���
;
; ʾ������
;
; ����: ������
;
; ��ϵ��ʽ��sdlcdyq@sina.com
;-
PRO ENVI_Report_Ex
  ;ENVI������
  ENVI,/restore_base_save_files
  ENVI_BATCH_INIT
  ;��ʼ��������
  ENVI_REPORT_INIT, '���ݴ�����...', $
    title="ENVI������ʾ��", $
    base=base ,/INTERRUPT
  ENVI_REPORT_INC, base, 100 ;�ٷ���
  FOR i=0,29 DO BEGIN
    ENVI_REPORT_STAT,base, i, 90, CANCEL=cancelvar  ;Ҫһ��29 29
    ;�ж��Ƿ���ȡ��
    IF cancelVar EQ 1 THEN BEGIN
      tmp = DIALOG_MESSAGE('�����ȡ��'+STRING(i)+'%',/info)
      ENVI_REPORT_INIT, base=base, /finish
      BREAK
    ENDIF
    WAIT,0.1
  ENDFOR
  ENVI_REPORT_INIT, base=base, /finish
  ENVI_BATCH_EXIT
END