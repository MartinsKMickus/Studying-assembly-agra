#include <stdio.h>
#include "agra.h"

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
    // notīrīt buferi, aizpildīt katru pikseli ar 0x00000000
    while (x < xmax)
    {
        while (y<ymax)
        {
            pixel(x, y, &current_pixel);
            y++;
        }
        y = 0;
        x++;
    }
    // zīmēt pikseli koordinātās (25,2), baltu
    current_pixel.r = 1023;
    current_pixel.g = 1023;
    current_pixel.b = 1023;
    pixel(25, 2, &current_pixel);

    // zīmēt līniju no (0,0) līdz (39,19), zilu, ar intensitāti 0x03ff
    current_pixel.r = 0;
    current_pixel.g = 0;
    current_pixel.b = 0x03ff;
    setPixColor(&current_pixel);
    line(0, 0, 39, 19);

    // zīmēt aizpildītu trijstūri: (20,13), (28,19), (38,6), zaļu, ar intensitāti 0x03ff
    current_pixel.r = 0;
    current_pixel.g = 0x03ff;
    current_pixel.b = 0;
    // current_pixel.op = 3;
    setPixColor(&current_pixel);
    triangleFill(20,13,28,19,38,6);

    // zīmēt riņķa līniju ar centru (20,10) un rādiusu 7, sarkanu, ar intensitāti 0x03ff
    current_pixel.r = 0x03ff;
    current_pixel.g = 0;
    current_pixel.b = 0;
    // current_pixel.op = 0;
    setPixColor(&current_pixel);
    circle(20, 10, 7);

    // izsaukt funkciju FrameShow()
    FrameShow();
}