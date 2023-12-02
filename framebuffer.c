#include <stdio.h>
#include <stdlib.h>
#include "agra.h"

#define WIDTH 80
#define HEIGHT 20

pixcolor_t * framebuffer = NULL;

pixcolor_t * FrameBufferGetAddress()
{
    if  (framebuffer == NULL)
    {
        framebuffer = (pixcolor_t*) malloc(WIDTH * HEIGHT * sizeof(pixcolor_t));
    }
    return framebuffer;
}

int FrameBufferGetWidth()
{
    return WIDTH;
}

int FrameBufferGetHeight()
{
    return HEIGHT;
}

int FrameShow()
{
    // printf("Min Address: %d\n", (int)framebuffer);
    // printf("Max Address: %d\n", maxaddress);
    if (framebuffer == NULL)
    {
        return 1;
    }
    pixcolor_t * p = framebuffer;
    pixcolor_t *end = framebuffer + WIDTH * HEIGHT;
    unsigned int w_counter = 0;
    // printf("p - framebuffer = %ld\n", (long unsigned)p - (long unsigned)framebuffer);
    // printf("Second equation = %ld\n", (long unsigned)(WIDTH * HEIGHT * STRUCTSIZE));
    while (p < end)
    {
        if (p->r>511)
        {
            if (p->g>511)
            {
                if (p->b>511)
                {
                    printf("*");
                }
                else
                {
                    printf("\033[1;33mY\033[1;0m");
                }
                
            }
            else
            {
                if (p->b>511)
                {
                    printf("\033[1;35mM\033[1;0m");
                }
                else
                {
                    printf("\033[1;31mR\033[1;0m");
                }
            }
        }
        else
        {
            if (p->g>511)
            {
                if (p->b>511)
                {
                    printf("\033[1;36mC\033[1;0m");
                }
                else
                {
                    printf("\033[1;32mG\033[1;0m");
                }
                
            }
            else
            {
                if (p->b>511)
                {
                    printf("\033[1;34mB\033[1;0m");
                }
                else
                {
                    printf(" ");
                }
            }
        }
        if (++w_counter >= WIDTH)
        {
            printf("\n");
            w_counter = 0;
        }
        
        p++;
    }
    
    return 0;
}