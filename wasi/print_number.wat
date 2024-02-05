(module
  (import "wasi_snapshot_preview1" "fd_write" (func $fd_write (param i32 i32 i32 i32) (result i32)))
  (import "wasi_snapshot_preview1" "proc_exit" (func $proc_exit (param i32)))

  ;; Memory declaration
  (memory (export "memory") 1)

  ;; Data for iovec struct
  (data (i32.const 0) "\08\00\00\00") ;; start of data buffer
  (data (i32.const 4) "\0e\00\00\00") ;; length of data buffer

  (func $main

    (i32.const 8) ;; string buffer start address
    (i32.const 1234) ;; number to convert
    (call $i32_to_string)

    ;; Add a newline to the data buffer after adding number to it
    (i32.const 0x0A) ;; 0x0A is the ASCII hex representation of "newline"
    (i32.store8) ;; Accepts a memory address first, and a value second

    ;; Call fd_write to write the message to stdout
    (i32.const 1)  ;; File descriptor for stdout
    (i32.const 0)  ;; iovec pointer
    (i32.const 1)  ;; Length of iovec array
    (i32.const 20) ;; Pointer to store number of bytes written (can be anywhere, just example)
    (call $fd_write)

    ;; Discard the result of fd_write
    (drop)

    ;; Exit the program with status code 0
    (i32.const 0)
    (call $proc_exit)
  )

  ;; Put string representation of unsigned 32 bit integer into memory address
  (func $i32_to_string (param $memAddr i32) (param $number i32) (result i32)
    (local $digit i32)
    (local $startAddr i32)
    (local $tempAddr i32)
    (local $endAddr i32)
    (local $tempDigit i32)

    ;; Store the start address to reverse the string later
    (local.set $startAddr (local.get $memAddr))

    ;; Convert each digit to ASCII and store it in memory
    (block $done
      (loop $loop
        (local.set $digit
          (i32.add
            (i32.rem_u (local.get $number) (i32.const 10))
            (i32.const 48)))
        (i32.store8 (local.get $memAddr) (local.get $digit))
        (local.set $memAddr (i32.add (local.get $memAddr) (i32.const 1)))
        (local.set $number (i32.div_u (local.get $number) (i32.const 10)))
        (br_if $done (i32.eqz (local.get $number)))
        (br $loop)
      )
    )

    ;; Update $endAddr to point to the last numeric character
    (local.set $endAddr (i32.sub (local.get $memAddr) (i32.const 1)))

    ;; Reverse the string
    (block $reverse_done
      (loop $reverse_loop
        ;; Check if start address is less than end address
        (br_if $reverse_done (i32.ge_u (local.get $startAddr) (local.get $endAddr)))

        ;; Swap the characters at $startAddr and $endAddr
        (local.set $tempDigit (i32.load8_u (local.get $startAddr)))
        (local.set $tempAddr (i32.load8_u (local.get $endAddr)))
        (i32.store8 (local.get $startAddr) (local.get $tempAddr))
        (i32.store8 (local.get $endAddr) (local.get $tempDigit))

        ;; Move $startAddr forward and $endAddr backward
        (local.set $startAddr (i32.add (local.get $startAddr) (i32.const 1)))
        (local.set $endAddr (i32.sub (local.get $endAddr) (i32.const 1)))

        (br $reverse_loop)
      )
    )

    ;; Null-terminate the string
    (i32.store8 (local.get $memAddr) (i32.const 0))

    ;; Return the last memory address of the string (before the null terminator)
    (local.get $memAddr)
  )

  (start $main)
)
