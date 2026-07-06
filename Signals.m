clc;
clear;
close all;


%% Load cursed image
img = imread("cursed_schematic_05.png");
img = im2double(img);


%% 1. Spatial Cleansing (Median Filter)
img1 = medfilt2(img, [5 5]);


%% 2. Frequency Exorcism
%% 2.1 Transforming image into Frequency Domain using 2D FFT
img1ft = fftshift(fft2(img1));
mod_img1ft = abs(img1ft);
copy = mod_img1ft;

%% 2.2 Automated Peak Detector
[M, N] = size(img1);

cx = floor(N/2) + 1;
cy = floor(M/2) + 1;

core_radius = 30;
[x, y] = meshgrid(1:N, 1:M);
core_mask = ((x - cx).^2 + (y - cy).^2) <= core_radius^2;
copy(core_mask) = 0;

threshold = mean(copy(:)) + 5*std(copy(:));
peak = copy>threshold;

%% 2.3 Applying a Gaussian Notch Filter to block interference
H = ones(M, N);

[peaky, peakx] = find(peak);

notch_radius = 5;

for i = 1:length(peaky)
    d = sqrt((x - peakx(i)).^2 + (y - peaky(i)).^2);

    H = H .* (1 - exp(-0.5 * (d ./ notch_radius).^2));    
end

clean_img = img1ft .* H;

%% 2.4 Restoration
restored_img = real(ifft2(ifftshift(clean_img)));
restored_img = rescale(restored_img);

%% 2.5 Blueprint Color Mapping
cmap = [linspace(0.0, 0.7, 256)', ...
        linspace(0.1, 0.9, 256)', ...
        linspace(0.3, 1.0, 256)']


%% 3. Display Required Output
figure('Name', 'Cursed Schematic 1', 'Position', [100, 100, 1200, 800]);

%% 3.1 Original Corrupted Image
subplot(2, 3, 1);
imshow(img);
title('1. Original Corrupted Image');

%% 3.2 Image after Spatial Filtering 
subplot(2, 3, 2);
imshow(img1);
title('2. Spatial Filtered Image');

%% 3.3 The 2D FFT Magnitude Spectrum 
img2 = log(1+mod_img1ft);
subplot(2, 3, 3);
imshow(img2, []);
colormap(gca, 'gray');
title('3. FFT Magnitude Spectrum');

%% 3.4 Your frequency mask
subplot(2, 3, 4);
imshow(H);
title('4. Frequency Mask');

%% 3.5 The final restored image
subplot(2, 3, 5);
imshow(restored_img);
colormap(gca, cmap);
title('5. Restored Image');