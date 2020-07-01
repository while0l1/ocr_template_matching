% 利用模板匹配的方法进行字符识别
clc,clear,close all;

% 待识别图片的名字
ocrimg = 'this.jpg';
I=imread(ocrimg);%读取测试图片
[m, n, z] = size(I);
figure(1);
imshow(I);
title('测试图片')
I1=rgb2gray(I);
figure('name', '灰度图');
imshow(I1); %显示灰度图像
figure('name', '原灰度直方图');
imhist(I1); %灰度直方图


Ic = imcomplement(I1);%对灰度图取反
figure('name', '取反后的灰度图');
imshow(Ic); %显示取反后的图片
BW = imbinarize(Ic, 'adaptive');%对取反后的图像做二值化
figure('name', '取反后灰度图的二值化');
subplot(211);imshow(I);
subplot(212);
imshow(BW); 


bw=edge(I1,'prewitt');%边缘提取
figure('name', '原灰度图边缘提取');
imshow(bw);
title('矫正前二值化图像');

theta=1:180;
[R,xp] = radon(bw,theta); % radon变换 https://blog.csdn.net/yu132563/article/details/99228303

% 拉东变换后的谱图
figure('name', 'Radon变换谱图');
imagesc(theta,xp, R); colormap(jet);
xlabel('theta (角度)');ylabel('x');
title('theta方向对应的Radon变换');
colorbar

[I0,J] = find(R>=max(R(:)));% 找到最大值，J就是投影的最大点对应角度
angle = 90-J;
goal1 = imrotate(BW,angle,'bilinear','crop');
figure('name', '角度矫正后图像');
imshow(goal1);title('矫正后二值化图像'); % 角度矫正后图像显示


%中值滤波
goal3=medfilt2(goal1,[3,3]);
goal3=medfilt2(goal3,[3,3]); % 进一步中值滤波可以减少噪声点
figure('name', '图像中值滤波'), imshow(goal3);

% 行分割
% 对每一行求和，大于0的行为字符所在行
imline = goal3(sum(goal3, 2) > 0, :);
figure(); imshow(imline);

% 分割单个字符
% 对每一列求和，大于0的列存在字符
charBegin = []; % 字符起始位置
charEnd = []; % 字符结束位置
colSum = sum(imline);
figure();
plot(colSum);
% 遍历
for i=1:length(colSum) - 1
    if colSum(i) == 0 && colSum(i+1) ~= 0
        charBegin = [charBegin, i];
    elseif colSum(i) ~= 0 && colSum(i+1) == 0
        charEnd = [charEnd, i+1];
    end
end
% 通过imline(:,charBegin(i):charEnd(i))获取第i个字符
% 将字符存在img_fo_char元胞里面
img_of_char = {};
for i=1:length(charBegin)
    img = imline(:, charBegin(i):charEnd(i));
    img = img(sum(img, 2) > 0, :);
    img_of_char{i} = img;
end

template = {}; % 模板元胞
for i=1:36
    imgName = strcat(num2str(i),'.bmp');
    imgName = strcat('allchar/', imgName);
    I = imread(imgName);
    % 将模板缩放到一个固定的长宽比不好，比如o和0不好区分
    template{i} = imresize(I, 0.2,'nearest'); % 将模板缩小可以加快速度
end

allchar = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
char_recognized = []; % 识别后的结果
for i=1:length(img_of_char)
    dist = [];
    for j=1:36
        [m, n] = size(template{j});
        img = imresize(img_of_char{i}, [m, n], 'nearest'); %按照模板尺寸进行缩放，归一化
        MM{j} = xor(img, template{j}); % 异或
        dist = [dist,sum(sum(MM{j}))/(m*n)]; % 距离，除以像素点做归一化 
    end
    [~, index] = min(dist); % 得到距离最小的值的下标，对应allchar里面的字符
    char_recognized = [char_recognized, allchar(index)]; % 将识别的字符存起来
end
char_recognized
figure('name', '识别结果');
I = imread(ocrimg);
F = imshow(I);
[m, n] = size(I);
resultstr = strcat('识别结果:',(char_recognized));
title(resultstr, 'Fontsize', 18);