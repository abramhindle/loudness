
16 => int minmid;
96 => int maxmid;

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

3 => int attrs;
float p[attrs];
8 => int maxkeep;
float bestps[maxkeep][attrs];
float bestpserr[maxkeep];
0 => int keeps;
function void addps(float error, float arr[]) {
    if (keeps < maxkeep) {
        error => bestpserr[keeps];
        for (0 => int i ; i < attrs; 1 +=> i) {
            arr[i] => bestps[keeps][i];
        }
        1 +=> keeps;
        return;
    } else {
        bestpserr[0] => float maxf;
        0 => int maxdex;
        for (1 => int i ; i < maxkeep; 1 +=> i) {
            if ( bestpserr[i] > maxf) {
                bestpserr[i] => maxf;
                i => maxdex;
            }
        }
        if (maxf > error) {
            error => bestpserr[maxdex];
            for (0 => int i ; i < attrs; 1 +=> i) {
                arr[i] => bestps[maxdex][i];
            }
        }
    }
}


function float[][] randomsearch(float p[],int patience) {
    randomize_p(p);
    float bestp[p.cap()];
    A(p) => float best_err;
    copy(p,bestp);
    patience => int maxpatience;
    0.05 => float rate;
    float err;
    1000 => int iters;
    while(  iters > 0 && patience > 0) {
        <<< best_err, "[", bestp[0], bestp[1], bestp[2], "]" >>>;
        randomize_p(p);
        playA( bestp );
        A(p) => err;
        addps(err, p);
        if (err < best_err) {
            err => best_err;
            copy(p,bestp);
            maxpatience => patience;
        }
        1 -=> patience;
        1 -=> iters;
    }
    <<< p >>>;
    <<< p[0], p[1], p[2] >>>;
    A(p);
    /*
    for (0 => int i; i < 10; 1 +=> i) {
        A(bestp);
    } */
    for (0 => int i; i < keeps; 1 +=> i) {
        <<< i, bestpserr[i], bestps[i][0], bestps[i][1], bestps[i][2] >>>;
        playA(bestps[i]);
        playA(bestps[i]);
        playA(bestps[i]);
    }
    return bestps;
}
randomsearch(p,60);
<<< " now lets play a tune! " >>>;
for (0 => int i ; i < 1000; 1 +=> i) {
    Math.random2(0,bestps.cap()-1) => int j;
    <<<"Playing", i, bestps[i][0], bestps[i][1], bestps[i][2] >>>;
    playA(bestps[j]);
}
