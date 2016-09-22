OscRecv orec;
10000 => orec.port;
orec.listen();

function void oneOff(string str, string program) {
    orec.event(str) @=> OscEvent play3Event;
    while ( true ) {
        <<< ("waiting for", str) >>>;
        play3Event => now; //wait for events to arrive.
        while( play3Event.nextMsg() != 0 ) {
            Machine.add(program);
        }
    }
}

function void delayTest() {
    orec.event("/delaytest") @=> OscEvent play3Event;
    while ( true ) {
        <<< "waiting" >>>;
        play3Event => now; //wait for events to arrive.
        while( play3Event.nextMsg() != 0 ) {
            Machine.add("delaytest.ck");
        }
    }
}

spork ~ oneOff("/randomsearch","randomsearch.ck");
spork ~ oneOff("/genetic","genetic.ck");
spork ~ oneOff("/twiddle","twiddle.ck");
delayTest();


