16 => int minmid;
128 => int maxmid;

Response response;

Speak.Speak() @=> Speak speak;

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

Best.Best(8,3) @=> Best best;


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
        if (iters % 25 == 0) {
            speak.speakDelay("Current best midi notes: " + (bestp[0] $ int) + " " + (bestp[1] $ int) + " " + (bestp[2] $ int+"."),4::second);
        }
        <<< best_err, "[", bestp[0], bestp[1], bestp[2], "]" >>>;
        randomize_p(p);
        playA( bestp );
        A(p) => err;
        best.add(err, p);
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
    speak.speakDelay("Loudest Frequencies Founnd",3::second);
    for (0 => int i; i < best.keeps; 1 +=> i) {
        best.bests()[i] @=> float bestps[];
        <<< i, bestps[0], bestps[1], bestps[2] >>>;
        playA(bestps);
        playA(bestps);
        playA(bestps);
    }
    return best.bests();
}
speak.speakDelay("Warning this problem is not convex.",3::second);
speak.speakDelay("Initiating Random Search",3::second);
float p[best.attrs];
randomsearch(p,50) @=> float bestps[][];
<<< " now lets play a tune! " >>>;

OscRecv orec;
10000 => orec.port;
orec.listen();
orec.event("/playrandom, i, i") @=> OscEvent play3Event;

speak.speak("Waiting for user input on port 10000 using open sound control protocol");

function void OSCrand() {
     while ( true ) {
        <<< "waiting" >>>;
        play3Event => now; //wait for events to arrive.
        while( play3Event.nextMsg() != 0 ) {
            play3Event.getInt() => int i;
            play3Event.getInt() => int shifti;
            <<< i >>>; 
            Math.random2(1,4) => int mj;
            Math.random2(10,400)::ms => mindel;

            bestps[i % bestps.cap()] @=> float curr[];
            <<< curr[0], curr[1], curr[2] >>>;
            for ( 0 => int j ; j < mj; 1 +=> j) {
                if (shifti < 97) {
                    5000::ms => mindel;
                }
                spork ~ playA(curr);
            }
        }
    }
}


OSCrand();


//for (0 => int i ; i < 1000; 1 +=> i) {
//    Math.random2(0,bestps.cap()-1) => int j;
//    <<<"Playing", i, bestps[j][0], bestps[j][1], bestps[j][2] >>>;
//    playA(bestps[j]);
//    //Math.random2f(0.1,1.1) * mindel => now;
//}
//
