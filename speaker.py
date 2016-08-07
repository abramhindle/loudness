import talkey
import argparse
from liblo import *
import threading

tts = None

class MyOscServer(Server):
    def __init__(self,port=1234):
        Server.__init__(self, port)

    @make_method('/say', 's')
    def foo_callback(self, path, args):
        s = args[0]
        print "received message '%s' with arguments: %s" % (path, s)
        tts.say(s)


def print_say_handler(unused_addr, args, text):
  print("[{0}] ~ {1}".format(args[0], text))
  tts.say(text)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--ip",
                        default="127.0.0.1", help="The ip to listen on")
    parser.add_argument("--port",
                        type=int, default=5005, help="The port to listen on")
    args = parser.parse_args()
    
    tts = talkey.Talkey()
    
    try:
        server = MyOscServer(port=args.port)
    except ServerError, err:
        print str(err)
        sys.exit()
    while True:
        server.recv(33)
