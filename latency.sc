s.boot;


SynthDef(\playTone, { |freq, duration|
    var w = SinOsc.ar(freq) * XLine.ar(1001,1,duration,add: -1,doneAction:2) / 1000;
    Out.ar(0,w!2);
}).add;



SynthDef(\recordTone, { |buffer|
    RecordBuf.ar(SoundIn.ar(0,1), buffer, loop: 0, doneAction: 2);
}).add;

b = Buffer.alloc(s, s.sampleRate * 3.0, 1);

~sayaddr = NetAddr.new("127.0.0.1", 5005);  
~say = { |str|
	str.postln;
	~sayaddr.sendMsg("/say",str);
};

Routine({
	var delays;
	~say.("Testing sound-card and microphone latency");
	3.0.wait;
	delays = 10.collect {
		var indices, barr;
		0.01.wait;
		s.makeBundle(func: {
			var toner = Synth(\playTone,[\freq,10000,\duration,0.1]);
			var recorder = Synth.after(toner,\recordTone,[\buffer,b]);
		});
		0.3.wait;
		x.stop;
		b.loadToFloatArray(action:{arg arr;barr=arr; {arr[(0..10000)]}.defer;});
		indices = (0..(10000));
		indices.sort({arg a,b; barr.[a] > barr.[b]});
		indices.[(0..4)].postln;
		indices[0];
	};
	~delayms = 1000*(delays.mean)/s.sampleRate;
	~delaysamp = (delays.mean);		
	~say.("Mean Delay of " + (~delayms.round) + " milliseconds.");
	3.wait;
}).play;
