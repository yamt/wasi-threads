;; When a non-main thread calls proc_exit, it should terminate
;; the main thread which is blocking in a WASI call. (poll_oneoff)

(module
  (memory (export "memory") (import "foo" "bar") 1 1 shared)
  (func $thread_spawn (import "wasi" "thread_spawn") (param i32) (result i32))
  (func $proc_exit (import "wasi_snapshot_preview1" "proc_exit") (param i32))
  (func $poll_oneoff (import "wasi_snapshot_preview1" "poll_oneoff") (param i32 i32 i32 i32) (result i32))
  (func (export "wasi_thread_start") (param i32 i32)
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
    ;; long enough block
    ;; clock_realtime, !abstime (zeros)
    i32.const 124 ;; 100 + offsetof(subscription, timeout)
    i64.const 1_000_000_000 ;; 1s
    i64.store
    i32.const 100 ;; subscription
    i32.const 200 ;; event (out)
    i32.const 1   ;; nsubscriptions
    i32.const 300 ;; retp (out)
    call $poll_oneoff
    unreachable
  )
)
