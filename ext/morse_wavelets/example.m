clear
close all

x1=[zeros(1,128) sin(2.*pi.*0.03.*(0:127)) zeros(1,256)];
x3=[zeros(1,128) cos(2.*pi.*0.03.*(0:127)) zeros(1,256)];
x2=zeros(1,128*4);

y1=x1+randn(1,128*4)./15;
y2=x2+randn(1,128*4)./15;
y3=x3+randn(1,128*4)./15;

nk=4;
n=length(y1);

A=(1:100).*0.3;

% calculates the wavelet transform with the (8,3) wavelets
% for k=0 to nk-1
for k=0:nk-1
    picture(:,:,k+1)=wscal55b(y1,A,8,3,k,1);
end

figure
imagesc(0:n-1,A,mean(abs(picture).^2,3));
ylabel('scale')
xlabel('time')
title('scalogram')



nyttcoh544(y1,y2,y3,A,8,3,4,1,0)