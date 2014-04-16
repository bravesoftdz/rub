package uk.co.peopleandroid.aceb;

public class Sorter {

    public boolean lessThan(int i, int j) {
        return index[i]<index[j];
    }

    protected int[] index; //the index pointer

    public void sort(int[] array) {
        index = array;
        qsort(0, index.length);
    }

    private void qsort(int left, int right) {
        if(right > left) {
             int pivotIndex = left+(right-left)/2;
             int pivotNewIndex = partition(left, right, pivotIndex);
             qsort(left, pivotNewIndex - 1);
             qsort(pivotNewIndex + 1, right);
        }
    }

    private int partition(int left, int right, int pivotIndex) {
         swap(pivotIndex, right);
         int storeIndex = left;
         for(int i = left;i < right;i++) {
             if(lessThan(i, pivotIndex)) {
                 swap(i, storeIndex);
                 storeIndex++;
             }
         }
         swap(storeIndex, right);
         return storeIndex;
    }

    private void swap(int i, int j) {
        int t = index[i];
        index[i] = index[j];
        index[j] = t;
    }
}
