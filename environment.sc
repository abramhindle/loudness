s.boot;
//~qfolder = "/home/hindle1/projects/loudness/supercollider";
//Quarks.addFolder(~qfolder);
//Quarks.gui

SynthDef(\env,
	{
		arg amp=1.0,low=0.5,mid=0.5,high=0.5,delay=0.01,in=0;
		var ulow, umid, uhigh, uin;
		uin = SoundIn.ar(in);
		ulow  = low*BPF.ar(uin,100,100.0/50.0);
		umid  = mid*BPF.ar(uin,400,400.0/200.0);
		uhigh = high*BPF.ar(uin,2000,0.5);
		Out.ar(in,
			HPF.ar(
				DelayC.ar(
					((0.333*amp)*(ulow + umid + uhigh))!2,
					maxdelaytime: 1.0,
					delaytime: delay),
				30.0,
			)
		);
	}
).add;
s.scope;
x = Synth(\env);
x.set(\low,0.0);
x.set(\mid,0.0);
x.autogui;

(
w = Window.new("I catch keystrokes");
w.view.keyDownAction = { arg view, char, modifiers, unicode, keycode;  [char, keycode].postln; };
w.front;
)

// then execute this and then press the 'j' key
(
w.front; // something safe to type on
{ SinOsc.ar(800, 0, KeyState.kr(38, 0, 0.1)) }.play;
)
w.view.keyDownAction = { arg view, char, modifiers, unicode, keycode;
	[char, modifiers, unicode, keycode].postln;
	// send OSC commands here to Chuck
};
