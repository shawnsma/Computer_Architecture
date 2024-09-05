#include <stdio.h>
#include <stdlib.h>

int recurse(int n){
    if (n == 0){
        return 2;
    }
    return 3 * n - 2 * (recurse(n - 1)) + 7;
}

int main(int argc, char* argv[]){

    int n = atoi(argv[1]);

    int result = recurse(n);

    printf("%d", result);

    return EXIT_SUCCESS;
}