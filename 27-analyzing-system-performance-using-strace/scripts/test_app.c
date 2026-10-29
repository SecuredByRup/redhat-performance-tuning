#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>

int main() {
    pid_t pid = fork();

    if (pid == 0) {
        // Child process
        execl("/bin/ls", "ls", "-la", "/tmp", NULL);
    } else {
        // Parent process
        wait(NULL);
        printf("Child process completed\n");
    }

    return 0;
}
