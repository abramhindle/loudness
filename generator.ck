
// need this long to hear 20 hz :(
// 50ms
66.0::ms => dur mindel;

adc => Gain g => blackhole;
SinOsc s => ADSR e => dac;
e.set( mindel/10, mindel/10, 1.0, mindel/5 );

20 => s.freq;
1.0 => s.gain;

for (0 => int i; i < 128; i + 1 => i) {
    Std.mtof(i) => s.freq;
    <<< s.freq() >>>;
    e.keyOn();
    4*mindel/5  => now;
    e.keyOff(); 
    mindel/5 => now;
}
