#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#define SIZE (1024 * 1024 * 64) // 64 MB array

int main() {
    printf("Starting memory test (PID: %d)\n", getpid());
    int *arr = malloc(SIZE * sizeof(int));
    if (!arr) {
        perror("malloc failed");
        return 1;
    }

    for (int i = 0; i < 10; i++) {
        for (int j = 0; j < SIZE; j += 64) {
            arr[j] = j + i;
        }
    }

    free(arr);
    printf("Memory test completed\n");
    return 0;
}
