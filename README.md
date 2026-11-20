# Lab 1 — Image as a 2D Signal

**Mahir Foysol Chowdhury**

This lab explores how quantization, contrast stretching, gamma correction, and spatial sampling affect a digital image. Run `lab1.m` in MATLAB with Image Processing Toolbox to generate the test image and save the figures.

## 0. Load and inspect the image

I used a synthetic RGB test image with a smooth gradient, a shaded ellipse, and fine diagonal stripes. The gradient makes changes in intensity easier to see, and the stripes make aliasing visible. After converting the image to grayscale, it became a 400 × 600 matrix of `uint8` values. Each entry represents the intensity at one row and column. The script prints the measured intensity range in the MATLAB Command Window.

![Original RGB test image and grayscale conversion](figures/00-input.png)

## 1. Quantization and bit depth

An 8-bit grayscale image can represent up to 256 intensity levels. Rounding each intensity down to a multiple of 4 gives up to 64 levels, equivalent to 6-bit precision. Using a step of 16 gives up to 16 levels, equivalent to 4-bit precision. MATLAB stores all three results as `uint8` for display. The coarsest quantization produces the most visible bands in the smooth background.

![Comparison of 8-bit, 6-bit, and 4-bit intensity levels](figures/01-quantization.png)

## 2. Histogram and contrast stretching

The histogram shows how many pixels have each intensity. Min-max normalization maps the darkest and brightest pixels in the image to black and white. Contrast stretching maps the chosen input interval [0.2, 0.8], equivalent to intensities 51 through 204, onto the full 8-bit range of 0 to 255. The mapping is linear within that interval. Intensities outside it are clipped to black or white.

The stretched histogram spans a wider range, and clipping places more pixels at the endpoints. Differences within the gradient and shading become more visible. Pixels clipped to the same endpoint lose their differences in brightness.

![Original and contrast-stretched histograms](figures/02-histograms.png)

![Original, min-max normalized, and contrast-stretched images](figures/02-contrast.png)

## 3. Gamma correction

Gamma correction applies the nonlinear mapping `output = input^gamma` to normalized intensities. A gamma of 0.6 lifts the midtones and makes the image brighter. A gamma of 1.6 lowers the midtones and makes it darker. Both settings preserve the black and white endpoints of the mapping.

![Original grayscale image and two gamma corrections](figures/03-gamma.png)

## 4. Sampling and aliasing

Downsampling to 10% of the original width and height reduces the image from 400 × 600 to 40 × 60 pixels. The smaller image has 1% of the original number of samples. Nearest-neighbor upsampling repeats those samples, creating blocky edges and retaining the coarser pattern in the stripe patch.

With one sample every ten original pixels along each axis, the new Nyquist limit is 0.05 cycles per original pixel along each axis. Fine patterns above this limit can appear as lower spatial frequencies. Applying a low-pass filter before downsampling would reduce this aliasing.

![Original, downsampled, and upscaled test image](figures/04-sampling.png)

## 5. Optional moiré demonstration

The original diagonal stripes have a horizontal frequency of 0.108 cycles per original pixel. After taking one sample every ten pixels, that frequency appears as 0.008 cycles per original pixel in the horizontal direction. The reconstructed image shows this aliasing as a broad stripe pattern called moiré.

![Fine diagonal stripes and the resulting moiré pattern](figures/05-moire.png)

## 6. Short reflections

1. **How does bit depth affect banding?** Fewer levels make nearby shades share the same value. In the 4-bit image, this creates visible steps across the smooth background.
2. **How does contrast stretching affect the histogram and details?** It spreads the middle intensities over a wider range, making their differences easier to see. Clipping also increases the counts at 0 and 255 and removes some tonal differences at the extremes.
3. **Why does aggressive downsampling cause aliasing?** A lower sampling rate reduces the Nyquist limit. Without prefiltering, frequencies above that limit can appear as false lower-frequency patterns, such as the broad stripes in the moiré example.
