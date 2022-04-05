%% Plot LFPTTRaw timeseries data (contact 0, epoch 1)

Fs=1024;
T=1/Fs;
N=30000;
t1=(0:N-1)/Fs;
Signal1=sin(1*2*pi*t1);
Signal2=0.25*sin(2*2*pi*t1);
Signal4=0.125*sin(4*2*pi*t1);
Signal10=0.25*sin(10*2*pi*t1);
Signal50=0.005*sin(50*2*pi*t1);

temp_epoch = Signal1+Signal2+Signal4+Signal10+Signal50;

 figure   
 hold on;
 plot(t1,Signal1)
 plot(t1,Signal2)
 plot(t1,Signal4)
 plot(t1,Signal10)
 plot(t1,Signal50)
 plot(t1,temp_epoch)
 xlabel('time')
 ylabel('amplitude')


    temp_hp = highpass(temp_epoch,0.5,Fs); % filter out everything below 0.5 Hz (0.1 or 0.5 Hz - gets rid of large mag)

    % pspectrum --> power, freq
    [power, freq] = pspectrum(temp_hp,Fs,"FrequencyLimits",[0 80]);
    % convert pwr to decibels -->  10*log(10)
    power_decibel = 10*log10(power);
    smooth_power = smoothdata(power_decibel,'movmean',30);

figure
plot(freq,smooth_power)
xlabel('freq')
ylabel('power')

figure
plot(1:30720,LFPTTRaw.("0"){1})
xlabel('samples over time')
ylabel('voltage changes')
% freq = 1/period
% power = 