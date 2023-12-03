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
    PUSH {R4, R5, R6, LR}
    # Move R0,R1,R2 = X, Y, Col -> R1,R2,R3
    BL getbufferinfo
    LDR R3, [R2]
    MOV R2, R1
    MOV R1, R0
    BL putpixel

fastend:
    POP {R4, R5, R6, LR}
    BX LR

line:
    # Ieeja:
    # R0 = X0
    # R1 = Y0
    # R2 = X1 -> R12 (vēlāk)
    # R3 = Y1
    # Pārējie dati:
    # R4 = dx
    # R5 = dy
    # R7 = dE
    # R8 = dNE
    # R9 = d
    # R10= x
    # R11= y
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
    MOV R12, R2
    # y = y0
    MOV R2, R1
    # Ielādēt info par buferi
    BL getbufferinfo

    # TEMP Aizpilda tikai pirmās kordinātas pikseli
    MOV R3, #0xFFFFFFFF
    BL putpixel
    POP {R4-R12, LR}
# whilelinexless:


    # OTHER SOLUTION:
    #PUSH {R0-R4}
    # if abs(y1 - y0) < abs(x1 - x0)
    # SUB R4, R3, R1
    # CMP R4, #0
    # Ja negatīvs, tad maina zīmi.
    # RSBLT R4, R4, #0
    # SUB R5, R2, R0
    # CMP R5, #0
    # RSBLT R5, R5, #0
    #MOV R0, R5

    # CMP R4, R5
    # BLT absy1minusy0lowerabsx1minusx0
    # POP {R4-R11, LR}


# absy1minusy0lowerabsx1minusx0:
    # if x0 > x1
    # CMP R0, R2
    # BGT

