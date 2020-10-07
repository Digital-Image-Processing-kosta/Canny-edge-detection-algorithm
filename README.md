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


# TEST
Run the **main.m** to test the algorithm.
