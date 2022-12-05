function beta_plotopt(loop_index, beta_array)
s=beta_array;
for i=1:5
n=4;
n1=n-1;
if i==1;
    m=1;
end
if i==2;
    m=5;
end
if i==3;
    m=9;
end
if i==4;
    m=13;
end
if i==5;
    m=17;
end
[p]=s(:,m:m+3)';
for j=0:1:n1
    coeff(j+1)=factorial(n1)/(factorial(j)*factorial(n1-j));
end
J=[];
D=[];
for t=0:0.002:1
for d=1:n
    J(d)=coeff(d)*((t^(d-1))*((1-t)^(n-d)));
end
    D=cat(1,D,J);
end
B1=D*p;
hold on;
figure(loop_index)
if i==1
line(B1(:,1),B1(:,2),'color','r');
end
if i==2
line(B1(:,1),B1(:,2),'color','b');
end
if i==3
line(B1(:,1),B1(:,2),'color','g');
end
if i==4
line(B1(:,1),B1(:,2),'color','m');
end
if i==5
line(B1(:,1),B1(:,2),'color','c');
end

end
legend ('layer 1','layer 2','layer 3','layer 4','layer 5');
xlabel('%M-PRIME');
ylabel('BETA ANGLE');
title(sprintf('Optimisation Iteration %d', loop_index));
baseFileName = sprintf('Optimization Iteration %d.jpg', loop_index);
folder = 'D:\\Kalpana101\\beta_opt';
fullFileName = fullfile(folder, baseFileName);
saveas(figure(loop_index),fullFileName); %put varible for 1 if you want create different name 
 hold off
 close all;
end
