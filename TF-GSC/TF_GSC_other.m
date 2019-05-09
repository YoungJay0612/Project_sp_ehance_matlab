function [FBFOutput,Output] = TF_GSC(x,fs,DesAng,NFFT,mu,forgottor)
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
[x1,fs1]= audioread('F:/Work/2018/Beamforming/matlab/TF-GSC/xOne.wav'); % main mic
[x2,fs2]= audioread('F:/Work/2018/Beamforming/matlab/TF-GSC/xTwo.wav'); % ref mic
forgottor = 0.9; mu = 0.073;
fs = fs1;

x = [x1,x2]';
NFFT = 512;
%MArray = 0.0425*[1,0;1/2,sqrt(3/4);-1/2,sqrt(3)/2;-1,0;-1/2,-sqrt(3)/2;1/2,-sqrt(3)/2];
MArray=0.05*[-2.5;-1.5;-0.5;0.5;1.5;2.5];
% MArray=0.05*[-2.5,0;-1.5,0;-0.5,0;0.5,0;1.5,0;2.5,0];
%MArray=0.05*[0;1;2;3;4;5];
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
DesAng = 0;

%% steer vector
for freIdx=1:length(Freband)
    coefficient = 2 * pi * Freband(freIdx)/c;

     h=cosd(DesAng); % ģ��
%     h= [cosd(DesAng),sind(DesAng)].';
    tao = MArray*h;
    
    %expval = exp( coefficient*tao);
    %timeDelay(1,freIdx)=   exp( coefficient*tao);
     % timeDelay(2,freIdx)=   exp( coefficient*tao);
end


for m=1:MicNum
  %  tmpDelay=timeDelay(m,1:(NFFT/2+1)).';
   % tmpConjD=timeDelay(m,2:NFFT/2).';
   % timeDelay(m,:)=[tmpDelay;flipud(conj(tmpConjD))].';
end




%% ��ͳ�����γɼ�Ȩ����
% % w_con = zeros(MicNum,NFFT);
% % for FreIdx = 1 : length(Freband)
% %     coefficient = 2 * pi * Freband(FreIdx)/c;
% % %     h = [cosd(DesAng),sind(DesAng)].';
% %     h=cosd(DesAng); % ģ��
% %     tao = MArray*h;
% %     w_con(:,FreIdx) = exp(j*coefficient*tao)/MicNum;
% % end;
% % 
% % for m=1:MicNum
% %     tmpW_con=w_con(m,1:NFFT/2+1).';
% %     tmpW_conj=w_con(m,2:NFFT/2).';
% %     w_con(m,:)=[tmpW_con;flipud(conj(tmpW_conj))];
% % end
% 
% %% ���Ҳ���
% TMH=Plot_H(X,NFFT,segs,window,timeDelay);
% n=1;
% subplot(331);
% 
% angle_01=atand(imag(TMH(1,(n-1)*NFFT+1:n*NFFT))./real(TMH(1,(n-1)*NFFT+1:n*NFFT)));
% % angle_01=atand(imag(TMH(1,1:end))./real(TMH(1,1:end)));
% plot(1:512,angle_01);
% % plot(1:length(TMH(1,:)),angle_01);
% title('Pic Mic1');
% subplot(332);
% angle_02=atand(imag(TMH(2,(n-1)*NFFT+1:n*NFFT))./real(TMH(2,(n-1)*NFFT+1:n*NFFT)));
% % angle_02=atand(imag(TMH(2,1:end))./real(TMH(2,1:end)));
% plot(1:512,angle_02);
% % plot(1:length(TMH(1,:)),angle_02);
% % polarplot(TMH(2 ,41),'*');
% title('Pic Mic2');
% subplot(333);
% angle_03=atand(imag(TMH(3,(n-1)*NFFT+1:n*NFFT))./real(TMH(3,(n-1)*NFFT+1:n*NFFT)));
% % angle_03=atand(imag(TMH(3,1:end))./real(TMH(3,1:end)));
% plot(1:512,angle_03);
% % plot(1:length(TMH(1,:)),angle_03);
% % polarplot(TMH(3 ,41),'*');
% title('Pic Mic3');
% subplot(334);
% angle_04=atand(imag(TMH(4,(n-1)*NFFT+1:n*NFFT))./real(TMH(4,(n-1)*NFFT+1:n*NFFT)));
% % angle_04=atand(imag(TMH(4,1:end))./real(TMH(4,1:end)));
% plot(1:512,angle_04);
% % plot(1:length(TMH(1,:)),angle_04);
% % polarplot(TMH(4 ,41),'*');
% title('Pic Mic4');
% subplot(335);
% angle_05=atand(imag(TMH(5,(n-1)*NFFT+1:n*NFFT))./real(TMH(5,(n-1)*NFFT+1:n*NFFT)));
% % angle_05=atand(imag(TMH(5,1:end))./real(TMH(5,1:end)));
% plot(1:512,angle_05);
% % plot(1:length(TMH(1,:)),angle_05);
% % polarplot(TMH(5 ,41),'*');
% title('Pic Mic5');
% subplot(336);
% angle_06=atand(imag(TMH(6,(n-1)*NFFT+1:n*NFFT))./real(TMH(6,(n-1)*NFFT+1:n*NFFT)));
% % angle_06=atand(imag(TMH(6,1:end))./real(TMH(6,1:end)));
% plot(1:512,angle_06);
% % plot(1:length(TMH(1,:)),angle_06);
% % polarplot(TMH(6 ,41),'*');
% title('Pic Mic6');


%% �㷨��ʼ   
for n=1:nblocks
  
    %% TF���ƽ׶�
    % �鿴Ŀǰ���Ķ�H�ϣ�ʹ����Ӧ��H
    if(mod(n*overlap,HThrehod)~=0)
        HSIndex=fix(n*overlap/HThrehod)+1; 
    else
        HSIndex=fix(n*overlap/HThrehod);
    end
    
    if(lastOne~=HSIndex) % ������ÿ�ν���һ֡ ����Ҫ����һ��
        if(HSIndex*HThrehod<=DataLength)  % ������������ʱ�����Ǿ���H��W0������һ�μ���õ���ֵ��
            % H=TF_Estimation(X(:,(HSIndex-1)*HThrehod+1:HSIndex*HThrehod),NFFT,13,window); 
            % aaaa=X(:,(HSIndex-1)*HThrehod+1:HSIndex*HThrehod);
           H=TF_Estimation_TD(X(:,(HSIndex-1)*HThrehod+1:HSIndex*HThrehod),NFFT,segs,window ); 
         %   H = ones(2, NFFT);
%             for m=1:MicNum
%                 for freIdx=1:NFFT
%                     if H(m,freIdx)>1
%                         H(m,freIdx)=1;
%                     end
%                 end
%             end
%            FreBand=linspace(-fs/2,fs/2,NFFT);
%            plot(FreBand,H(2,:));
            
            
%             ifftH=ifft(H.');
%             ifftH=ifftH(1:181,:);
%             HStd=fft(ifftH,NFFT);
%             f=16000/2*linspace(-1,1,512);
%             plot(f,HStd(:,2));
            HStd=H.';
            lastOne=HSIndex;
           %% W0�׶�
            for freIdx=1:NFFT
                W0(:,freIdx)=HStd(freIdx,:)./norm(HStd(freIdx,:)).^2    ; % MicNum*NFFT   .*timeDelay(:,freIdx).' 
            end
            
            
           %% Blocking Matrix
   
            for freIdx=1:NFFT
                for row=1:MicNum
                    for col=1:MicNum-1
                        if(row==1)
                            BM(row,col,freIdx)=-conj(HStd(freIdx,col+1));
                        elseif(row~=1 && row-1==col)
                            BM(row,col,freIdx)=1;
                        end
                    end
                end
            end
            
        end
       
    end
    
   %% GSC Beamforming�׶�
    for m=1:MicNum
        xbuf(m,NFFT/2+1:end)=X(m,(n-1)*overlap+1:n*overlap);
        Xbuf(m,:)=fft(xbuf(m,:)'.*window) ; % .*rectwin(NFFT)
        Xbuf(m,:)=Xbuf(m,:);%.*timeDelay(m,:) ;
    end

    %% YFBF  ���
    for freIdx=1:NFFT
        YFBF(freIdx,1)=W0(:,freIdx)'*Xbuf(:,freIdx); % NFFT*MicNum  *  MicNum*1=NFFT*1
    end
     
   % YFBF(:,1)=Y_con(:,1);
   % YFBF(:,1)=Xbuf(2,:).';
    %===============���Կ�ʼ===================
%       YBF_time=real(ifft(YFBF));
%       FBFOutput((n-1)*NFFT/2+1:n*NFFT/2)=FBFOutbuff+YBF_time(1:NFFT/2); %
%       FBFOutbuff=YBF_time(NFFT/2+1:end);
%       xbuf(:,1:NFFT/2)=xbuf(:,NFFT/2+1:end);
    %===============���Խ���===================
%      continue;
     

    
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
    
    Y_time=real(ifft(YFBF));
    Y_time_t = Y_time;
    
    Output((n-1)*NFFT/2+1:n*NFFT/2)=outbuf+Y_time_t(1:NFFT/2); %
    outbuf=Y_time_t(NFFT/2+1:end);
    xbuf(:,1:NFFT/2)=xbuf(:,NFFT/2+1:end);
end
%Output=Output.*4; % ���ڼӴ������ķ���Ӱ�죬��������*2������hanning����0.5������Ӱ��(�������ԭ��)
%name=['origin_last_02_' num2str(mu) '_' num2str(forgottor) '.wav']
%audiowrite(name,Output(:,1),fs);
audiowrite('f:/Work/2018/Beamforming/matlab/TF-GSC/TF_GSCOUT.wav',Output,fs);


end
 
