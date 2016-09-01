SinOsc s => dac;
0.1 => float thegain;
thegain => s.gain;
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
    Std.mtof(i) => s.freq;
    thegain => s.gain;
    //thegain * 0.25 * response.freqResponse([s.freq()]) => s.gain;
    // print out RMS
    100::ms => now;
    //0 => s.gain;
    rms.upchuck() @=> UAnaBlob blob;
    blob.fval(0) => float frms;
    <<< s.freq(), s.gain(), frms>>>;
    33::ms => now;
    
}
<<< "done" >>>;
*/

33::ms => dur mindel;

Speak.Speak() @=> Speak speak;

function float min(float x, float y) {
    if (x > y) {
        return y;
    }
    return x;
}
function float max(float x, float y) {
    if (x > y) {
        return x;
    }
    return y;
}

speak.speak("Testing Frequency Response");
2::second => now;

for (0 => int i; i < 128; 1 +=> i) {
    Std.mtof(i) => s.freq;
    thegain => s.gain;
    thegain * min(10.0,3*response.freqResponse([s.freq()])) => s.gain;
    // print out RMS
    mindel => now;
    //((mindel::ms) * 2)  => now;
    //0 => s.gain;
    0.000 => float v;
    now => time start;
    while(now - start < mindel) {
        adc.last()*adc.last() + v => v;
        1::samp => now;
    }
    Math.sqrt(v) => v;    
    <<< s.freq(), s.gain(), v>>>;
}

