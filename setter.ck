
/*
  setter class
*/


public class Setter
{
    string hostname;
    int port;
    OscSend setterxmit;
    fun static Setter Setter() {
        return Setter("localhost",57120);
    }
    fun static Setter Setter(string host, int sendPort) {
        Setter setter;
        host => setter.hostname;
        sendPort => setter.port;
        setter.setterxmit.setHost( host, sendPort  );
        return setter;
    }
    fun void setter(float a, float b, float c) {
        setterxmit.startMsg("/setter","fff");
        a => setterxmit.addFloat;
        b => setterxmit.addFloat;
        c => setterxmit.addFloat;
        <<< "sent via OSC", (a,b,c) >>>;        
    }

}
