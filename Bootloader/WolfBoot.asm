BITS 16
ORG 0x7C00

; Set up stack
cli
xor ax, ax
mov ss, ax
mov sp, 0x7C00
sti

; Initialize the video mode (to simulate GUI-like appearance)
mov ah, 0x0F         ; Get current video mode
int 0x10             ; Call BIOS interrupt to get the current mode
mov ah, 0x00         ; Set video mode to 03h (Text Mode 80x25 Color)
int 0x10             ; Set the video mode to standard color text mode

; Declare a variable to track the selected option
current_option db 1  ; Start with option 1 selected

; Print startup message
mov ah, 0x0E
mov si, startup_msg
jmp .print_char

.print_char:
    lodsb
    or al, al
    jz .show_menu
    int 0x10
    jmp .print_char

.show_menu:
; Display the GUI-like menu interface
mov si, menu_option1
call .print_option
mov si, menu_option2
call .print_option
mov si, menu_option3
call .print_option
mov si, menu_option4
call .print_option

; Now wait for user input
.wait_for_input:
    mov ah, 0x00        ; BIOS input function
    int 0x16            ; Get keystroke
    cmp al, 0x48        ; Up arrow key
    je .move_up         ; If Up arrow key, move selection up
    cmp al, 0x50        ; Down arrow key
    je .move_down       ; If Down arrow key, move selection down
    cmp al, 0x0D        ; Enter key
    je .select_option   ; If Enter is pressed, select option
    jmp .wait_for_input ; Continue waiting for valid input

.move_up:
    ; Decrease current_option (wrap around if necessary)
    dec byte [current_option]
    cmp byte [current_option], 1
    jge .show_menu
    mov byte [current_option], 4  ; Wrap around to 4 (if at 1)
    jmp .show_menu

.move_down:
    ; Increase current_option (wrap around if necessary)
    inc byte [current_option]
    cmp byte [current_option], 5
    jl .show_menu
    mov byte [current_option], 1  ; Wrap around to 1 (if at 4)
    jmp .show_menu

.select_option:
    ; Handle menu selection
    cmp byte [current_option], 1
    je .load_kernel
    cmp byte [current_option], 2
    je .option_2
    cmp byte [current_option], 3
    je .option_3
    cmp byte [current_option], 4
    je .exit

.load_kernel:
    ; Load the kernel into 0x10000
    mov bx, 0x1000      ; Segment to load at 0x10000 (0x1000 * 16)
    mov ah, 0x02         ; BIOS read sector function
    mov al, 64           ; Read 64 sectors (adjust this based on kernel size)
    mov ch, 0x00         ; Cylinder 0
    mov dh, 0x00         ; Head 0
    mov cl, 0x02         ; Start at sector 2
    mov dl, 0x00         ; Boot drive (floppy)
    
    int 0x13             ; BIOS interrupt to read sectors
    jc .load_error       ; Jump if there is an error

    ; Set up real mode registers for the kernel
    mov ax, 0x0000       ; Zero out AX
    mov es, ax           ; Set ES to 0
    mov bx, 0x9000       ; Boot parameters address (0x9000:0000)
    mov word [es:0x1FC], 0x0202 ; Indicate bootloader supports 2.02+ boot protocol

    ; Jump to the loaded kernel at 0x10000
    jmp 0x1000:0000

.option_2:
    ; Action for Option 2
    mov si, option2_msg
    call .print_char
    jmp .wait_for_input

.option_3:
    ; Action for Option 3
    mov si, option3_msg
    call .print_char
    jmp .wait_for_input

.exit:
    ; Exit and stop the boot process
    mov si, exit_msg
    call .print_char
    hlt

.load_error:
    mov si, error_msg
    call .print_char
    hlt

.print_option:
    ; Print menu option
    lodsb
    or al, al
    jz .next_option
    int 0x10
    jmp .print_option

.next_option:
    ret

; Message data
startup_msg db 'Welcome to WolfBoot!', 0
menu_option1 db '1. Load Kernel', 0
menu_option2 db '2. Option 2', 0
menu_option3 db '3. Option 3', 0
menu_option4 db '4. Exit', 0
option2_msg db 'You selected Option 2!', 0
option3_msg db 'You selected Option 3!', 0
exit_msg db 'Exiting... Goodbye!', 0
error_msg db 'Error loading kernel!', 0

; Fill to 510 bytes
TIMES 510 - ($ - $$) db 0
DW 0xAA55             ; Boot signature
