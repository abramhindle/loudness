/* optional */
Machine.add("speak.ck");

Speak.Speak() @=> Speak speak;
//speak.speak("Bird up!");
//speak.speak("The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.");

function float micdelay() {
    adc => Gain g => blackhole;
    SinOsc s => dac;
    0 => float maxsamp;
    now => time when;
    0.25 => s.gain;
    Math.random2f(2000,8440) => s.freq;
    now => time started;
    while(now - started < 0.1::second) {
        // envelope
        0.25 * (1.0 - ((now - started)/(0.1::second))) => s.gain;
        if (adc.last() > maxsamp) {
            adc.last() => maxsamp;
            now => when;
        }
        1::samp => now;
    }
    <<< maxsamp, (when - started)/ms >>>;
    return (when - started)/ms;
}
speak.speak("Testing sound-card and microphone latency");
3.5::second => now;
0 => float times;
for (0 => int i; i < 10; i + 1 => i) {
    micdelay() + times => times;
    0.1::second => now;
}
speak.speak("Microphone delay of " + (times/10)$int + " milliseconds");
4::second => now;
<<< times/10 >>>;

times/10 => float mindelay;

