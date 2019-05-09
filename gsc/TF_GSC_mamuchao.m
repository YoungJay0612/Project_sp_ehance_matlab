%function [FBFOutput,Output] = TF_GSC_mamuchao(x,fs,DesAng,NFFT,mu,forgottor)
% ����˵�����˰汾Ϊû�м��뷽��ƫ��F�İ汾
% ����˵�� mu,forgottor,threhod,fs,desAngle
% x:�����ź� M*L Ĭ����1000�����ݽ���һ��
% win:������
% overlap:����
% NFFT:֡��
% Iden_NFFT:
% mu:�ݶ��½�����
% forgottor: �������ӣ�Pest��ȡʱʹ��
% fs:������
% DesAng:���������  Ŀǰû���õ�
fin0 = './voice/t10';
fA   = [fin0 '_TFGSC_A.wav'];
fB   = [fin0 '_TFGSC_B.wav'];
fN   = [fin0 '_TFGSC_N.wav'];
fOut = [fin0 '_TFGSC_OUT'];
forgottor = 0.95;
mu = 0.01;
NFFT = 1024;
[x,fs1]= audioread([fin0 '.wav']); % main mic
 
x = x';

fs = 16000;
DesAng = [180 ];

%MArray = 0.0425*[1,0;1/2,sqrt(3/4);-1/2,sqrt(3)/2;-1,0;-1/2,-sqrt(3)/2;1/2,-sqrt(3)/2];
MArray=0.05*[ -0.5;0.5 ];
% MArray=0.05*[-2.5,0;-1.5,0;-0.5,0;0.5,0;1.5,0;2.5,0];
% MArray=0.05*[0;1;2;3;4;5];
[MicNum,DataLength]=size(x);
window=hanning(NFFT);
overlap=NFFT/2;
N=fix((DataLength)/overlap)*overlap+overlap;
X=[x zeros(MicNum,N-DataLength)];  
nblocks=length(X)/overlap;
segs=13;
HThrehod=segs*NFFT; 
HSegments=fix(DataLength/HThrehod); 
c=340;
Output=zeros(N,1);
FBFOutput=zeros(N,1);
FBFOutbuff=zeros(NFFT/2,1);
H=zeros(MicNum,NFFT);
xbuf=zeros(MicNum,NFFT);
Xbuf=zeros(MicNum,NFFT);
lastOne=0;
W0=zeros(MicNum,NFFT);
YFBF=zeros(NFFT,1);
Y=zeros(NFFT,1);
HStd=zeros(MicNum,NFFT);
G=zeros(MicNum-1,NFFT);
outbuf=zeros(NFFT/2,1);
Pest=zeros(NFFT,1);
Freband=linspace(0,fs/2,NFFT/2+1);
timeDelay=zeros(MicNum,NFFT);
BM=zeros(MicNum,MicNum-1,NFFT);
%% steer vector
for freIdx=1:length(Freband)
    coefficient = 2 * pi * Freband(freIdx)/c;

     h=cosd(DesAng); % ģ��
%     h= [cosd(DesAng),sind(DesAng)].';
    tao = MArray*h;
    timeDelay(:,freIdx)=exp(j*coefficient*tao);
end


for m=1:MicNum
    tmpDelay=timeDelay(m,1:(NFFT/2+1)).';
    tmpConjD=timeDelay(m,2:NFFT/2).';
    timeDelay(m,:)=[tmpDelay;flipud(conj(tmpConjD))].';
end
 
%% �㷨��ʼ   
for n=1:nblocks
  
    %% TF���ƽ׶�
 
    
   %% GSC Beamforming�׶�
    for m=1:MicNum
        xbuf(m,NFFT/2+1:end)=X(m,(n-1)*overlap+1:n*overlap);
        Xbuf(m,:)=fft(xbuf(m,:)'.*window) ; % .*rectwin(NFFT)
        Xbuf(m,:)=Xbuf(m,:)  ;
    end

    %% YFBF  ���
    for freIdx=1:NFFT
        YFBF(freIdx,1)  =  0.5*(Xbuf(1,freIdx) +   Xbuf(2,freIdx)); % NFFT*MicNum  *  MicNum*1=NFFT*1
    end
     
   
    U=zeros(MicNum-1,NFFT);
    for freIdx=1:NFFT
        U(:,freIdx)=BM(:,:,freIdx)'*Xbuf(:,freIdx); % (M-1) *M  *M*1=(M-1)*1 
    end
    %% NC
    if n==1
        Y=YFBF; % G�ĳ�ʼֵ��Ϊ0�������� ��21���ͣ�22�� ֮��Ĺ�ʽ
    else
        for freIdx=1:NFFT
            Y(freIdx,1)=YFBF(freIdx,1)-G(:,freIdx)'*U(:,freIdx); % 1*1 - 1*(M-1)*(M-1)*1=1
        end
    end
    %% LMS
 
    for freIdx=1:NFFT
        Pest(freIdx,1)=forgottor*Pest(freIdx,1)+(1-forgottor)*norm(Xbuf(2:end,freIdx)).^2;
        G(:,freIdx)=G(:,freIdx)+mu*(U(:,freIdx)*conj(Y(freIdx,1)))/Pest(freIdx,1); % (M-1)*1  G�ڲ��ϵ�����
    end

%     for m=1:MicNum-1
%         for freIdx=1:NFFT
%             if G(m,freIdx)>3e-6;
%                G(m,freIdx)=3e-6;
%             end
%         end
%     end
    
  %  Freband=linspace(-fs/2,fs/2,NFFT);
  % plot(Freband,G(2,:));
   G_time=ifft(G.')';
   G_time=G_time(:,1:251); % ��Ӧ�����е�251��ϵ����FIR�˲���(����Ч�������Ǻܴ�)
   G=fft(G_time.',NFFT).';     
    
    %% ͨ�ü��㲿��
    
    Y_time=real(ifft(Y));
    Output((n-1)*NFFT/2+1:n*NFFT/2)=outbuf+Y_time(1:NFFT/2); %
    outbuf=Y_time(NFFT/2+1:end);
    xbuf(:,1:NFFT/2)=xbuf(:,NFFT/2+1:end);
end

  audiowrite('f:/Work/2018/Beamforming/matlab/GSCLMS/voice/M_TFGSC.wav',Output,fs);  

%Output=Output.*4; % ���ڼӴ������ķ���Ӱ�죬��������*2������hanning����0.5������Ӱ��(�������ԭ��)
%name=['origin_last_02_' num2str(mu) '_' num2str(forgottor) '.wav']
%audiowrite(name,Output(:,1),fs);
%end