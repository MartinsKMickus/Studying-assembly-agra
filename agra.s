.global pixel
putpixel:
    # Ieejā jābūt r1 = X, r2 = Y, r
    push {lr}
    # Pārbaude vai X vai Y nav ārpusē
    cmp r5, r1
    beq endputpixel
    bmi endputpixel
    cmp r6, r2
    beq endputpixel
    bmi endputpixel
    mla r0, r2, r5, r1
    lsl r0, r0, #4
    add r0, r4
    str r3, [r0]
    pop {pc}
endputpixel:
    mov r0, #-1
    pop {pc}
pixel:
    push {r4, r5, r6, lr}
    # Move r0,r1,r2 = X, Y, Col -> r1,r2,r3
    push {r0,r1,r2}
    # Get address to r0
    bl FrameBufferGetAddress
    mov r4, r0
    bl FrameBufferGetWidth
    mov r5, r0
    bl FrameBufferGetHeight
    mov r6, r0
    pop {r0,r1,r2}
    ldr r3, [r2]
    mov r2, r1
    mov r1, r0
    bl putpixel
    # str r3, [r4, #16]
    # ldr r0, [r0]

fastend:
    pop {r4, r5, r6, lr}
    bx lr
