public class Best {
    int attrs;
    float p[];
    int maxkeep;
    float bestps[][];
    float bestpserr[];
    int keeps;
    fun static Best Best(int maxkeep, int attrs) {
        Best best;
        attrs => best.attrs;
        float p[attrs];
        p @=> best.p;
        maxkeep => best.maxkeep;
        float bestps[maxkeep][attrs];
        bestps @=> best.bestps;
        float errors[maxkeep];
        errors @=> best.bestpserr;
        return best;
    }
    function float[][] bests() {
        return bestps;
    }
    function float[] choose() {
        return bestps[Math.random2(0,keeps-1)];
    }
    function void add(float error, float arr[]) {
        if (keeps < maxkeep) {
            error => bestpserr[keeps];
            for (0 => int i ; i < attrs; 1 +=> i) {
                arr[i] => bestps[keeps][i];
            }
            1 +=> keeps;
            return;
        } else {
            bestpserr[0] => float maxf;
            0 => int maxdex;
            for (1 => int i ; i < maxkeep; 1 +=> i) {
                if ( bestpserr[i] > maxf) {
                    bestpserr[i] => maxf;
                    i => maxdex;
                }
            }
            if (maxf > error) {
                error => bestpserr[maxdex];
                for (0 => int i ; i < attrs; 1 +=> i) {
                    arr[i] => bestps[maxdex][i];
                }
            }
        }
    }
}
