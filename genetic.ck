16 => int minmid;
128 => int maxmid;

Response response;


// need this long to hear 20 hz :(
// 50ms
57.0::ms => dur mindel;

// twiddle

adc => Gain g => blackhole;
SinOsc s => ADSR e => dac;
e.set( mindel/10, mindel/10, 1.0, mindel/5 );
SinOsc s2 => e;
SinOsc s3 => e;

function void playA(float arr[]) {
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

function float A(float arr[]) {
    1.0 => float cmax;
    0.001 => float v;
    playA(arr);
    0.0 => s.gain;
    0.0 => s2.gain;
    0.0 => s3.gain;
    now => time start;
    while(now - start < mindel) {
        adc.last()*adc.last() + v => v;
        //if (v > cmax) {
        //    v => cmax;
        //}
        1::samp => now;
    }
    Math.sqrt(v / (mindel / samp)) => v ;
    v * response.freqResponse(arr) => v; // see response.ck

    0.0 => float penalty;
    for (0 => int i; i < arr.cap() ; 1 +=> i) {
        if (arr[i] > 128 || arr[i] < 0) {
             100.0 +=> penalty;
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

function void randomize_p(float p[]) {
    for (0 => int i; i < p.cap(); 1 +=> i) {
        Math.random2f(minmid,maxmid) => p[i];
    }
}

8 => int nbest;

4 => int newmutants;

1 => int newrandoms;

Best.Best(nbest,3) @=> Best best;

float randoms[3];
randomize_p(randoms);
A(randoms) => float best_err;
best.add( best_err, randoms);    

function void mutate(float mutant[]) {
    for (0 => int i; i < mutant.cap(); 1 +=> i) {
        if (Math.random2(0,1) == 0) {
            // randomly set a value
            Math.random2(minmid,maxmid) => mutant[i];
        } else {
            // randomly mult a value
            Math.random2f(0.9,1.1) *=> mutant[i];
        }
    }
}


function void round(Best best) { 
    <<< "mutants" >>>;
    for (0 => int i; i <= newmutants; 1 +=> i) {
        float mutant[3];
        copy(best.choose(),mutant);
        mutate(mutant);
        A(mutant) => float best_err;
        best.add( best_err, mutant);
    }
    <<< "randoms" >>>;
    for (0 => int i; i <= newrandoms; 1 +=> i) {
        float randoms[3];
        randomize_p(randoms);
        A(randoms) => float best_err;
        best.add( best_err, randoms);    
    }
}
    
for ( 0 => int i; i < 100; 1 +=> i) {
    <<< i >>>;
    round(best);
    best.bests() @=> float bests[][];
    <<< "play best" >>>;
    for (0 => int j; j < bests.cap(); 1 +=> j) {
        playA(bests[j]);
    }
}
