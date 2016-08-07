
"localhost" => string hostname;
5005 => int port;
OscSend speakxmit;
speakxmit.setHost( hostname, port );
function void say(string input) {
    speakxmit.startMsg("/say","s");
    input => string temp => speakxmit.addString;
    <<< "sent via OSC", temp >>>;
    //0.2::second => now;
}
while( true ) {
    say("Cool bears!");
    3.0 :: second => now;
}
