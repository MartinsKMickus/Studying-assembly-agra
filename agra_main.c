#include <stdio.h>
#include "agra.h"

int main()
{
    pixcolor_t current_pixel;
    *(unsigned int *)&current_pixel = 0x3FFFFFFF;
    pixel(10, 10, &current_pixel);
    FrameShow();
    // printf("R is: %d\n", current_pixel.r);
    // printf("G is: %d\n", current_pixel.g);
    // printf("B is: %d\n", current_pixel.b);
    // printf("OP is: %d\n", current_pixel.op);
}