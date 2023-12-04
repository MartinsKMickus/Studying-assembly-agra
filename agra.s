.global pixel
.global line
putpixel:
    # Ieejā jābūt R1 = X, R2 = Y, R3 = PIXEL, R4 = ADDRESS, R5 = Xmax, R6 = Ymax, 
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

line:
    # Ieeja:
    # R0 = X0
    # R1 = Y0
    # R2 = X1 -> R10 (vēlāk)
    # R3 = Y1
    # Pārējie dati:
    # R4 = dx
    # R5 = dy
    # R7 = dE
    # R8 = dNE
    # R9 = d
    PUSH {R4-R12, LR}
    # dx = x1-x0
    SUB R4, R2, R0
    # dy = y1-y0
    SUB R5, R3, R1
    # d = 2 * dy - dx
    LSL R9, R5, #1
    SUB R9, R9, R4
    # dE = 2 * dy
    LSL R7, R5, #1
    # dNE = 2 * (dy - dx)
    SUB R8, R5, R4
    LSL R8, R8, #1
    # x = x0
    MOV R1, R0
    # Saglabāt R2 pirms tur iet R1.
    MOV R10, R2
    # y = y0
    MOV R2, R1
    # Ielādēt info par buferi
    BL getbufferinfo
    # R0 = FREE
    # R1 = X
    # R2 = Y
    # R3 = -
    # R4 = ADDRESS
    # R5 = Xmax
    # R6 = Ymax
    # R7 = dE
    # R8 = dNE
    # R9 = d
    # R10= X1
    # TEMP
    MOV R3, #0xFFFFFFFF
linewhile:
    # while(x<x1)
    CMP R1, R10
    BGE fastend
    CMP R9, #0
    # if(d<=0)
    BGT linedhigh
linedlesse:
    # d+=dE
    # ++x
    ADD R9, R9, R7
    ADD R1, R1, #1
    B linepixel
linedhigh:
    # d+=dNE
    # ++x
    # ++y
    ADD R9, R9, R8
    ADD R1, R1, #1
    ADD R2, R2, #1
linepixel:
    BL putpixel
    B linewhile
    # POP {R4-R12, LR}
# whilelinexless:


    # OTHER SOLUTION:
    # https://en.wikipedia.org/wiki/Bresenham%27s_line_algorithm
line2:
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
    # 
    # BLT absy1minusy0lowerabsx1minusx0
    # POP {R4-R11, LR}


# absy1minusy0lowerabsx1minusx0:
    # if x0 > x1
    # CMP R0, R2
    # BGT

