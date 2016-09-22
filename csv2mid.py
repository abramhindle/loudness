import numpy as np
import numpy
import math 

def midi2freq(d):
    return math.pow(2.0,((d-69)/12.0))*440

def freq2midi(f):
    return 69+(12*math.log(f/440.0))/(math.log(2))

def db_to_amp(db):
    return math.pow(10,(db/20.0))

def amp_to_db(amp):
    return 20*math.log10(amp/1.0)

def testMidi():
    assert(np.isclose(midi2freq(69),440.0))
    assert(np.isclose(midi2freq(21),27.5))
    assert(np.isclose(midi2freq(108),4186.0))
    for i in range(0,127):
        assert (np.isclose(freq2midi(midi2freq(i)),float(i))) , "Midi %s" % i
    assert np.isclose(db_to_amp(0),1.0)
    assert np.isclose(db_to_amp(-80),0.0001)
    for i in range(-90,0):
        assert (np.isclose(amp_to_db(db_to_amp(i)),float(i))) , "DB %s" % i

testMidi()

microphone = np.loadtxt("behringer-xm8500.csv",delimiter=",")
mindb = np.min(microphone[0:,1])
maxdb = np.max(microphone[0:,1])
#20*math.log10(0.000031621/1.0) == -90.00048799635282
#math.log10(0.000031621/1.0) == -90.00048799635282/20
#math.log10(x/1.0) == -90.00048799635282/20
#x == 10^(-90/20)
micamp = np.copy(microphone)
micamp[:,1]  = np.apply_along_axis(np.vectorize(db_to_amp),0,microphone[0:,1])
micamp[:,1]  /= np.max(micamp[:,1])
# invert
micamp[:,1] = 1.0/micamp[:,1]
 
midifreq = np.apply_along_axis(np.vectorize(midi2freq),0,np.arange(128))
interpolated = numpy.interp(midifreq,micamp[:,0],micamp[:,1])
first = ""
for i in range(0,128):
    print "%s%s" % (first,interpolated[i])
    first = ","
