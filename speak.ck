/*
  Speak class
*/


public class Speak 
{
    string hostname;
    int port;
    OscSend speakxmit;
    fun static Speak Speak() {
        return Speak("localhost",5005);
    }
    fun static Speak Speak(string host, int sendPort) {
        Speak speak;
        host => speak.hostname;
        sendPort => speak.port;
        speak.speakxmit.setHost( host, sendPort  );
        return speak;
    }
    fun void speak(string input) {
        speakxmit.startMsg("/say","s");
        input => string temp => speakxmit.addString;
        <<< "sent via OSC", temp >>>;        
    }
}
