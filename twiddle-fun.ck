
48 => int minmid;
94 => int maxmid;

// need this long to hear 20 hz :(
// 50ms
75.0::ms => dur mindel;
50::ms => dur listendel;
// twiddle

adc => Gain g => blackhole;
SqrOsc s => ADSR e => dac;
e.set( mindel/10, mindel/10, 1.0, mindel/5 );
SinOsc s2 => e;
TriOsc  s3 => e;


function float A(float arr[]) {
    1.0 => float cmax;
    0.001 => float v;
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
    Math.random2(3,5)*mindel/5  => now;
    e.keyOff(); 
    mindel/5 => now;
    0.0 => s.gain;
    0.0 => s2.gain;
    0.0 => s3.gain;
    now => time start;
    while(now - start < listendel) {
        adc.last()*adc.last() + v => v;
        //if (v > cmax) {
        //    v => cmax;
        //}
        1::samp => now;
    }
    0.0 => float penalty;
    for (0 => int i; i < arr.cap() ; 1 +=> i) {
        if (arr[i] > maxmid || arr[i] < minmid) {
             1000.0 +=> penalty;
         }
     }
    // if (arr[0]$int == arr[1]$int) {
    //     12.0 +=> penalty;
    // }
    // if (arr[0]$int == arr[2]$int) {
    //     12.0 +=> penalty;
    // }
    // if (arr[1]$int == arr[2]$int) {
    //     12.0 +=> penalty;
    // }
    // if (arr[2]$int < 58) {
    //     12.0 +=> penalty;
    // }
    // if (arr[1]$int > arr[2]$int) {
    //     12.0 +=> penalty;
    // }
    // if (arr[0]$int > 95) {
    //     12.0 +=> penalty;
    // }
    30.0/(0.0001+Math.fabs(arr[0] - arr[1])) +=> penalty;
    30.0/(0.0001+Math.fabs(arr[1] - arr[2])) +=> penalty;
    30.0/(0.0001+Math.fabs(arr[0] - arr[2])) +=> penalty;

    -1.0*v + penalty => float score;
    //-1.0*v => float score;

    <<< "a", arr[0], arr[1], arr[2], score >>>;

    return score;
}


function float floatsum(float arr[]) {
    0.0 => float sum;
    for (0 => int i; i < arr.cap(); i + 1 => i) {
        sum + arr[i] => sum;
    }
    return sum;
}

function void copy(float from[], float to[]) {
    for (0 => int i; i < from.cap(); i + 1 => i) {
        from[i] + 0.0 => to[i];
    }
}

[Math.random2f(minmid,maxmid),Math.random2f(minmid,maxmid),Math.random2f(minmid,maxmid)] @=> float p[];
float bestp[p.cap()];
[32.0,32.0,32.0] @=> float dp[];
A(p) => float best_err;
copy(p,bestp);
10.0 => float threshold;
0.05 => float rate;
// why aren't we keeping the best
float err;
while( floatsum(dp) > threshold ) {
    <<< "dp", dp[0], dp[1], dp[2], floatsum(dp), best_err >>>;    
    for (0 => int i; i < p.cap(); i + 1 => i) {
        p[i] + dp[i] => p[i];
        A(p) => err;
        if (err < best_err) {
            err => best_err;
            copy(p,bestp);
            dp[i] * (1.0 + 2.0*rate) => dp[i];
        } else {
            p[i] - 2 * dp[i] => p[i];
            A(p) => err;
            if (err < best_err) {
                err => best_err;              
                copy(p,bestp);
                dp[i] * (1.0 + rate) => dp[i];
            } else {
                p[i] + dp[i] => p[i];
                dp[i] * (1.0 - rate) => dp[i];
            }
        }
    }
}
<<< p >>>;
<<< p[0], p[1], p[2] >>>;
for ( 0 => int i; i < 20; 1 +=> i) {
    A(p);
    A(bestp);
}
