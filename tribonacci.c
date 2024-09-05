#include <stdio.h>
#include <stdlib.h>

int main(int argc, char* argv[]){

    int n = atoi(argv[1]);

    if (n < 0) {
        return EXIT_FAILURE;
    }

    int list[n];

    if (n == 0) {
        return EXIT_SUCCESS;
    }
    if (n >= 1) {
        list[0] = 1;
    }

    if (n >= 2) {
        list[1] = 1;
    }
    
    if (n >= 3) {
        list[2] = 2;
    }

    int tracker = 3;

    while(tracker < n){
        list[tracker] = list[tracker - 3] + list[tracker - 2] + list[tracker - 1];
        tracker++;
    }

    for (int i = 0; i < n; i++) {
        printf("%d ", list[i]);
        printf("\n");
    }

    return EXIT_SUCCESS;
}