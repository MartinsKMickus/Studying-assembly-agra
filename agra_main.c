#include <stdio.h>
#include "agra.h"
#include <unistd.h> // Sleep

int main()
{
    pixcolor_t current_pixel;
    current_pixel.r = 512;
    current_pixel.g = 512;
    current_pixel.b = 512;
    pixel(10, 5, &current_pixel);
    FrameShow();
    line(2, 2, 40, 8);
    sleep(1);
    FrameShow();
    line(2, 2, 8, 12);
    sleep(1);
    FrameShow();
    line(5, 9, 25, 3);
    sleep(1);
    // printf("line returned: %d", returned);
    FrameShow();
    circle(40, 10, 7);
    sleep(1);
    // printf("Circle returned: %d", returned);
    FrameShow();
    // printf("R is: %d\n", current_pixel.r);
    // printf("G is: %d\n", current_pixel.g);
    // printf("B is: %d\n", current_pixel.b);
    // printf("OP is: %d\n", current_pixel.op);
}