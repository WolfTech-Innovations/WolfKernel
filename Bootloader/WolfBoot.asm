BITS 16
ORG 0x7C00

; Set up stack
cli
xor ax, ax
mov ss, ax
mov sp, 0x7C00
sti

; Print a message
mov ah, 0x0E
mov si, msg
.print_char:
    lodsb
    or al, al
    jz .load_kernel
    int 0x10
    jmp .print_char

.load_kernel:
; Load the kernel into 0x10000
mov bx, 0x1000      ; Segment to load at 0x10000 (0x1000 * 16)
mov ah, 0x02         ; BIOS read sector function
mov al, 10           ; Read 10 sectors (adjust this to match kernel size)
mov ch, 0x00         ; Cylinder 0
mov dh, 0x00         ; Head 0
mov cl, 0x02         ; Start at sector 2 (sector 1 is the kernel start)
mov dl, 0x00         ; Boot drive (floppy)

int 0x13             ; BIOS interrupt to read sectors
jc .load_error       ; Jump if there is an error

; Jump to the loaded kernel
jmp 0x1000:0000

.load_error:
mov si, error_msg
jmp .print_char

; Message data
msg db 'Welcome to WolfOS 1.2.1', 0
error_msg db 'Error loading kernel!', 0

; Fill to 510 bytes
TIMES 510 - ($ - $$) db 0
DW 0xAA55             ; Boot signature
