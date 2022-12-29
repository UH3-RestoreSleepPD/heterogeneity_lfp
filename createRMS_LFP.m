function [] = createRMS_LFP(testfile,allDIRs)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

cd(allDIRs.rawDir)
load(testfile,'bipolarS','sl');
sln = sl;
bpRMSz = zeros(size(bipolarS));
for bpi = 1:3
    for epi = 1:height(bipolarS)

        tmpEp = bipolarS{epi,bpi};
        tmpLOW = lowpass(tmpEp,125,1024);
        tmpLdn = downsample(tmpLOW,4);
        tmpLDs = smoothdata(tmpLdn,'sgolay',100);
        tmpRMSz = rms(tmpLDs);

        bpRMSz(epi,bpi) = tmpRMSz;
        disp(['epi ', num2str(epi), ' done!'])

    end
end
cd(allDIRs.saveDir)
fparts = split(testfile,{'_','.'});
saveName = ['rmsLFP_',fparts{2},'_',fparts{3},'_',fparts{4},'.mat'];
save(saveName,'bpRMSz','sln');

end