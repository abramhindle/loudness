
public class Response {
[
1584.89319246
,1584.89319246
,1584.89319246
,1584.89319246
,1584.89319246
,1584.89319246
,1584.89319246
,1584.89319246
,1584.89319246
,1584.89319246
,1584.89319246
,1490.85934059
,1291.94626772
,1081.20520803
,857.932832817
,621.383991292
,491.276711268
,471.099949412
,449.723414861
,427.07576542
,403.081416663
,377.660289681
,350.727543828
,322.193293566
,291.962308488
,259.933695492
,226.000562059
,190.049659512
,151.961005053
,111.607481341
,68.8544122399
,23.5591133571
,6.93217224511
,6.69451564432
,6.44272724666
,6.08436875193
,5.60798544322
,5.10327490888
,4.65973105157
,4.20972947493
,3.87686836963
,3.66472154053
,3.36579790286
,2.9644163884
,2.81235066615
,2.80261714412
,2.79230483674
,2.78137932766
,2.769804154
,2.75754068469
,2.74454799156
,2.73078271268
,2.71619890773
,2.70074790461
,2.68437813704
,2.66703497242
,2.64933540883
,2.63095733414
,2.61148644226
,2.59085775091
,2.56900241373
,2.54584749058
,2.52131570404
,2.54599024715
,2.60269385641
,2.66276923774
,2.72641688714
,2.79384922273
,2.79425387083
,2.75531978268
,2.71407055317
,2.67036851684
,2.6973822974
,2.74643617461
,2.79840694716
,2.7901541903
,2.74321892902
,2.69349275188
,2.69153480393
,2.69153480393
,2.69153480393
,2.69153480393
,2.63345893495
,2.53386353099
,2.49336005194
,2.46856847439
,2.44230271292
,2.41447510801
,2.38499278759
,2.35375735718
,2.32066457142
,2.28560398621
,2.24845859012
,2.20910441384
,2.16741011646
,2.12323654714
,2.06432723551
,1.998540033
,1.92884091985
,1.85499728177
,1.77676267247
,1.69387599121
,1.60606061141
,1.50536907399
,1.39630164655
,1.28074873238
,1.15832468437
,1.02862092365
,1.02269653613
,1.05306852185
,1.08524651982
,1.11933792112
,1.24886506904
,1.39402758242
,1.54782190803
,1.63748012175
,1.70960316071
,1.78695872624
,1.87779214989
,1.97402680998
,1.72133166693
,1.35476393693
,1.17960132703
,1.06802660441
,2.37791724415
,3.88698795217
,5.48579267409
,7.17966727205
] @=> float response[];

    function float freqResponse(float freqs[]) {
        1.0 => float r;
        for (0 => int i; i < freqs.cap(); 1 +=> i) {
            response[Std.ftom(freqs[0])$int] *=> r;
        }
        return r;
    }
}