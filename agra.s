.global pixel
.global line
putpixel:
    # Ieeja
    # R1 = X
    # R2 = Y
    # R3 = PIXEL
    # R4 = ADDRESS
    # R5 = Xmax
    # R6 = Ymax 
    PUSH {LR}
    # Pārbaude vai X vai Y nav ārpusē
    CMP R5, R1
    BEQ endputpixel
    BMI endputpixel
    CMP R6, R2
    BEQ endputpixel
    BMI endputpixel
    mla R0, R2, R5, R1
    LSL R0, R0, #2
    # add R0, R4
    STR R3, [R0, R4]
endputpixel:
    POP {PC}

getbufferinfo:
    PUSH {LR}
    PUSH {R0-R3, R12}
    BL FrameBufferGetAddress
    MOV R4, R0
    BL FrameBufferGetWidth
    MOV R5, R0
    BL FrameBufferGetHeight
    MOV R6, R0
    POP {R0-R3, R12}
    POP {PC}
pixel:
    # Ieeja:
    # R0 = X
    # R1 = Y
    # R2 = pixcolor_t
    PUSH {R4-R12, LR}
    # Move R0,R1,R2 = X, Y, Col -> R1,R2,R3
    BL getbufferinfo
    LDR R3, [R2]
    MOV R2, R1
    MOV R1, R0
    BL putpixel

fastend:
    POP {R4-R12, LR}
    BX LR

@ line:
@     # Ieeja:
@     # R0 = X0
@     # R1 = Y0
@     # R2 = X1 -> R10 (vēlāk)
@     # R3 = Y1
@     # Pārējie dati:
@     # R4 = dx
@     # R5 = dy
@     # R7 = dE
@     # R8 = dNE
@     # R9 = d
@     PUSH {R4-R12, LR}
@     # dx = x1-x0
@     SUB R4, R2, R0
@     # dy = y1-y0
@     SUB R5, R3, R1
@     # d = 2 * dy - dx
@     LSL R9, R5, #1
@     SUB R9, R9, R4
@     # dE = 2 * dy
@     LSL R7, R5, #1
@     # dNE = 2 * (dy - dx)
@     SUB R8, R5, R4
@     LSL R8, R8, #1
@     # x = x0
@     MOV R1, R0
@     # Saglabāt R2 pirms tur iet R1.
@     MOV R10, R2
@     # y = y0
@     MOV R2, R1
@     # Ielādēt info par buferi
@     BL getbufferinfo
@     # R0 = FREE
@     # R1 = X
@     # R2 = Y
@     # R3 = -
@     # R4 = ADDRESS
@     # R5 = Xmax
@     # R6 = Ymax
@     # R7 = dE
@     # R8 = dNE
@     # R9 = d
@     # R10= X1
@     # TEMP
@     MOV R3, #0xFFFFFFFF
@ linewhile:
@     # while(x<x1)
@     CMP R1, R10
@     BGE fastend
@     CMP R9, #0
@     # if(d<=0)
@     BGT linedhigh
@ linedlesse:
@     # d+=dE
@     # ++x
@     ADD R9, R9, R7
@     ADD R1, R1, #1
@     B linepixel
@ linedhigh:
@     # d+=dNE
@     # ++x
@     # ++y
@     ADD R9, R9, R8
@     ADD R1, R1, #1
@     ADD R2, R2, #1
@ linepixel:
@     BL putpixel
@     B linewhile


    # OTHER SOLUTION:
    # https://en.wikipedia.org/wiki/Bresenham%27s_line_algorithm
line:
    # Ieeja:
    # R0 = X0
    # R1 = Y0
    # R2 = X1
    # R3 = Y1
    PUSH {R4-R12, LR}
    # if abs(y1 - y0) < abs(x1 - x0)
    SUB R4, R3, R1
    CMP R4, #0
    # Ja negatīvs, tad maina zīmi.
    RSBLT R4, R4, #0
    SUB R5, R2, R0
    CMP R5, #0
    RSBLT R5, R5, #0
    CMP R4, R5
    # R4 un R5 vairs nevajag.
    BGE plottinglinehigh
plottinglinelow:
    CMP R0, R2
    BLGT lineswitchsides
    B plotlinelow
plottinglinehigh:
    CMP R1, R3
    BLGT lineswitchsides
    B plotlinehigh
lineswitchsides:
    # Samainīt vietām x0, y0 ar x1, y1
    PUSH {LR}
    MOV R4, R0
    MOV R0, R2
    MOV R2, R4
    MOV R4, R1
    MOV R1, R3
    MOV R3, R4
    POP {PC}

plotlinelow:
    # R0 = X0
    # R1 = Y0
    # R2 = X1 -> R7
    MOV R7, R2
    # R3 = Y1
    # R7 = X1
    # R8 = dx
    # R9 = dy
    # R10= yi
    # R11= D
    # dx = x1 - x0
    SUB R8, R7, R0
    # dy = y1 - y0
    SUB R9, R3, R1
    # yi = 1
    MOV R10, #1
    # if dy < 0
    CMP R9, #0
    BGE continueplotlinelow
    # yi = -1
    MOV R10, #-1
    # dy = -dy
    RSB R9, R9, #0
continueplotlinelow:
    # D = (2 * dy) - dx
    LSL R11, R9, #1
    SUB R11, R11, R8
    BL getbufferinfo
    # R0 = FREE
    # R1 = X
    # R2 = Y
    MOV R2, R1
    MOV R1, R0
    # R3 = -
    # R4 = ADDRESS
    # R5 = Xmax
    # R6 = Ymax
    # R7 = X1
    # R8 = dx
    # R9 = dy
    # R10= yi
    # R11= D
    # TEMP
    MOV R3, #0xFFFFFFFF
linelowloop:
    # for x from x0 to x1
    CMP R1, R7
    BGT fastend
    BL putpixel
    # if D > 0
    CMP R11, #0
    BLE linelowloopno
linelowloopyes:
    # y = y + yi
    ADD R2, R2, R10
    # D = D + (2 * (dy - dx))
    SUB R0, R9, R8
    ADD R11, R11, R0, LSL #1
    B repeatlinelowloop
linelowloopno:
    # D = D + 2*dy
    ADD R11, R11, R9, LSL #1
repeatlinelowloop:
    ADD R1, R1, #1
    B linelowloop


plotlinehigh:
    # R0 = X0
    # R1 = Y0
    # R2 = X1
    # R3 = Y1 -> R7
    MOV R7, R3
    # R7 = Y1
    # R8 = dx
    # R9 = dy
    # R10= xi
    # R11= D
    # dx = x1 - x0
    SUB R8, R7, R0
    # dy = y1 - y0
    SUB R9, R3, R1
    # xi = 1
    MOV R10, #1
    # if dx < 0
    CMP R8, #0
    BGE continueplotlinehigh
    # xi = -1
    MOV R10, #-1
    # dx = -dx
    RSB R8, R8, #0
continueplotlinehigh:
    # D = (2 * dx) - dy
    LSL R11, R8, #1
    SUB R11, R11, R9
    BL getbufferinfo
    # R0 = FREE
    # R1 = X
    # R2 = Y
    MOV R2, R1
    MOV R1, R0
    # R3 = -
    # R4 = ADDRESS
    # R5 = Xmax
    # R6 = Ymax
    # R7 = Y1
    # R8 = dx
    # R9 = dy
    # R10= xi
    # R11= D
    # TEMP
    MOV R3, #0xFFFFFFFF
linehighloop:
    # for y from y0 to y1
    CMP R2, R7
    BGT fastend
    BL putpixel
    # if D > 0
    CMP R11, #0
    BLE linehighloopno
linehighloopyes:
    # x = x + xi
    ADD R1, R1, R10
    # D = D + (2 * (dx - dy))
    SUB R0, R8, R9
    ADD R11, R11, R0, LSL #1
    B repeatlinehighloop
linehighloopno:
    # D = D + 2*dx
    ADD R11, R11, R8, LSL #1
repeatlinehighloop:
    ADD R2, R2, #1
    B linehighloop
