.section .data
pixcolor:
    .space 4
lastx:
    .space 4
lasty:
    .space 4
.section .text
.global setPixColor
.global pixel
.global line
.global circle
setPixColor:
    LDR R1, =pixcolor
    LDR R0, [R0]
    STR R0, [R1]
    BX LR
putpixel:
    # Ieeja
    # R1 = X
    # R2 = Y
    # R3 = PIXEL
    # R4 = ADDRESS
    # R5 = Xmax
    # R6 = Ymax 
    PUSH {LR}
    PUSH {R7-R8}
    @ Pārbaude vai tikko jau nebija. Ja pikselis bija, tad izlaiž. XOR operācijas glābšana
    LDR R7, =lastx @ Ielādē X adresi
    LDR R8, =lasty @ Ielādē Y adresi
    LDR R0, [R7]
    CMP R0, R1
    BNE continueputpixel
    LDR R0, [R8]
    CMP R0, R2
    BEQ endputpixel
continueputpixel:
    STR R1, [R7] @ Saglabā X R7
    STR R2, [R8] @ Saglabā Y R8

    @ Pārbaude vai X vai Y nav ārpusē
    CMP R5, R1
    BEQ endputpixel
    BMI endputpixel
    CMP R6, R2
    BEQ endputpixel
    BMI endputpixel
    MLA R0, R2, R5, R1
    LSL R0, R0, #2
    LSR R7, R3, #30
    CMP R7, #1
    BEQ putpixeland
    CMP R7, #2
    BEQ putpixelor
    CMP R7, #3
    BEQ putpixelxor
    STR R3, [R0, R4]
endputpixel:
    POP {R7-R8}
    POP {PC}

putpixeland:
    LDR R7, [R0, R4]
    AND R3, R3, R7
    STR R3, [R0, R4]
    B endputpixel
putpixelor:
    LDR R7, [R0, R4]
    ORR R3, R3, R7
    STR R3, [R0, R4]
    B endputpixel
putpixelxor:
    LDR R7, [R0, R4]
    EOR R3, R3, R7
    STR R3, [R0, R4]
    MOV R0, R7
    B endputpixel

getbufferinfo:
    PUSH {LR}
    PUSH {R0-R2, R12}
    BL FrameBufferGetAddress
    MOV R4, R0
    BL FrameBufferGetWidth
    MOV R5, R0
    BL FrameBufferGetHeight
    MOV R6, R0
    LDR R3, =pixcolor
    LDR R3, [R3]
    POP {R0-R2, R12}
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
    LDR R1, =lastx @ Ielādē X adresi
    LDR R2, =lasty @ Ielādē Y adresi
    MOV R0, #-1
    STR R0, [R1]
    STR R0, [R2]
    POP {R4-R12, LR}
    BX LR

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

# Apļa līnija: https://en.wikipedia.org/wiki/Midpoint_circle_algorithm
circle:
    PUSH {R4-R12, LR}
    # Ieeja:
    # R0 = X -> R1
    # R1 = Y -> R2
    # R2 = R -> R7
    MOV R7, R2
    MOV R2, R1
    MOV R1, R0
    BL getbufferinfo
    # R0 = FREE
    # R1 = X
    # R2 = Y
    # R3 = -
    # R4 = ADDRESS
    # R5 = Xmax
    # R6 = Ymax
    # R7 = R
    # R8 = t1
    # R9 = pre-x
    # R10= pre-y
    # R11= t2
    # t1 = r / 16
    MOV R8, R7, LSR #4 @ Dalīt ar 16
    @ x = r
    MOV R9, R7
    @ y = 0
    MOV R10, #0
circleloop:
    @ Repeat Until x < y
    CMP R9, R10
    BLT fastend
    @ PIXEL
    BL circlepoint1
    BL circlepoint2
    BL circlepoint3
    BL circlepoint4
    BL circlepoint5
    BL circlepoint6
    BL circlepoint7
    BL circlepoint8
    @ y = y + 1
    ADD R10, R10, #1
    @ t1 = t1 + y
    ADD R8, R8, R10
    @ t2 = t1 - x
    SUB R11, R8, R9
    @ If t2 >= 0 (Ja neizpildās, tad aktārto)
    CMP R11, #0
    BLT circleloop
    @ t1 = t2
    MOV R8, R11
    @ x = x - 1
    SUB R9, R9, #1
    B circleloop

circlepoint1:
    @ (x, y)
    PUSH {LR}
    ADD R1, R1, R9
    ADD R2, R2, R10
    BL putpixel
    SUB R1, R1, R9
    SUB R2, R2, R10
    POP {PC}
circlepoint2:
    @ (x,-y)
    PUSH {LR}
    ADD R1, R1, R9
    SUB R2, R2, R10
    BL putpixel
    SUB R1, R1, R9
    ADD R2, R2, R10
    POP {PC}
circlepoint3:
    @ (y,-x)
    PUSH {LR}
    ADD R1, R1, R10
    SUB R2, R2, R9
    BL putpixel
    SUB R1, R1, R10
    ADD R2, R2, R9
    POP {PC}
circlepoint4:
    @ (-y,-x)
    PUSH {LR}
    SUB R1, R1, R10
    SUB R2, R2, R9
    BL putpixel
    ADD R1, R1, R10
    ADD R2, R2, R9
    POP {PC}
circlepoint5:
    @ (-x, -y)
    PUSH {LR}
    SUB R1, R1, R9
    SUB R2, R2, R10
    BL putpixel
    ADD R1, R1, R9
    ADD R2, R2, R10
    POP {PC}
circlepoint6:
    @ (-x, y)
    PUSH {LR}
    SUB R1, R1, R9
    ADD R2, R2, R10
    BL putpixel
    ADD R1, R1, R9
    SUB R2, R2, R10
    POP {PC}
circlepoint7:
    @ (-y,x)
    PUSH {LR}
    SUB R1, R1, R10
    ADD R2, R2, R9
    BL putpixel
    ADD R1, R1, R10
    SUB R2, R2, R9
    POP {PC}
circlepoint8:
    @ (y,x)
    PUSH {LR}
    ADD R1, R1, R10
    ADD R2, R2, R9
    BL putpixel
    SUB R1, R1, R10
    SUB R2, R2, R9
    POP {PC}
