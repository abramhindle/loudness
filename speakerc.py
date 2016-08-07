import liblo
import argparse

parser = argparse.ArgumentParser()

parser.add_argument("--ip",
                    default="127.0.0.1", help="The ip to listen on")
parser.add_argument("--port",
                    type=int, default=5005, help="The port to listen")
parser.add_argument('words', metavar='N', type=str, nargs='+',
                     help='words to say')
args = parser.parse_args()
target = liblo.Address(args.ip,args.port)
liblo.send(target, "/say", " ".join(args.words))
