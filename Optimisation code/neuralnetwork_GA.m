function [x fval] = ga_n(iteration)
% iteration=1
tic
% For reading data from database file and assining it to variables\
Ip=xlsread('Filtered-database.xlsx');

global net
MeanD=mean(Ip(:,1:10));
SD=std(Ip(:,1:10));
Ip(:,1:10)=(Ip(:,1:10)-MeanD)./SD;

A=Ip(:,1);
B=Ip(:,2);
C=Ip(:,3);
D=Ip(:,4);
E=Ip(:,5);
F=Ip(:,6);
G=Ip(:,7);
H=Ip(:,8);
I=Ip(:,9);
J=Ip(:,10);
Head=Ip(:,11);
Power=Ip(:,12);
Er_T=Ip(:,13);
CC=Ip(:,14);

eff=Power./(997*102.9*8.1*9.81);
% % Defining The objective function

FunO = 127.744.*(1-eff).^2+8*270.505.*((102900-Head)./(102900)).^2+(0.69467.*(Er_T./5795).^2)+0.00228.*((0.0002-CC)/0.0002).^2;

inputs=[A,B,C,D,E,F,G,H,I,J]';

targets=[FunO]';
net = feedforwardnet([8,3]);
net = init(net);
net.layers{1}.transferFcn = 'poslin';
net.layers{2}.transferFcn = 'poslin';
net.trainFcn = 'trainlm';
net = configure(net,inputs,targets);
net.trainParam.epochs=1000;
net.trainParam.min_grad=1e-20;
net.trainParam.mu=10;
net.trainParam.mu_inc=10;
net.trainParam.mu_dec=0.1;
net.trainParam.mu_max=1e20;

[net,tr] = train(net,inputs,targets);
outputs = net(inputs);
reg=regression(targets,outputs);
 
 
 plotperform(tr);
 folder = 'D:\Kalpana101\performance_diagram';
 baseFileName = sprintf('performance%d.jpg',iteration); %pass i
 fullFileName = fullfile(folder, baseFileName);
 saveas(plotperform(tr),fullFileName);

%%training analysis
 trainip=zeros(numel(tr.trainInd),10);
 trainout=zeros(numel(tr.trainInd),4);
 trainip(1:numel(tr.trainInd),:)=Ip(tr.trainInd,1:10);
 trainout(1:numel(tr.trainInd),:)=Ip(tr.trainInd,11:14);
 trHead=trainout(:,1);
 trPower=trainout(:,2);
 trEr_T=trainout(:,3);
 trCC=trainout(:,4);
 treff=trPower./(997*102.9*8.1*9.81);
 % % Defining The objective function  
 trFunO = 127.774.*(1-treff).^2+8*270.505.*((102900-trHead)./(102900)).^2+(0.69467.*(trEr_T./5795).^2)+0.00228.*((0.0002-trCC)/0.0002).^2;
 trtargets=[trFunO]';
 troutput=net(trainip');
 trreg=regression(trtargets,troutput);
 e1=trtargets-troutput;
 
 
 %validation analysis
 valip=zeros(numel(tr.valInd),10);
 valout=zeros(numel(tr.valInd),4);
 valip(1:numel(tr.valInd),:)=Ip(tr.valInd,1:10);
 valout(1:numel(tr.valInd),:)=Ip(tr.valInd,11:14);
 vHead=valout(:,1);
 vPower=valout(:,2);
 vEr_T=valout(:,3);
 vCC=valout(:,4);
 veff=vPower./(997*102.9*8.1*9.81);
 % % Defining The objective function  
 vFunO =  127.774.*(1-veff).^2+8*270.505.*((102900-vHead)./(102900)).^2+(0.69467.*(vEr_T./5795).^2)+0.00228.*((0.0002-vCC)/0.0002).^2;
 vtargets=[vFunO]';
 voutput=net(valip');
 vreg=regression(vtargets,voutput);
 e2=vtargets-voutput;

%%% testing analysis
 testip=zeros(numel(tr.testInd),10);
 testout=zeros(numel(tr.testInd),4);
 testip(1:numel(tr.testInd),:)=Ip(tr.testInd,1:10);
 testout(1:numel(tr.testInd),:)=Ip(tr.testInd,11:14);
 tHead=testout(:,1);
 tPower=testout(:,2);
 tEr_T=testout(:,3);
 tCC=testout(:,4);
 teff=tPower./(997*102.9*8.1*9.81);
 % % Defining The objective function  
 tFunO =  127.774.*(1-teff).^2+8*270.505.*((102900-tHead)./(102900)).^2+(0.69467.*(tEr_T./5795).^2)+0.00228.*((0.0002-tCC)/0.0002).^2;
 ttargets=[tFunO]';
 toutput=net(testip');
 treg=regression(ttargets,toutput);
 e3=ttargets-toutput;
 
 figure(3)
 ploterrhist(e1,'Training',e2,'Validation',e3,'Test','bins',20)
 
 folder = 'D:\Kalpana101\error_hist';
 baseFileName = sprintf('errhist%d.jpg',iteration); %pass i
 fullFileName = fullfile(folder, baseFileName);
 saveas(figure(3),fullFileName);
 
 plottrainstate(tr)
 folder= 'D:\Kalpana101\train_state';
 baseFileName = sprintf('trainstate%d.jpg',iteration); % pass i
 fullFileName = fullfile(folder, baseFileName);
 saveas(plottrainstate(tr),fullFileName);
 
 figure(4)
 plotregression(troutput,trtargets,'Training',voutput,vtargets,'Validation',toutput,ttargets,'Testing',outputs,targets,'All')
 
 folder= 'D:\Kalpana101\regression';
 baseFileName = sprintf('Regression%d.jpg',iteration); %%pass i
 fullFileName = fullfile(folder, baseFileName);
 saveas(figure(4),fullFileName);
 
 result = [iteration trreg vreg treg reg tr.best_perf tr.best_vperf tr.best_tperf tr.num_epochs tr.best_epoch];
 %%pass i in 1
dlmwrite('result.csv', result,'-append');
% csvwrite('result.csv',result,0,'append'); %need to write in csv %what if CFD doesnot produce result what for written data 



% lb and ub needs to be updated
lb=[0.407981566	0.299407658	0.465244	0.471364	0.492821	0.501218	0.264454	0.359494	0.65611	0.655634
];
lb = (lb - MeanD)./(SD);
ub=[	0.498284604	0.365672244	0.568341	0.575688	0.602073	0.612184	0.323092	0.439247	1.190902	1.191557
];
ub = (ub - MeanD)./(SD);
options = gaoptimset('PopInitRange',[lb;ub],...
    'PopulationSize',300,...
    'Vectorized','off',...
    'Generations',150,...
    'PlotInterval',1,...
    'PlotFcns', @gaplotbestf,...
    'TolFun',1e-100);
A=eye(10,10);
b=ub;
h = @(x1) ObjectiveFunction(x1,net);
[x1, fitval] = ga(h,10,A,ub,[],[],lb,ub,[],[],options); 
x=(x1.*SD)+MeanD; 
fval = fitval;

toc
close all
end
