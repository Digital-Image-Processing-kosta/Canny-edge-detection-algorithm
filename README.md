# CANNY EDGE DETECTION ALGORITHM
Matlab implementation of Canny edge detection algorithm from scratch.
# IMPLEMENTATION
Algorithm contains following steps:<br />
**1.** Filtering input image with Gaussian filter with given standard deviation (filter size should be equal or greater than 6 * sigma)<br />
**2.** Determining horizontal and vertical gradients of the filtered image<br />

Original Image             |  Gradients in x direction | Gradients in y direction
:-------------------------:|:-------------------------:|:-------------------------:
![o1](https://github.com/Digital-Image-Processing-kosta/Canny-edge-detection-algorithm/blob/master/garbage/15.png)  |  ![gx](https://github.com/Digital-Image-Processing-kosta/Canny-edge-detection-algorithm/blob/master/garbage/13.png) | ![gy](https://github.com/Digital-Image-Processing-kosta/Canny-edge-detection-algorithm/blob/master/garbage/14.png)

**3.** Determining magnitude and angle od the gradients with following formulas:<br />
![img 15](https://github.com/Digital-Image-Processing-kosta/Canny-edge-detection-algorithm/blob/master/garbage/18.png)

Gradient magnitude            |  Gradient angle
:-------------------------:|:-------------------------:
![o1](https://github.com/Digital-Image-Processing-kosta/Canny-edge-detection-algorithm/blob/master/garbage/16.png)  |  ![gx](https://github.com/Digital-Image-Processing-kosta/Canny-edge-detection-algorithm/blob/master/garbage/17.png)

**4.** Quantization of the angle of the gradient on the following directions: 0, -45, 45, 90 degrees.<br />
![quantization](https://github.com/Digital-Image-Processing-kosta/Canny-edge-detection-algorithm/blob/master/garbage/19.png)<br />
**5.** Supression of the gradients that do not represent local maximum.<br />
We iterate thorugh every pixel of the magnitude of the gradient and we read qunatized value of the gradient angle for that pixel. For every direction of the gradient angle specific matrix of 0s and 1s is defined:<br />
![matriciies](https://github.com/Digital-Image-Processing-kosta/Canny-edge-detection-algorithm/blob/master/garbage/25.png)<br />
We take the matrix that corresponds to the read quantized value of the gradient angle and multiply it with 3x3 gradient magnitude surrounding of the pixel. If the maximum value in the resulting 3x3 matrix is not in the middle, the pixel value is set to zero. This must NOT be done inplace!<br />
![supression](https://github.com/Digital-Image-Processing-kosta/Canny-edge-detection-algorithm/blob/master/garbage/20.png)<br />
**6.** Determining the maps of weak and strong edges based on low and high threshold.<br />
All values of the magnitude of the gradient that are higher than T_high are set to value 1 in the map of the combined edges and they go into the map of the strong edges. All values between T_low and T_high are set to value 50/250 in the map of the combined edges and they go into the map of the weak edges. All values below T_low are set to 0.<br />

Weak edges             |  Strong edges | Combined edges
:-------------------------:|:-------------------------:|:-------------------------:
![o1](https://github.com/Digital-Image-Processing-kosta/Canny-edge-detection-algorithm/blob/master/garbage/15.png)  |  ![gx](https://github.com/Digital-Image-Processing-kosta/Canny-edge-detection-algorithm/blob/master/garbage/13.png) | ![gy](https://github.com/Digital-Image-Processing-kosta/Canny-edge-detection-algorithm/blob/master/garbage/14.png)

# TEST
Run the **main.m** to test the algorithm.
