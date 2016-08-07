Machine.add("speak.ck");
Speak.Speak() @=> Speak speak;

int indices[128];
float maxes[128];

function void reverse(int arr[]) {
    arr.cap() / 2 => int mid;
    arr.cap() => int s;
    int tmp;
    for (0 => int i; i < mid; i + 1 => i) {
        arr[i] => tmp;
        arr[s - 1 - i] => arr[i];
        tmp => arr[s - 1 - i];        
    }
}

function float f(int i) {
    return maxes[i];
}

function void quicksort(int arr[], int lo, int hi) {
    if (lo < hi) {
        partition(arr,lo,hi) => int p;
        quicksort(arr, lo, p - 1);
        quicksort(arr, p + 1, hi);
    }
}

function int partition(int arr[], int lo, int hi) {
    int tmp;
    f(arr[hi]) => float pivot;
    lo => int i;
    for ( lo => int j; j <= hi - 1 ; j + 1 => j) {
        if (f(arr[j]) <= pivot) {
            arr[i] => tmp;
            arr[j] => arr[i];
            tmp => arr[j];
            i + 1 => i;
        }
    }
    arr[i] => tmp;
    arr[hi] => arr[i];
    tmp => arr[hi];
    return i;
}

function void shuffle(int arr[], int size) {
    for (0 => int i; i < size -2; i + 1 => i) {
        Math.random2(i,size-1) => int j;
        arr[i] => int tmp;
        arr[j] => arr[i];
        tmp => arr[j];
    }
}

// function testit() {
//     for (0 => int i; i < 128; i + 1 => i) {
//         i => indices[i];
//         Math.random2f(0.0,1.0) => maxes[i];
//     }
//     quicksort(indices
// }

for (0 => int i; i < 128; i + 1 => i) {
    i => indices[i];
    0.0 => maxes[i];
}





<<< "ordered" >>>;
//shuffle(indices,128);
<<< "shuffled" >>>;
16 => int minmid;
127 => int maxmid;

// need this long to hear 20 hz :(
// 50ms
66.0::ms => dur mindel;

adc => Gain g => blackhole;
SinOsc s => ADSR e => dac;
e.set( mindel/10, mindel/10, 1.0, mindel/5 );

20 => s.freq;
1.0 => s.gain;

speak.speak("Testing frequency response");
3::second => now;

for (0 => int i; i < 128; i + 1 => i) {
    indices[i] => int j;
    if (j >= minmid && j <= maxmid) {
        1.0 => s.gain;
        0.0 => s.phase;
        e.keyOn();
        Std.mtof(j) => s.freq;
        4*mindel/5  => now;
        e.keyOff(); 
        mindel/5 => now;
        0.0 => s.gain;
        now => time start;
        while(now - start < mindel) {
            adc.last() => float v;
            if (v > maxes[j]) {
                v => maxes[j];
            }
            1::samp => now;
        }
        // mindel * ms => now;
    }
}
// 0.05 at 32, 0.11 @ 64 and 0.5 @ 96
<<< maxes[32], maxes[64], maxes[96] >>>;
quicksort(indices,0,127);
for (127 => int i; i > 127 - 10; i - 1 => i) {
    <<< (i - 127), indices[i], maxes[indices[i]] >>>;
}
//for (0 => int i; i < 128; i + 1 => i) {
//    <<< i, indices[i], maxes[i], maxes[indices[i]] >>>;
//}

///*
//Sub-bass 	20 to 60 Hz         16 to 34  - 18 \    \
//Bass 	60 to 250 Hz            35 to 58  - 23 /=41  \41
//Low midrange 	250 to 500 Hz   59 to 70  - 11 \     \
//Midrange 	500 Hz to 2 kHz     71 to 94  - 23  +=>47 \ 34
//Upper midrange 	2 to 4 kHz      95 to 108 - 13 /   \
//Presence 	4 to 6 kHz          108 to 113 - 5 \    \
//Brilliance 	6 to 20 kHz         114 to 127 - 13 \18  \31
//*/
int basses[42]; // 16 to 58
int mids[35]; // 59 to 94
int highs[32]; //95 to 127
int i;
<<< "new array inits" >>>;
for (0 => i; i < 42; i + 1 => i) {
    16 + i => basses[i];
}
for (0 => i; i < 35; i + 1 => i) {
    59 + i => mids[i];
}
for (0 => i; i < 32; i + 1 => i) {
    95 + i => highs[i];
}
<<< "q sort basses" >>>;
quicksort(basses,0,41);
<<< "q sort mids" >>>;
quicksort(mids,0,34);
quicksort(highs,0,31);
reverse(basses);
reverse(mids);
reverse(highs);
for (0 => int i; i < 5; i + 1 => i) {
    <<< "b", i, basses[i], maxes[basses[i]]  >>>;
    <<< "m", i, mids[i], maxes[mids[i]]  >>>;
    <<< "h", i, highs[i], maxes[highs[i]]  >>>;
}

SinOsc s2 => e;
SinOsc s3 => e;

[
[0,0,-1],
[0,1,-1],
[1,0,-1],
[0,-1,1],
[-1,0,1],
[0,0,0]
] @=> int combos[][];

float cmaxes[combos.cap()];
for (0 => int j; j < 5; j + 1 => j) {
    for (0 => int x; x < combos.cap(); x + 1 => x) {
        combos[x] @=> int combo[];
        if (combo[0] >= 0) {
            1.0 => s.gain;
            0.0 => s.phase;
            Std.mtof(basses[combo[0]]) => s.freq;
        }
        if (combo[1] >= 0) {
            1.0 => s2.gain;
            0.0 => s2.phase;
            Std.mtof(mids[combo[1]]) => s2.freq;
        }
        if (combo[2] >= 0) {
            1.0 => s3.gain;
            0.0 => s3.phase;
            Std.mtof(highs[combo[2]]) => s3.freq;
        }
        e.keyOn();
        3*4*mindel/5  => now;
        e.keyOff(); 
        mindel/5 => now;
        0.0 => s.gain;
        0.0 => s2.gain;
        0.0 => s3.gain;
        now => time start;
        while(now - start < mindel) {
            adc.last() => float v;
            if (v > cmaxes[x]) {
                v => cmaxes[x];
            }
            1::samp => now;
        }
        // mindel * ms => now;
    }
    
    for (0 => int i; i < cmaxes.cap(); i + 1 => i) {
        <<< i, cmaxes[i], combos[i][0], combos[i][1], combos[i][2] >>>;
    }
}
// twiddle

function float A(int arr[]) {
    adc => Gain g => blackhole;
    SinOsc s => ADSR e => dac;
    e.set( mindel/10, mindel/10, 1.0, mindel/5 );
    SinOsc s2 => e;
    SinOsc s3 => e;
    1.0 => float cmax;
    if (combo[0] >= 0) {
        1.0 => s.gain;
        0.0 => s.phase;
        Std.mtof(basses[combo[0]]) => s.freq;
    }
    if (combo[1] >= 0) {
        1.0 => s2.gain;
        0.0 => s2.phase;
        Std.mtof(mids[combo[1]]) => s2.freq;
    }
    if (combo[2] >= 0) {
        1.0 => s3.gain;
        0.0 => s3.phase;
        Std.mtof(highs[combo[2]]) => s3.freq;
    }
    e.keyOn();
    3*4*mindel/5  => now;
    e.keyOff(); 
    mindel/5 => now;
    0.0 => s.gain;
    0.0 => s2.gain;
    0.0 => s3.gain;
    now => time start;
    while(now - start < mindel) {
        adc.last() => float v;
        if (v > cmax) {
            v => cmax;
        }
        1::samp => now;
    }
    return 1.0/cmax;
}
function float floatsum(float arr[]) {
    0.0 => float sum;
    for (0 => int i; i < arr.cap(); i + 1 => i) {
        sum + arr[i] => sum;
    }
    return sum;
}

[Math.random2f(0,127),Math.random2f(0,127),Math.random2f(0,127)] => float p[];
[1.0,1.0,1.0] => float p[];
A(p) => float best_err;
0.001 => float threshold;
while( sum(dp) > threshold ) {
    float err;
    for (0 => int i; i < p.cap(); i + 1 => i) {
        p[i] + dp[i] => p[i]
        A(p) => err;
        if (err < best_err) {
            err => best_Err;
            dp[i] * 1.05 => dp[i]
        } else {
            p[i] - 2 * dp[i] => p[i];
            A(p) => err;
            if (err < best_err) {
                err => best_err
                dp[i] * 1.05 => dp[i]
            } else {
                p[i] + dp[i] => p[i];
                dp[i] * 0.95 => dp[i];
            }
        }
    }
}
<<< p >>>;
<<< p[0], p[1], p[2] >>>;
