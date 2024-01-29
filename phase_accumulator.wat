(module
    ;; Declare a mutable global 32-bit integer for the phase accumulator
    (global $phaseAccumulator (mut i32) (i32.const 0))

    ;; Declare a mutable global 32-bit integer for the increment value
    (global $increment (mut i32) (i32.const 16000000))

    ;; Function to increment the phase and return the MSB
    (func $phaseAccumulatorOscillator (result i32)
        ;; Load the current value of the phase accumulator
        (global.get $phaseAccumulator)

        ;; Add the global increment to the phase accumulator
        (i32.add (global.get $increment))

        ;; Update the phase accumulator with the new value
        (global.set $phaseAccumulator)

        ;; Extract the most significant bit
        ;; Shift right by 31 bits and return
        (i32.shr_u (global.get $phaseAccumulator) (i32.const 31))
    )

    ;; Function to set the increment value
    (func $setIncrement (param $newIncrement i32)
        (global.set $increment (local.get $newIncrement))
    )

    ;; Export the oscillator and setIncrement functions so they can be called from outside
    (export "phaseAccumulatorOscillator" (func $phaseAccumulatorOscillator))
    (export "setIncrement" (func $setIncrement))
)
