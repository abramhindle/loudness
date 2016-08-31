//Machine.add("speak.ck");

Speak.Speak() @=> Speak speak;

//Response response;
adc => Gain g => blackhole;

adc => FFT fft =^ RMS rms => blackhole;

// set parameters
256 => int fftsize;
fftsize => fft.size;
// set hann window
Windowing.hann(fftsize) => fft.window;

0.0 => float frms;
1 => int dospeak;
function void RMSSpeaker() {
    while(1 > 0) {
        if (dospeak > 0) {
            <<< frms >>>;
            speak.speak("R M S measured "+(frms $ int));
            <<< "what" >>>;
        }
        5001::ms => now;
    }
}

spork ~ RMSSpeaker();

while( true) {
    rms.upchuck() @=> UAnaBlob blob;
    blob.fval(0) => float frms;
    33::ms => now;    
}
