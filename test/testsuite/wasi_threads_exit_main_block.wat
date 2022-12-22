(module
  (func $thread_spawn (import "wasi" "thread_spawn") (param i32) (result i32))
  (func $proc_exit (import "wasi_snapshot_preview1" "proc_exit") (param i32))
  (func (export "wasi_thread_start") (param i32 i32)
    ;; infinite wait
    i32.const 0
    i32.const 0
    i64.const -1
    memory.atomic.wait32
    unreachable
  )
  (func (export "_start")
    ;; spawn a thread
    i32.const 0
    call $thread_spawn
    ;; check error
    i32.const 0
    i32.le_s
    if
      unreachable
    end
    ;; wait 500ms to ensure the other thread block
    i32.const 0
    i32.const 0
    i64.const 500_000_000
    memory.atomic.wait32
    ;; assert a timeout
    i32.const 2
    i32.ne
    if
      unreachable
    end
    ;; exit
    i32.const 99
    call $proc_exit
    unreachable
  )
  (memory 1 1 shared)
)
