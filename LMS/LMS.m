
%  Ŀǰ�ð汾Ϊ lms �㷨�� ����mtlab ����ģ��������ź�8khz/16khz����ʵ�ֽϺõ�Ч���� 
%  ����2ͨ��  16Tap/8Tap ��LCMV�㷨��

% lms flow
% 1������w(0)w(0)����1<��<1/��max1<��<1/��max��

% 2���������ֵ��y(k)=w(k)Tx(k)y(k)=w(k)Tx(k);

% 3�����������e(k)=d(k)?y(k)e(k)=d(k)?y(k);

%  4��Ȩ�ظ��£�w(k+1)=w(k)+��e(k)x(k)

close all; clc; clear all;
 
 
Nmic = 2; % mic number 
Nflt = 256; % fir length
Num_c = Nmic*Nflt;
 A_st = zeros(Nflt, 1);   
 
 
[Y_Up,fs1]= audioread('F:/Work/2018/Beamforming/matlab/LMS/A.wav');  % main mic
[Y_Down,fs2]= audioread('F:/Work/2018/Beamforming/matlab/LMS/B.wav'); % ref mic
fs = fs1;
lenS =length(Y_Up);
  
k = 1;
K = 256;
alpha = 0.1;
 
En =zeros(lenS,1); 
Y_LMS =zeros(lenS,1); 
w = zeros(Nmic - 1, K);
 
 En(k:k+Nflt-1) =   Y_Up(k:k+Nflt-1) ;
  
 for k=Nflt:lenS - Nflt+1    
    
     Y_Frame_Block = Y_Down(k-Nflt+1 :k);  
      yB =  Y_Frame_Block' * Y_Frame_Block;       
      
      Y_LMS(k) = A_st'*Y_Frame_Block;   
      err = Y_Up(k) - Y_LMS(k) ;
     % --- lms --- %         
     % update mu
     mu = alpha /yB;   
     A_st = A_st + mu*err*Y_Frame_Block;  
      
     En(k) = err;    
     
 end
   
audiowrite('f:/Work/2018/Beamforming/matlab/LMS/LSM_OUT.wav',Y_LMS,fs);
 audiowrite('f:/Work/2018/Beamforming/matlab/LMS/En.wav',En,fs);
%audiowrite('f:/Work/2018/Beamforming/matlab/LMS/GSC_down.wav',Y_Down,fs);
%audiowrite('f:/Work/2018/Beamforming/matlab/LMS/GSC_B.wav',Y_Block,fs);


