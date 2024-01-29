let audioContext;
let workletNode;
let wasmModule;
let currentIncrement = 16000000; // Default increment value


async function loadWasmModule() {
    const wasmArrayBuffer = await fetch('phase_accumulator.wasm').then(response => response.arrayBuffer());
    wasmModule = await WebAssembly.compile(wasmArrayBuffer);
}

async function createOrReuseWorkletNode() {
    if (!audioContext) {
        audioContext = new (window.AudioContext || window.webkitAudioContext)();
        await loadWasmModule();
        await audioContext.audioWorklet.addModule('phase-accumulator-processor.js');
    }

    if (!workletNode) {
        workletNode = new AudioWorkletNode(audioContext, 'phase-accumulator-processor', {
            processorOptions: {
                wasmModule: wasmModule,
                initialIncrement: currentIncrement  // Pass the current increment value
            }
        });
        workletNode.connect(audioContext.destination);
    }

    if (audioContext.state === 'suspended') {
        await audioContext.resume();
    }
}


document.getElementById('playButton').addEventListener('click', async () => {
    await createOrReuseWorkletNode();
});


document.getElementById('stopButton').addEventListener('click', () => {
    if (workletNode) {
        workletNode.disconnect();
        workletNode = null;  // Reset workletNode to allow recreation
    }

    if (audioContext) {
        audioContext.suspend();
    }
});

// Update the increment value without triggering playback
function updateIncrement(value) {
    currentIncrement = value;
}

document.getElementById('setIncrement16000000').addEventListener('click', () => {
    updateIncrement(16000000);
});

document.getElementById('setIncrement32000000').addEventListener('click', () => {
    updateIncrement(32000000);
});

document.getElementById('setIncrement48000000').addEventListener('click', () => {
    updateIncrement(48000000);
});