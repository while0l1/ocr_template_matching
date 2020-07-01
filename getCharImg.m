clc, clear, close all;
% ��allchar.png�ָ�õ�36���ַ���������allchar�ļ��У�����ģ��
img = imread('allchar.png');
img = imcomplement(img);
img = imbinarize(img);
% imshow(img);

lineBegin = [];
lineEnd = [];

lineSum = sum(img, 2);

% �õ��еĿ�ʼ�ͽ���
for i=1:length(lineSum) - 1
    if lineSum(i) == 0 && lineSum(i+1) ~= 0
        lineBegin = [lineBegin, i];
    elseif lineSum(i) ~= 0 && lineSum(i+1) == 0
        lineEnd = [lineEnd, i];
    end
end

imgNum = 1; % ��¼ͼƬ����ţ�����ģ������

for i=1:length(lineBegin) % ��ÿһ�����ַ��ָ�
    lineImg = img(lineBegin(i):lineEnd(i), :);
    colSum = sum(lineImg);
    charBegin = [];
    charEnd = [];
    for j=1:length(colSum) - 1 % ����ָ��ַ�
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