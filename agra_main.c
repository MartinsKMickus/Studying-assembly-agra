#include <stdio.h>
#include "agra.h"

int main()
{
    pixcolor_t current_pixel;
    current_pixel.r = 512;
    current_pixel.g = 512;
    current_pixel.b = 512;
    pixel(15, 15, &current_pixel);
    FrameShow();
    // printf("R is: %d\n", current_pixel.r);
    // printf("G is: %d\n", current_pixel.g);
    // printf("B is: %d\n", current_pixel.b);
    // printf("OP is: %d\n", current_pixel.op);
}