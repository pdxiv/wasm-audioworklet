class PhaseAccumulatorProcessor extends AudioWorkletProcessor {
    constructor(options) {
        super();
        this.wasmInitialized = false;
        this.frameCount = 0;
        this.totalSamples = sampleRate * 4;
        this.initialIncrement = options.processorOptions.initialIncrement || 16000000;
        this.port.onmessage = this.handleMessage.bind(this);
        this.initWasm(options.processorOptions.wasmModule).then(() => {
            // After WASM is initialized, set the initial increment value
            this.wasmInstance.exports.setIncrement(this.initialIncrement);
            this.wasmInitialized = true;
        });
    }

    handleMessage(event) {
        if (event.data.type === 'setIncrement') {
            this.wasmInstance.exports.setIncrement(event.data.value);
        }
    }

    async initWasm(wasmModule) {
        try {
            this.wasmInstance = await WebAssembly.instantiate(wasmModule);
        } catch (error) {
            console.error('Error initializing WASM:', error);
        }
    }


    process(inputs, outputs, parameters) {
        if (!this.wasmInitialized) {
            return true; // Keep the processor alive until WASM is initialized
        }

        const output = outputs[0];
        const channel = output[0];

        for (let i = 0; i < channel.length; i++) {
            if (this.frameCount < this.totalSamples) {
                // Call the WebAssembly function for each sample
                channel[i] = (this.wasmInstance.exports.phaseAccumulatorOscillator() * 2 - 1);
                this.frameCount++;
            } else {
                // Stop the processor after this.totalSamples exceeded
                this.frameCount = 0; // Reset frame count for next time
                return false;
            }
        }
        return true;
    }
}

registerProcessor('phase-accumulator-processor', PhaseAccumulatorProcessor);
