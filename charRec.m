% ����ģ��ƥ��ķ��������ַ�ʶ��
clc,clear,close all;

% ��ʶ��ͼƬ������
ocrimg = 'this.jpg';
I=imread(ocrimg);%��ȡ����ͼƬ
[m, n, z] = size(I);
figure(1);
imshow(I);
title('����ͼƬ')
I1=rgb2gray(I);
figure('name', '�Ҷ�ͼ');
imshow(I1); %��ʾ�Ҷ�ͼ��
figure('name', 'ԭ�Ҷ�ֱ��ͼ');
imhist(I1); %�Ҷ�ֱ��ͼ


Ic = imcomplement(I1);%�ԻҶ�ͼȡ��
figure('name', 'ȡ����ĻҶ�ͼ');
imshow(Ic); %��ʾȡ�����ͼƬ
BW = imbinarize(Ic, 'adaptive');%��ȡ�����ͼ������ֵ��
figure('name', 'ȡ����Ҷ�ͼ�Ķ�ֵ��');
subplot(211);imshow(I);
subplot(212);
imshow(BW); 


bw=edge(I1,'prewitt');%��Ե��ȡ
figure('name', 'ԭ�Ҷ�ͼ��Ե��ȡ');
imshow(bw);
title('����ǰ��ֵ��ͼ��');

theta=1:180;
[R,xp] = radon(bw,theta); % radon�任 https://blog.csdn.net/yu132563/article/details/99228303

% �����任�����ͼ
figure('name', 'Radon�任��ͼ');
imagesc(theta,xp, R); colormap(jet);
xlabel('theta (�Ƕ�)');ylabel('x');
title('theta�����Ӧ��Radon�任');
colorbar

[I0,J] = find(R>=max(R(:)));% �ҵ����ֵ��J����ͶӰ�������Ӧ�Ƕ�
angle = 90-J;
goal1 = imrotate(BW,angle,'bilinear','crop');
figure('name', '�ǶȽ�����ͼ��');
imshow(goal1);title('�������ֵ��ͼ��'); % �ǶȽ�����ͼ����ʾ


%��ֵ�˲�
goal3=medfilt2(goal1,[3,3]);
goal3=medfilt2(goal3,[3,3]); % ��һ����ֵ�˲����Լ���������
figure('name', 'ͼ����ֵ�˲�'), imshow(goal3);

% �зָ�
% ��ÿһ����ͣ�����0����Ϊ�ַ�������
imline = goal3(sum(goal3, 2) > 0, :);
figure(); imshow(imline);

% �ָ���ַ�
% ��ÿһ����ͣ�����0���д����ַ�
charBegin = []; % �ַ���ʼλ��
charEnd = []; % �ַ�����λ��
colSum = sum(imline);
figure();
plot(colSum);
% ����
for i=1:length(colSum) - 1
    if colSum(i) == 0 && colSum(i+1) ~= 0
        charBegin = [charBegin, i];
    elseif colSum(i) ~= 0 && colSum(i+1) == 0
        charEnd = [charEnd, i+1];
    end
end
% ͨ��imline(:,charBegin(i):charEnd(i))��ȡ��i���ַ�
% ���ַ�����img_fo_charԪ������
img_of_char = {};
for i=1:length(charBegin)
    img = imline(:, charBegin(i):charEnd(i));
    img = img(sum(img, 2) > 0, :);
    img_of_char{i} = img;
end

template = {}; % ģ��Ԫ��
for i=1:36
    imgName = strcat(num2str(i),'.bmp');
    imgName = strcat('allchar/', imgName);
    I = imread(imgName);
    % ��ģ�����ŵ�һ���̶��ĳ���Ȳ��ã�����o��0��������
    template{i} = imresize(I, 0.2,'nearest'); % ��ģ����С���Լӿ��ٶ�
end

allchar = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
char_recognized = []; % ʶ���Ľ��
for i=1:length(img_of_char)
    dist = [];
    for j=1:36
        [m, n] = size(template{j});
        img = imresize(img_of_char{i}, [m, n], 'nearest'); %����ģ��ߴ�������ţ���һ��
        MM{j} = xor(img, template{j}); % ���
        dist = [dist,sum(sum(MM{j}))/(m*n)]; % ���룬�������ص�����һ�� 
    end
    [~, index] = min(dist); % �õ�������С��ֵ���±꣬��Ӧallchar������ַ�
    char_recognized = [char_recognized, allchar(index)]; % ��ʶ����ַ�������
end
char_recognized
figure('name', 'ʶ����');
I = imread(ocrimg);
F = imshow(I);
[m, n] = size(I);
resultstr = strcat('ʶ����:',(char_recognized));
title(resultstr, 'Fontsize', 18);