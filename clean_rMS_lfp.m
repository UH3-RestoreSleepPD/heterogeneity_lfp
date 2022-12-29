function [] = clean_rMS_lfp(testfile,dataDir)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

cd(dataDir.rawDir)

load(testfile,'bpRMSz','sln');

bpRMSz2 = normalize(bpRMSz,'zscore');
% Determine cut off
highCUT = sum(bpRMSz2 > 4,2) ~= 0;
keepRow = ~highCUT;

bpRMSzT = bpRMSz2(keepRow,:);
sln2 = sln{1,1};
sln3 = sln2(keepRow);

distMet = pdist(bpRMSzT,'euclidean');

mdsParms = cmdscale(distMet);

cd(dataDir.saveDir)
fparts = split(testfile,{'_','.'});
saveName = ['ZSrmsLFP_',fparts{2},'_',fparts{3},'_',fparts{4},'.mat'];
save(saveName,'bpRMSzT','sln3','keepRow','distMet','mdsParms');


end