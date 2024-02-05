(module
  (import "wasi_snapshot_preview1" "fd_write" (func $fd_write (param i32 i32 i32 i32) (result i32)))
  (import "wasi_snapshot_preview1" "proc_exit" (func $proc_exit (param i32)))

  ;; Memory declaration
  (memory (export "memory") 1)

  ;; Data for "Hello, World!\n" and iovec struct
  (data (i32.const 0) "\08\00\00\00") ;; start of data buffer
  (data (i32.const 4) "\0e\00\00\00") ;; length of data buffer
  (data (i32.const 8) "Hello, World!\n\00") ;; message at 8

  (func $main
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

  (start $main)
)
