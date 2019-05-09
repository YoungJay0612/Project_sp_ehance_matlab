% Subband freq domain NLMS algorithm
% 频域NLMS, 验证能起到降噪效果, 声音正常， 而且降噪效果要好于时域NLMS  NFFT = 1024时效果较好，低于该值效果差。
 
%fin0 = 'D:\F_Drive\Work\2018\Beamforming\matlab\voice\T16L';
%fin1 = 'D:\F_Drive\Work\2018\Beamforming\matlab\voice\T16R';
fin0 = '..\..\voice\T164L';
fin1 = '..\..\voice\T164R';
  
fout = [fin0 'SubFreqNLMSEn'];
fout1 = [fin0 'B'];

omega = 0.01; 
alpha = 0.02;
NFFT = 1024;
OVERLAP = NFFT/2;

window = hanning(NFFT);

[Y_L,fs1]= audioread([fin0 '.wav']); % main mic
[Y_R,fs2]= audioread([fin1 '.wav']); % ref mic

fs = fs1;

Y_Up   =  Y_L;% 0.5 * (Y_L + Y_R);
Y_Down =  Y_R;% Y_L - Y_R;

L1 = length(Y_Up);
L2 = length(Y_Down);

Len = min(L1,L2);

InitFrame = 1;
EndFrame = InitFrame+ NFFT-1;
Pest = zeros(NFFT,1);
G = zeros(NFFT,1);
Nlms = zeros(NFFT,1);
Nlms_T =   zeros(Len,1);
A_T =   zeros(Len,1);
B_T =   zeros(Len,1);
His_A = zeros(OVERLAP,1);
His_B = zeros(OVERLAP,1);
His_Nlms = zeros(OVERLAP,1);
 
Out = zeros(NFFT,1);
Out_T = zeros(Len,1);
His_Out = zeros(OVERLAP,1);

FrameNO = 1;

 
while (EndFrame < Len)
    
    Frame1 =   Y_L(InitFrame:EndFrame); % Y_Up(InitFrame:EndFrame);
    Frame2 =   Y_R(InitFrame:EndFrame); %Y_Down(InitFrame:EndFrame);
    
     X1 = fft(window .* Frame1);
     X2 = fft(window .* Frame2);
       
     X_lms =  G.* X2;
          
     En = X1 - X_lms;
     
     Pest = omega * Pest + (1-omega) * abs(X2).^2;     
     
     mu = alpha ./ Pest;
    
     G = G + mu .* En .* conj( X2)  ;
     
     A_up = ifft(X1);
     B_down = ifft(X2);
 
     Nlms = ifft(X_lms);
     Out  = ifft(En);
     
     Out_T((FrameNO-1)*OVERLAP+1 : FrameNO*OVERLAP) = Out(1:OVERLAP) + His_Out;
     His_Out = Out(OVERLAP+1 : NFFT);
     
     Nlms_T((FrameNO-1)*OVERLAP+1 : FrameNO*OVERLAP) = Nlms(1:OVERLAP) + His_Nlms;
     His_Nlms = Nlms(OVERLAP+1 : NFFT);
      
      
    FrameNO = FrameNO +1;
    InitFrame = InitFrame+OVERLAP;
    EndFrame = EndFrame+ OVERLAP;
    
end

 audiowrite([fout '_e.wav'],Out_T,fs);
 
 
  fprintf('End of freq nlms\n');
  
 
