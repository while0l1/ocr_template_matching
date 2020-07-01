clc, clear, close all;
% 将allchar.png分割得到36个字符，保存在allchar文件夹，当作模板
img = imread('allchar.png');
img = imcomplement(img);
img = imbinarize(img);
% imshow(img);

lineBegin = [];
lineEnd = [];

lineSum = sum(img, 2);

% 得到行的开始和结束
for i=1:length(lineSum) - 1
    if lineSum(i) == 0 && lineSum(i+1) ~= 0
        lineBegin = [lineBegin, i];
    elseif lineSum(i) ~= 0 && lineSum(i+1) == 0
        lineEnd = [lineEnd, i];
    end
end

imgNum = 1; % 记录图片的序号，用作模板名字

for i=1:length(lineBegin) % 对每一行做字符分割
    lineImg = img(lineBegin(i):lineEnd(i), :);
    colSum = sum(lineImg);
    charBegin = [];
    charEnd = [];
    for j=1:length(colSum) - 1 % 逐个分割字符
        if colSum(j) == 0 && colSum(j+1) ~= 0
        charBegin = [charBegin, j];
    elseif colSum(j) ~= 0 && colSum(j+1) == 0
        charEnd = [charEnd, j];
        end
    end
    for j=1:length(charBegin)
        charimg = lineImg(:, charBegin(j):charEnd(j));
        charimg = charimg(sum(charimg, 2)>0, :);
        imgName = strcat(num2str(imgNum), '.bmp');
        imgName = strcat('allchar/', imgName);
        imwrite(charimg, imgName);
        imgNum = imgNum + 1;
    end
end