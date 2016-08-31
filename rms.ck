Machine.add("speak.ck");

Response response;
adc => Gain g => blackhole;

/* 
adc => FFT fft =^ RMS rms => blackhole;

// set parameters
256 => int fftsize;
fftsize => fft.size;
// set hann window
Windowing.hann(fftsize) => fft.window;

for (0 => int i; i < 128; 1 +=> i) {
    rms.upchuck() @=> UAnaBlob blob;
    blob.fval(0) => float frms;
    <<< s.freq(), s.gain(), frms>>>;
    33::ms => now;    
}
