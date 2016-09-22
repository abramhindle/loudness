s.boot;

~sayaddr = NetAddr.new("127.0.0.1", 5005);  
~say = { |str|
	str.postln;
	~sayaddr.sendMsg("/say",str);
};

~say.("Welcome to Loudness Version 0.666.");
~say.("This program is licensed under the GNU Public License Version 3.0.");
~say.("Warning: this program may damage Public Address systems.");


~keystroker = {
	arg name="Keystroker",paths=["/playrandom"];
	var host,window,response;
	host = NetAddr.new("127.0.0.1", 10000);
	window = Window.new(name);
	response = {
		arg view, char, modifiers, unicode, keycode;
		[char, keycode].postln;
		paths.do{|path| host.sendMsg(path, keycode, char.ascii) };
		// send osc messages of keycode I think
	};
	window.view.keyDownAction = response;
	window.view.keyUpAction = response;
	window.front;
	window
};
~keystroker.("Random",["/playrandom"]);
~keystroker.("Twiddle",["/playtwiddle"]);
~keystroker.("Genetic",["/playgenetic"]);
~keystroker.("All",["/playrandom","/playtwiddle","/playgenetic"]);

~host = NetAddr.new("127.0.0.1", 10000);

~r = Routine({
	125.do { |x|
		~host.sendMsg("/playrandom", x, 200.rand);
		0.3.rand.wait;
	}
}).play;

~r2 = Routine({
	125.do { |x|
		~host.sendMsg("/playtwiddle", 48.rand, 200.rand);
		0.3.rand.wait;
	}
}).play;

~r3 = Routine({
	125.do { |x|
		~host.sendMsg("/playgenetic", x, 1);
		0.3.rand.wait;
	}
}).play;

~r4 = Routine({
	100.do { |x|
		~host.sendMsg("/play3", 127.rand, 127.rand, 127.rand,400.rand);
		0.2.rand.wait;
	}
}).play;

~host.sendMsg("/play3", 15,120,103,100);
~host.sendMsg("/play3", 15,16,30,2000);
~host.sendMsg("/play3", 15,32,40,2000);
~host.sendMsg("/play3", 15.rand+10,32.rand+10,40.rand+10,2000.rand + 1000);
~host.sendMsg("/play3", 60.rand+10,70.rand+10,50.rand+10,2000.rand + 1000);


// Eval the next block to finish
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


x= {0.05*Mix.ar((SinOsc.ar([24.620925,78.210836,68.932222].midicps)))}.play;
y= {0.1*Mix.ar((SinOsc.ar([5.902575, 5.74428, 52.914931 ].midicps)))}.play;
z= {0.1*Mix.ar((SinOsc.ar([0.376505,59.874092,127.041578].midicps)))}.play;
g= {0.1*Mix.ar((SinOsc.ar([12.272065,35.467828,119.429157].midicps)))}.play;
e= {0.1*Mix.ar((SinOsc.ar([21.840251,107.563882,68.613739].midicps)))}.play;
d= {0.1*Mix.ar((SinOsc.ar([85.860501,98.159534,34.882455].midicps)))}.play;
