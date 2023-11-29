.global pixel
pixel:
    push {lr}
    bl FrameBufferGetAddress
    pop {lr}
    bx lr
