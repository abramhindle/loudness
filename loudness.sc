// DONT RUN ME LIVE

s.boot;

~mic = CSVFileReader.read("behringer-xm8500.csv").postcs;
~mic = ~mic.collect({|x| x[0] = x[0].asFloat; x[1] = x[1].asFloat; x});
~levels = ~mic.collect {|x| 90 + x[1]   };
~times = ~mic.collect {|x| x[0] / 22000 };
~micenv = Env(~levels,~times, curve: 'cubed');
~micenv.plot;
(0..100).collect({|x| ~micenv.at(x/22000) }).plot;

(
{
    var input, numsamp, power;
    numsamp = 4000;
    input = SoundIn.ar;
    power = MouseX.kr(0.1, 16);
	Out.ar(0,[
		0.5*SinOsc.ar(MouseY.kr(20,200)),
		(RunningSum.ar(input.squared, numsamp) / numsamp).sqrt
	])
}.scope
)


(
~pitch = 0.0;
~rms = 0.0;
~maxhz = 1000;
~sum = Signal.newClear(~maxhz);
~count = Signal.newClear(~maxhz);


x = Bus.control(s, 1).set(0);
y = Bus.control(s, 1).set(0);
{
	var pitch = MouseY.kr(20,1000);
	Out.kr(x,pitch);
	Out.ar(0,0.5*SinOsc.ar(pitch));
}.scope;
{
	var numsamp = 1000, input;
	input = SoundIn.ar;
	Out.kr(y,(RunningSum.ar(input.squared, numsamp) / numsamp).sqrt);
}.play;

fork {
	loop {
		var in = 0, curr, rms;
		x.get({|val| ~pitch = val; });
		y.get({|val| ~rms = val; });
		0.2.wait;
		[~pitch,~rms].postln;
		in = ~pitch.asInteger;
		rms = ~rms;
		curr = ~sum.at(in);
		curr = curr + rms;
		~sum.put(in, curr);
		~count.put(in,~count.at(in) + 1);
	}
}
)
~loud.asList
// plot the average loudness for that frequency
(~sum/(1+~count)).plot();
~loud = ~sum/(1+~count);
~loud.plot();
~loud.size
[(0..(-1 + ~loud.size)),~loud.asList].lace(~loud.size)
~indices = (0..(-1 + ~loud.size));
~indices.sort({arg a,b; ~loud.at(a) > ~loud.at(b) })
{ 0.2 * (SinOsc.ar(~indices[0]) + SinOsc.ar(~indices[1]) + SinOsc.ar(~indices[2])) }.play;

}.play();


(
var maxi = 0;
for (0, (~maxhz-1), { arg i; var v = ~loud.at(i); if(v > ~loud.at(maxi),{maxi = i;});});
maxi.postln;
~maxi = maxi;
)
{ SinOsc.ar(~maxi) }.play();

(
SynthDef(\playTone, { |freq, duration|
    var w = SinOsc.ar(freq) * XLine.ar(1001,1,duration,add: -1,doneAction:2) / 1000;
    Out.ar(0,w!2);
}).add;
)
Synth(\playTone,[\freq,440,\duration,8]);

(
SynthDef(\recordTone, { |buffer|
    RecordBuf.ar(SoundIn.ar(0,1), buffer, loop: 0, doneAction: 2);
}).add;
)
b = Buffer.alloc(s, s.sampleRate * 3.0, 1);
s.makeBundle(func: {
	var recorder = Synth(\recordTone, [\buffer, b]);
	var player = Synth(\playTone, [\freq, 10000, \duration, 0.3]);
});


//b.plot(bounds:[0,-1,30,1])
b.loadToFloatArray(action:{arg arr;~barr=arr; {arr[(0..10000)].plot;}.defer;})
~indices = (0..(~barr.size-1));
~indices.sort({arg a,b; ~barr.[a] > ~barr.[b]});
~indices.[(0..4)];
//~barr.sort
SynthDef("help-In", { arg out=0, in=0;
    var input;
        input = SoundIn.ar(in, 1);
        Out.ar(out, input);

}).send(s);

Synth("help-In", [\out, 0, \in, 0]);
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

16.midicps
{SinOsc.ar(86.midicps)}.play;

{0.5*(SinOsc.ar(87.midicps) + SinOsc.ar(103.midicps))}.play;
{0.01*(SinOsc.ar([49,87,95].midicps))}.play;
{0.01*(SinOsc.ar([50,90,103].midicps))}.play;
{0.01*(SinOsc.ar([47,91,99].midicps))}.play;
{0.01*(SinOsc.ar([43,91,99].midicps))}.play;
{0.01*(SinOsc.ar([49,51,53].midicps))}.play;

x= {0.05*Mix.ar((SinOsc.ar([24.620925,78.210836,68.932222].midicps)))}.play;
y= {0.1*Mix.ar((SinOsc.ar([5.902575, 5.74428, 52.914931 ].midicps)))}.play;
z= {0.1*Mix.ar((SinOsc.ar([0.376505,59.874092,127.041578].midicps)))}.play;
g= {0.1*Mix.ar((SinOsc.ar([12.272065,35.467828,119.429157].midicps)))}.play;
e= {0.1*Mix.ar((SinOsc.ar([21.840251,107.563882,68.613739].midicps)))}.play;
d= {0.1*Mix.ar((SinOsc.ar([85.860501,98.159534,34.882455].midicps)))}.play;
g.stop;
e.stop;
x.stop;
y.stop;
z.stop;
s.scope;

20.cpsmidi
60.cpsmidi
250.cpsmidi
500.cpsmidi
2000.cpsmidi

108-95
127-114
70-59
58-35
34-16

18 + 23 + 11
18+23
5+13
41+47+18
13+5+13
11+23
18+23
58-16
~say.("Coool")
~cmdaddr = NetAddr.new("127.0.0.1", 10000);  
~cmd = { |str|
	str.postln;
	~cmdaddr.sendMsg(str);
};
~cmd.("/delaytest");
~cmd.("/genetic");
~cmd.("/twiddle");