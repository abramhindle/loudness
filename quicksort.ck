/*
    
    Quicksort implementation in chuck.
    Copyright (C) 2016 Abram Hindle, Ge Wang
    
    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.
    
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
    
    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
    
*/

// fill arr with values 0 to size-1
function void fillrange(int arr[], int size) {
    for (0 => int i; i < size; 1 +=> i) {
        i => arr[i];
    }
}

// reverse the order of elements in arr
function void reverse(int arr[]) {
    arr.cap() / 2 => int mid;
    arr.cap() => int s;
    int tmp;
    for (0 => int i; i < mid; i + 1 => i) {
        arr[i] => tmp;
        arr[s - 1 - i] => arr[i];
        tmp => arr[s - 1 - i];        
    }
}

// quicksort, call with your arr of indices and float values
// quicksort(indices, values, 0, values.cap() - 1) sorts indices
function void quicksort(int arr[], float values[], int lo, int hi) {
    if (lo < hi) {
        partition(arr, values, lo,hi) => int p;
        quicksort(arr, values, lo, p - 1);
        quicksort(arr, values, p + 1, hi);
    }
}

function int partition(int arr[], float values[], int lo, int hi) {
    int tmp;
    values[arr[hi]] => float pivot;
    lo => int i;
    for ( lo => int j; j <= hi - 1 ; j + 1 => j) {
        if (values[arr[j]] <= pivot) {
            arr[i] => tmp;
            arr[j] => arr[i];
            tmp => arr[j];
            i + 1 => i;
        }
    }
    arr[i] => tmp;
    arr[hi] => arr[i];
    tmp => arr[hi];
    return i;
}

// fisher-yates shuffle
function void shuffle(int arr[], int size) {
    for (0 => int i; i < size -2; i + 1 => i) {
        Math.random2(i,size-1) => int j;
        arr[i] => int tmp;
        arr[j] => arr[i];
        tmp => arr[j];
    }
}

