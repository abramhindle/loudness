57::ms => dur mindel;
function void playA(float arr[],int millis) {
    SinOsc s => ADSR e => dac;
    e.set( mindel/10, mindel/10, 1.0, mindel/5 );
    SinOsc s2 => e;
    SinOsc s3 => e;
    millis * ms => dur mindel;
    1.0 => s.gain;
    0.0 => s.phase;
    Std.mtof(arr[0]) => s.freq;
    1.0 => s2.gain;
    0.0 => s2.phase;
    Std.mtof(arr[1]) => s2.freq;
    1.0 => s3.gain;
    0.0 => s3.phase;
    Std.mtof(arr[2]) => s3.freq;
    e.keyOn();
    4*mindel/5  => now;
    e.keyOff(); 
    mindel/5 => now;
}
OscRecv orec;
10000 => orec.port;
orec.listen();
orec.event("/play3, i, i, i, i") @=> OscEvent play3Event;
function void OSCrand() {
    float arr[3];
    while ( true ) {
        <<< "waiting" >>>;
        play3Event => now; //wait for events to arrive.
        while( play3Event.nextMsg() != 0 ) {
            play3Event.getInt() => arr[0];
            play3Event.getInt() => arr[1];
            play3Event.getInt() => arr[2];
            play3Event.getInt() => int d;
            spork ~ playA(arr,d);
        }
    }
}
OSCrand();
