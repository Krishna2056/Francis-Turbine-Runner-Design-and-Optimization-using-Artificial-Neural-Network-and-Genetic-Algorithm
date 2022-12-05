%OPTIMISATION RUN 
clc 
clear all
close all
diary on
format compact;
format long;
read_ANN_data=readtable('validate.csv');
d_array_1 = table2array(read_ANN_data);
[row_pos, column_size]=size(d_array_1);
if row_pos == 0
    iteration = 1;
else
    iteration = d_array_1(end,1) + 1;
end

% iteration = str2double(iteration{1}) + 1;
fprintf('\n Running Iteration: %d\n',iteration)
counter = 0
while 1
    [x, fval] = ga_n(iteration);
    [err tfval] = bgi_opt2(x,iteration);
    check=abs((tfval-fval)/tfval);
    ANN_data = [iteration,fval,tfval];
    read_ANN_data=readtable('validate.csv');
    d_array_2 = table2array(read_ANN_data);
        if err == -1
            dlmwrite('validate.csv', ANN_data,'-append');
        end
        if check<=0.1
           counter = counter + 1
        else
            counter = 0
        end
        if counter >= 5
            break;
        end
        
   iteration= iteration+1;
   fprintf('\n Running Iteration: %d\n',iteration)
end
diary off
