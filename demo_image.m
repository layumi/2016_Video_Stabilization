%--------image demo
addpath vlfeat-0.9.20/toolbox
run vl_setup
%--------import data
I1 = vl_impattern('roofs1') ;
I2 = vl_impattern('roofs2') ;
im1 = single(rgb2gray(I1));
im2 = single(rgb2gray(I2));
%--------get key points
[fa,da] = vl_sift(im1);
[fb,db] = vl_sift(im2);
[matches, scores] = vl_ubcmatch(da, db) ;
matches(3,:) = scores;
m = sortrows(matches',3);
% select top k points
k=200;
pa = fa(1:2,m(1:k,1));
pb = fb(1:2,m(1:k,2));
%{
figure(1);
subplot 121;
imshow(im1);
hold on 
plot(pa(1,:),pa(2,:),'r*');
subplot 122;
imshow(im2);
hold on 
plot(pb(1,:),pb(2,:),'r*');
%}
%-------caculate rotate angle
angle = 0;
scale = 1;
bias = [0.0;0.0]; % biasx, biasy
step = 1e-3;
batchsize = size(pa,2);
% s.*pa*rotate .+ b = pb
meand = mean(pb,2) - mean(pa,2);
pa = bsxfun(@minus,pa,mean(pa,2));
pb = bsxfun(@minus,pb,mean(pb,2));

%pa = [cos(pi/2),-sin(pi/2);sin(pi/2),cos(pi/2)]*pb; %test
for i=1:20
    rotate = [cos(angle),-sin(angle);sin(angle),cos(angle)];
    drotate = [-sin(angle),-cos(angle);cos(angle),-sin(angle)];
    y = bsxfun(@plus,scale.*rotate*pa,bias);
    loss = y-pb;
    loss(abs(loss)>1) = abs(loss(abs(loss)>1));
    loss(abs(loss)<1) = 0.5*(loss(abs(loss)<1));
    fprintf('epoch:%d,loss:%f\n',i,sum(sum(loss)));
    dy = y-pb;
    dy(dy>1)=1;
    dy(dy<-1)=-1;
    b_gradient = sum(dy,2);
    s_gradient = sum(sum(rotate*pa.*dy));
    a_gradient = sum(sum(scale.*drotate*pa.*dy));
    bias = bias - 2*step*b_gradient./batchsize;
    scale = scale - step*s_gradient./batchsize;
    angle = angle - step*a_gradient./batchsize;
end

[hh,ww,~] = size(I1);
im1_r = imresize(I1,scale); %enlarge
im1_b = imrotate(im1_r,-angle/pi*180,'bicubic','crop'); % rotate angle
im1_b = move_image(im1_b,bias); % move bias
im1_b = move_image(im1_b,meand); % move 
output = imresize(im1_b,[hh,ww]);

figure(1);
subplot(131);
imshow(I1);
title('Image1');
subplot(132);
imshow(I2);
title('Image2');
subplot(133);
imshow(output);
title('Image1m');


