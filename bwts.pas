package uk.co.peopleandroid.aceb;

/* A bijective BWT (S) adapted from source
 * Mark Nelson
 * March 8, 1996
 * http://web2.airmail.net/markn
 * modifed by David A. Scott Dec of 2007
 * to make a fully bijective BWT
 * modifed by David A. Scott in August of 2000
 * to sort faster and drop EOF
 * modified by Simon P. Jackson, BEng. in June of 2010
 * to become a Java class to BWTS char[] type
 */

public class BWTS extends Sorter {

    private char[] bufs;
    private char[] buffer;
    private int[] xx;

    private void modBufs(int aS, int aE, boolean mod) {
       char ch = buffer[aE];
       int p1 = aE;
       for (int i = aE + 1; i-- > aS;) {
          if (buffer[i] != ch) {
             ch = buffer[i];
             p1 = i + 1;
          }
          if (mod && xx[i] == p1) {
             break;
          }
          xx[i] = p1;
       }
       xx[aE] = aS;
    }

    public void sort(int[] x) {
        //null function
    }

    public boolean lessThan(int i, int j) {
       return lessThan(i, j, false);//sorter thing!!
    }

    private boolean lessThan(int i, int j, boolean s) {
       int iold = i;
       int jold = j;
       short ic = 3;
       short jc = 3;
       if (buffer[i] != buffer[j])
          return buffer[i] < buffer[j];
       for (;;) {
          if (i < xx[i]) {
             if (j < xx[j]) {
                if ((xx[i] - i) < (xx[j] - j)) {
                   j += xx[i] - i;
                   i = xx[i];
                } else if ((xx[i] - i) > (xx[j] - j)) {
                   i += xx[j] - j;
                   j = xx[j];
                } else {
                   i = xx[i];
                   j = xx[j];
                }
             } else {

                if (jc != 0)
                   jc--;
                j = s? jold : xx[j];
                i++;
             }
          } else {
             if (j < xx[j]) {
                j++;
             } else {
                if (jc != 0)
                   jc--;
                j = s? jold : xx[j];
             }
             i = s? iold : xx[i];
             if (ic != 0)
                ic--;
          }
          if (buffer[i] != buffer[j])
             break;
          if ((ic + jc) == 0)
             break;
       }
       if (buffer[i] != buffer[j])
          return buffer[i] < buffer[j];
       return i < j;
    }

    private void part_cycle(int startS, int endS) {
       int Ns = endS;
       int Ts;
       modBufs(startS, endS, false);
       for (;;) {
          if (Ns == startS) {
             bufs[Ns] = buffer[Ns];
             xx[Ns] = Ns;
             return;
          }
          modBufs(startS, Ns, true);
          Ts = Ns;			// first guess
          for (int i = startS; i < Ns; i = xx[i]) {
             if (lessThan(Ts, i, true) != true)
                Ts = i;
          }
          modBufs(Ts, Ns, true);
          bufs[Ts] = buffer[Ns];
          if (Ts == startS)
             return;
          Ns = Ts - 1;
          bufs[startS] = buffer[Ns];
       }
    }

    public void sort(char[] in) {
        buffer = in;
        int i;
        int length = buffer.length;
        index = new int[length];
        for (i = 0; i < length; i++) {
            index[i] = i;
        }
        bufs = new char[length];
        for (i = 0; i < length - 1; i++) {
            bufs[i + 1] = buffer[i];
        }
        bufs[0] = buffer[length - 1];
        xx = new int[length];
        part_cycle(0, length - 1);
        super.sort(index);
        for (i = 0; i < length; i++) {
            buffer[i] = bufs[index[i]];
        }
    }

    private int[] T;
    private int[] count;

    public void unsort(char[] in) {
        buffer = in;
        int length = buffer.length;
        int i, j;
        count = new int[length];
        bufs = new char[length];
        for (i = 0; i < length; i++)
            count[i] = 0;
        for (i = 0; i < length; i++) {
            bufs[i] = '0';
            count[buffer[i]]++;
        }
        int sum = 0;
        xx = new int[length];
        for (i = 0; i < length; i++) {
            xx[i] = sum;
            sum += count[i];
            count[i] = 0;
        }
        T = new int[length];
        for (i = 0; i < length; i++) {
            j = buffer[i];
            T[count[j] + xx[j]] = i;
            count[j]++;
        }
        for (i = 0;;) {
            bufs[i] = '2';	/* 2 top of a cycle */
            for (j = 0; j < length; j++) {
               i = T[i];
               if (bufs[i] == '2')
                  break;
               bufs[i] = '3';
            }
            for (j = i; j < length; j++)
               if (bufs[j] == '0')
                  break;
            if (bufs[j] != '0' || j == length)
               break;
            i = j;
        }
        char[] out = new char[length];
        int k = 0;
        for (i = length - 1;; i--) {
            if (bufs[i] != '2')
               continue;
            for (j = T[i];;) {
               if (i == j)
                  break;
               out[k++] = buffer[j];
               j = T[j];
            }
            out[k++] = buffer[i];
            if (i == 0)
               break;
        }
        for(i = 0; i<length; i++)
            buffer[i] = out[i];
    }
}