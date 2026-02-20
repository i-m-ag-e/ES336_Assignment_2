// I have included this file as reference for the 3rd question
// The assembly is an exact conversion of this C file 
#include <stdio.h>

void swap(int* a, int* b) {
    int t = *b;
    *b = *a;
    *a = t;
}

int get_pivot(int* arr, int low, int high) {
    int mid = low + (high - low) / 2;
    int bigger = 0, smaller = 0;
    if (arr[low] < arr[mid]) {
        bigger = mid;
        smaller = low;
    } else {
        bigger = low;
        smaller = mid;
    }
    if (arr[bigger] < arr[high]) return bigger;
    else if (arr[smaller] < arr[high]) return high;
    else return smaller;
}

void quick_sort(int* arr, int low, int high) {
    if (low >= high)
        return;
    
    int pivot = get_pivot(arr, low, high);
    int pivot_elem = arr[pivot];
    swap(&arr[pivot], &arr[high]);

    int i = low;
    int j = high;
    while (i < j) {
        // find first bigger from the left
        while (arr[i] < pivot_elem && i <= high - 1) {
            ++i;
        }

        // find first lesser from right
        while (arr[j] >= pivot_elem && j >= low + 1) {
            j--;
        }

        if (i < j)
            swap(&arr[i], &arr[j]);
    }
    swap(&arr[high], &arr[i]);

    quick_sort(arr, low, i - 1);
    quick_sort(arr, i + 1, high);
}

int main() {
    int arr[] = {5, 3, 6, 1, 9, 33, 2, 6};
    int n = sizeof(arr) / sizeof(int);
    quick_sort(arr, 0, n - 1);

    for (int i = 0; i < n; ++i) {
        printf("%d ", arr[i]);   
    }
    printf("\n");
}
