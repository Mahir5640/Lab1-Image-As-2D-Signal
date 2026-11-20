%% Lab 1 — Image as a 2D Signal
% Mahir Foysol Chowdhury

close all;
clear;
clc;

outputFolder = fullfile(fileparts(mfilename('fullpath')), 'figures');
if ~isfolder(outputFolder)
    mkdir(outputFolder);
end

%% 0) Create and inspect an RGB test image

[x, y] = meshgrid(0:599, 0:399);

% Create a smooth color gradient.
red   = 0.15 + 0.70 * x / 599;
green = 0.18 + 0.62 * x / 599;
blue  = 0.23 + 0.51 * x / 599;

% Add a shaded ellipse.
radius = sqrt(((x - 295) / 145).^2 + ((y - 260) / 118).^2);
ellipse = radius < 1;
shading = 1 - radius(ellipse);

red(ellipse)   = 0.32 + 0.57 * shading;
green(ellipse) = 0.19 + 0.56 * shading;
blue(ellipse)  = 0.16 + 0.44 * shading;

% Add a patch of fine diagonal stripes.
phase = 2 * pi * (0.108 * x + 0.013 * y);
stripePatch = x > 415 & x < 565 & y > 165 & y < 340;
stripeValues = 0.50 + 0.29 * cos(phase(stripePatch));

red(stripePatch)   = stripeValues;
green(stripePatch) = stripeValues;
blue(stripePatch)  = stripeValues;

I_rgb = im2uint8(cat(3, red, green, blue));
I = rgb2gray(I_rgb);

fprintf('Class: %s | Range: [%g, %g] | Size: %d x %d\n', ...
    class(I), double(min(I(:))), double(max(I(:))), ...
    size(I, 1), size(I, 2));

savePanels(outputFolder, '00-input', ...
    {I_rgb, I}, {'Original RGB', 'Grayscale'});

%% 1) Quantization and bit depth

I8 = I;
I6 = uint8(floor(double(I) / 4) * 4);
I4 = uint8(floor(double(I) / 16) * 16);

savePanels(outputFolder, '01-quantization', ...
    {I8, I6, I4}, {'8-bit original', '6-bit levels', '4-bit levels'});

%% 2) Histogram and contrast stretching

I_normalized = im2uint8(mat2gray(I));
I_stretched = imadjust(I, [0.2 0.8], [0 1]);

originalCounts = imhist(I);
stretchedCounts = imhist(I_stretched);
maxCount = max([originalCounts; stretchedCounts]);

fig = figure('Color', 'white', 'Position', [100 100 1050 360]);
tiledlayout(1, 2, 'Padding', 'compact', 'TileSpacing', 'compact');

nexttile;
bar(0:255, originalCounts, 1, 'EdgeColor', 'none');
xlim([0 255]);
ylim([0 1.05 * maxCount]);
xlabel('8-bit intensity');
ylabel('Pixel count');
title('Original histogram');

nexttile;
bar(0:255, stretchedCounts, 1, 'EdgeColor', 'none');
xlim([0 255]);
ylim([0 1.05 * maxCount]);
xlabel('8-bit intensity');
ylabel('Pixel count');
title('Stretched histogram');

exportgraphics(fig, fullfile(outputFolder, '02-histograms.png'), ...
    'Resolution', 150);

savePanels(outputFolder, '02-contrast', ...
    {I, I_normalized, I_stretched}, ...
    {'Original', 'Min-max normalized', 'Contrast-stretched'});

%% 3) Gamma correction

I_gamma_low = imadjust(I, [], [], 0.6);
I_gamma_high = imadjust(I, [], [], 1.6);

savePanels(outputFolder, '03-gamma', ...
    {I, I_gamma_low, I_gamma_high}, ...
    {'Original', 'Gamma = 0.6', 'Gamma = 1.6'});

%% 4) Sampling and aliasing

scale = 0.1;
I_small = imresize(I, scale, 'nearest', 'Antialiasing', false);
I_back = imresize(I_small, size(I), 'nearest');

savePanels(outputFolder, '04-sampling', ...
    {I, I_small, I_back}, ...
    {'Original', sprintf('Downsampled (%d x %d)', size(I_small, 1), ...
    size(I_small, 2)), 'Upscaled with nearest neighbor'});

%% 5) Optional moire demonstration

stripes = im2uint8(0.5 + 0.5 * cos(phase));
stripes_small = imresize(stripes, scale, 'nearest', 'Antialiasing', false);
stripes_back = imresize(stripes_small, size(stripes), 'nearest');

savePanels(outputFolder, '05-moire', ...
    {stripes, stripes_small, stripes_back}, ...
    {'Fine diagonal stripes', 'Downsampled stripes', 'Upscaled moire pattern'});

%% Figure export helper

function savePanels(outputFolder, fileName, images, labels)
    fig = figure('Color', 'white', 'Position', [100 100 1100 350]);
    tiledlayout(1, numel(images), 'Padding', 'compact', ...
        'TileSpacing', 'compact');

    for k = 1:numel(images)
        nexttile;
        imshow(images{k});
        title(labels{k});
    end

    exportgraphics(fig, fullfile(outputFolder, [fileName '.png']), ...
        'Resolution', 150);
end