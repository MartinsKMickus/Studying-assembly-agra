#include <stdio.h>
#include "agra.h"
#include <unistd.h> // Sleep

int main()
{
    int x = 0, xmax, y = 0, ymax;
    pixcolor_t current_pixel;
    current_pixel.r = 0;
    current_pixel.g = 0;
    current_pixel.b = 0;
    current_pixel.op = 0;
    xmax = FrameBufferGetWidth();
    ymax = FrameBufferGetHeight();
    while (x < xmax)
    {
        while (y<ymax)
        {
            pixel(x, y, &current_pixel);
            y++;
        }
        x++;
    }
    current_pixel.r = 1023;
    current_pixel.g = 1023;
    current_pixel.b = 1023;
    current_pixel.op = 0;
    pixel(10, 5, &current_pixel);
    // current_pixel.r = 0;
    // current_pixel.g = 1023;
    // current_pixel.b = 0;
    setPixColor(&current_pixel);
    line(2, 2, 40, 8);
    line(2, 2, 8, 12);
    // printf("Pix returned: %u", returned);
    // current_pixel.g = 0;
    // current_pixel.b = 1023;
    // setPixColor(&current_pixel);
    circle(40, 10, 7);
    // current_pixel.r = 1023;
    // current_pixel.b = 0;
    // setPixColor(&current_pixel);
    line(5, 9, 25, 3);
    FrameShow();
    // printf("R is: %d\n", current_pixel.r);
    // printf("G is: %d\n", current_pixel.g);
    // printf("B is: %d\n", current_pixel.b);
    // printf("OP is: %d\n", current_pixel.op);
}