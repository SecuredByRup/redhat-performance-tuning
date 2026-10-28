#include <stdio.h>
#include <unistd.h>

int main() {
    printf("Starting long-running CPU task (PID: %d)\n", getpid());
    // Run an infinite loop so we have plenty of time to profile it
    while(1) {
        volatile double result = 12345.6789 * 98765.4321;
    }
    return 0;
}
