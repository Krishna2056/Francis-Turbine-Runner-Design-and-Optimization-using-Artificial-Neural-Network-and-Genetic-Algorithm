function [err tfval] = bgi_opt(x,opti_num)

% This program opens batchinput file from preliminary design and extract
% necessary data. str contains the whole content of the bgi file in form of
% cell array. idx contains the coordinates available in given bgi file

% name = input('Enter Filename (without extension) of preliminary design 
% batchinput file: ','s');
filename = ['BG','.bgi'];
% filename = ['BG-1','.bgi'];
str=[];
fid=fopen(filename);
if fid == -1
    error('Cannot open file: %s', filename);
end
l=fgetl(fid);
while ischar(l)
  str{end+1,1}=l;
  l=fgetl(fid);
end
fclose(fid);
str;
idx=str(cellfun(@numel,regexp(str,'[\d\.]+'))==2);
idx = regexp(idx,'\d?\d?\d?\.?\d+','match');


% The value of n refers to the number of control points for meridional profile curves
n = 32;
for i = 1: n
    z{i} = (str2double(idx{i}{1}));
    r{i} = (str2double(idx{i}{2}));
end
% To change cell array into matrix
z_orig = cell2mat(z);
r_orig = cell2mat(r);

r = [r_orig x(9) x(10)];
z = [z_orig NaN(1, 2)];
r_new = r;
chnging=[4 5 14 15 26 27 30 31 33 34];
for q=1:numel(x)
    r_new(chnging(q))=x(q);
end

 zr = [z_orig; r_orig];
 space = [4 5 14 15 26 27 30 31]; % needed to be changed

 zr_new = [z; r_new];

 for j= 1:32
     if ~sum(j == space)
         zr_new(2,j) = r (j);
    end
end
temp1 = zr_new;



% Prelim Design Beta angles
 beta_angle=[61.70010608	50.66341106	39.62671604	28.59002102	58.999756...
     47.66649802	36.33324005	24.99998207	56.19999773	44.77667079	33.35334384...
     21.9300169 52.89999001	41.45332459	30.00665917	18.55999375	46.29997458...
     35.89998846	25.50000233	15.10001621];

pos=[2 6 10 14 18];
for j=1:(numel(pos))
    beta_angle(pos(j)) = r_new(end-1).*beta_angle(pos(j));
    beta_angle(pos(j)+1) = r_new(end).*beta_angle(pos(j)+1);
 end
beta_angle = beta_angle';

vv = [0:100/3:100];
vv = [vv';vv';vv';vv';vv'];

% The beta_array consists the 20 rows of (%M-Prime,Beta angle)
beta_array1 = [vv beta_angle];
 
% fixing the necessaary coordinates e.g. intersection of hub and te
zr_new(:,[21 3 25 7 29 23 22 13 28 17 32 24])=temp1(:,[1 2 2 6 6 10 11 12 12 16 16 20]);
beta_array1 = beta_array1';
zr_mer = zr_new(:,1:end-2);

% The design data array consists the data that is ready to be replaced into
% create a new design
design_data = [zr_mer beta_array1];

% Two bgi files: Bg-1.bgi is opened in read mode and the BATCHINPUT.bgi is 
% opened in the write mode
f_id = fopen(filename,'r');
f2_id = fopen('BATCHINPUT.bgi','wt');

% The suffix 1 and 2 refers to meridional curves points while 11 and 22
% refers to the beta angles
checkstr1 = '			Begin Data';
checkstr11 ='				Begin Data';
checkstr2 = '			End Data';
checkstr22 ='				End Data';

k = 1;
while ~feof(f_id)
    strings = fgetl(f_id); 
    % This part replaces thte meridional curves control points and writes 
    % into new BGI file (BATCHINPUT.bgi)
    if strcmp(strings, checkstr1)
        fprintf(f2_id,'			Begin Data\n');
        while strcmp(fgetl(f_id), checkstr2) == 0
            fprintf(f2_id, '				( %f,%f )\n',design_data(1,k), design_data(2,k));
            k = k + 1;
        end 
        fprintf(f2_id,'			End Data\n');
        
        % This part replaces the beta angles and writes into a new BGI file
        % If thickness needs to be included, we can simply omit the 
        % later condtition
    elseif strcmp(strings, checkstr11) & k <= 52 
        fprintf(f2_id,'				Begin Data\n');
        while strcmp(fgetl(f_id), checkstr22) == 0
            fprintf(f2_id, '					( %f,%f )\n',design_data(1,k), design_data(2,k));
            k = k + 1;
        end 
        fprintf(f2_id,'				End Data\n');
    else
        
        % This part writes into the BGI file as it is without any change
        fprintf(f2_id, '%s\n', strings);
    end
end
fclose(f_id);
fclose(f2_id);
fprintf('\n Running %d Optimization Check Simulation\n\n',opti_num)
% bladeplot_opt(opti_num,zr_mer,zr);
% beta_plotopt(opti_num,beta_array1);
hold off
[H, P, Er_T, CC, err]=code(opti_num);
% d_base=xlsread('Filtered-database.xlsx');
% da_base(1:10) = x;
opt_base=xlsread('Filtered-database.xlsx');
opt_base(end+1,1:10) =x;
opt_base(end,11:16)= [H P Er_T CC err opti_num];
% da_base(11:16)= [H P Et Cc error,opti_num];
% % Accessing the data of recent last column of d_base
if opti_num ~= 1
    H_1 = opt_base(opti_num-1,11);
    P_1 = opt_base(opti_num-1,12);
    ET_1 = opt_base(opti_num-1,13);
    CC_1 = opt_base(opti_num-1,14);
    last_values = [H_1 P_1 ET_1 CC_1];
    recent_values = [H P Er_T CC];
    if sum(last_values == recent_values) > 1
        err = 5;
    end
end
eff=P/(997*102.9*8.1*9.81);
tfval = 127.774.*(1-eff).^2+8*270.505.*((102900-H)./(102900)).^2+(0.69467.*(Er_T./5795).^2)+0.00228.*((0.0002-CC)/0.0002).^2;
if (err == -1)
    xlswrite('Filtered-database.xlsx',opt_base);
    mkdir('ANSYS FILES 2',sprintf('OptimData-%d SIMFILES',opti_num));
    folder1 = sprintf('D:\\Kalpana101\\ANSYS FILES 2\\OptimData-%d SIMFILES',opti_num);
    if isfile('BATCH_SOLVERINPUT_002.out')
        copyfile('BATCH_SOLVERINPUT_002.out',folder1);
    end
    if isfile('BATCH_SOLVERINPUT_002.res')
        copyfile('BATCH_SOLVERINPUT_002.res',folder1);
    end
    copyfile('turbomesh.gtm',folder1);
    copyfile('HydraulicTurbineReport',folder1);
    copyfile('HydraulicTurbineReport.txt',folder1);
    copyfile('PerformanceTable.csv',folder1);
    copyfile('curves',folder1);
    bladeplot_opt(opti_num, zr_mer,zr)
    beta_plotopt(opti_num, beta_array1) 
end
err = err;
tfval;
close all;
end

 

