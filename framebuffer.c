#include <stdio.h>
#include <stdlib.h>
#include "agra.h"

#define STRUCTSIZE 32

#define WIDTH 40
#define HEIGHT 20

pixcolor_t * framebuffer = NULL;

pixcolor_t * FrameBufferGetAddress()
{
    if  (framebuffer == NULL)
    {
        framebuffer = (pixcolor_t*) malloc(WIDTH * HEIGHT * STRUCTSIZE);
    }
    return framebuffer;
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
    unsigned int w_counter = 0;
    while (p - framebuffer < framebuffer - framebuffer + WIDTH * HEIGHT * STRUCTSIZE)
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
                    printf("?");
                }
            }
        }
        if (++w_counter >= WIDTH)
        {
            printf("\n");
            w_counter = 0;
        }
        
        p+=32;
    }
    
    return 0;
}