kill:
	killall chuck || echo "no chuck"
	killall sclang|| echo "no sclang"
	killall scsynth|| echo "no scsynth"
	killall speaker.py || echo "no speaker.py"
start:
	setsid gnome-terminal -e "python speaker.py"
	setsid gnome-terminal -e "perl oscrelay.pl daemon"
	python speakerc.py "Initiating"
	chuck --loop load.ck play3.ck commander.ck

rms:
	chuck  + rms.ck
