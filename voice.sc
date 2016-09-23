
s.waitForBoot {
    var fftsize = 4096*4;
    var buf = { Buffer.alloc(s, fftsize) }.dup;
    var hop = 1/2;
    var nfreqs = 16;
    ~freqs = Buffer.alloc(s,nfreqs);
    PyOnce("
        pv = PhaseVocoder(hop)
        
        def smushit(freqs,fb,b):
            a = freqs
            ass = fb            
            # repeat frequency measure for each input freq
            bs = np.transpose(np.broadcast_to(b,(a.shape[0],b.shape[0])))
            # we want to smush the frequencies to the closest freq
            v = (ass - bs)*closeness
            vs = np.abs(v)
            newb = b + v[np.arange(v.shape[0]),np.argmin(vs,axis=1)]
            return newb
        
        def fn(x,freqs):
            x = pv.forward(x)
            idx = indices(x.shape)[1]
            # repeat freqs so we can do matrix manipulations
            fb = np.broadcast_to(freqs,(fftsize/2,freqs.shape[0]))
            x = pv.shift(x, lambda y: smushit(freqs,fb,y[0]))
            x = pv.backward(x)
            return x
    ", (hop:hop,fftsize:fftsize));

    s.freeAll;
    ~synth = {
	    arg amp=0.0;
        var in = AudioIn.ar([1]);
        var x = FFT(buf.collect(_.bufnum), in, hop);
        Py("
            out(x, fn(array(x), array(freqs)))
        ", (x:x, closeness:MouseX.kr, freqs:~freqs));
        Out.ar(0, amp*(0.5+(1.5*MouseX.kr))*IFFT(x));
    }.play(s);


};


~amp = {
	|msg|
	"Setting amplitude".postln;
	msg.postln;
	~synth.set(\amp,msg[1]);	
};
OSCFunc.newMatching(~amp, '/amp');
~setteri = 0;
~setter = {
	|msg|
	msg.postln;
	msg[1..(msg.size)].do {
		|x|
		~freqs.set(~setteri % 16, x.midicps);
		~setteri = ~setteri + 1;
	};
};
OSCFunc.newMatching(~setter,'/setter');

~sayaddr = NetAddr.new("127.0.0.1", 5005);  
~say = { |str|
	str.postln;
	~sayaddr.sendMsg("/say",str);
};
~host = NetAddr.new("127.0.0.1", 10000);

~intro = {
	~say.("Welcome to Loudness Version 0.666.");
	~say.("This program is licensed under the GNU Public License Version 3.0.");
	~say.("Warning: this program may damage Public Address systems.");
};

~ender = {
	~say.("Computer aided search complete.");
	~r5 = Routine({
		30.do {|x|
			~host.sendMsg("/play3", 44-x,55-x,66-x,2000);
			1.0.wait;
		};
	}).play;
	~r6 = Routine({
		17.do {|x|
			~say.("Terminating.");
			2.0.wait;
		};
		~say.("Warning: this program may damage Public Address systems.");
		~say.("Thank you for your participation in Loudness version 0.666.");
	}).play;
};

OSCFunc.newMatching(~ender,'/end');
OSCFunc.newMatching(~intro,'/intro');
 
/*
~shost = NetAddr.new("127.0.0.1", 57120);
~shost.sendMsg("/amp", 1.0);
~shost.sendMsg("/amp", 0.0);
~shost.sendMsg("/setter",20,80,90,90,80,80,80);
~shost.sendMsg("/setter",160);
*/
(
   var v = 24.0.rand;
   ~synth.set(\amp,1.0);
   v.postln;
   16.do { |i|
    	~freqs.set(i,i*v);
   };
)


// Then
//s.scope;
//s.freqscope;

// Set some freqs
~freqs.set(0,440);
~freqs.set(1,380);
~freqs.set(2,240);
~freqs.set(3,60);
~freqs.set(4,1640);

// A fun set that shows up well on the freqscope so you
// can verify what is up
~freqs.set(0,121);
~freqs.set(1,923);
~freqs.set(2,6000);
~freqs.set(3,481);
~freqs.set(4,1750);

// You get tired and let the computer do it
(
var v = 24.0.rand;
   v.postln;
   16.do { |i|
    	~freqs.set(i,i*v);
   };
)
// Then you tell the computer to keep doing it
~r = Routine({
	while({true}, {
		//16.do { |i|
		var i = 16.rand;
		~freqs.set(i,i*440.0.rand);
		//};
		1.5.rand.wait;
	})
}).play;
//~r.stop;

~r = Routine({
	while({true}, {
		//16.do { |i|
		16.do { |i|
			~freqs.set(i,i*(1024.0.rand));
		};
		1.5.rand.wait;
	})}).play;
