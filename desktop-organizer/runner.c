/*
 * Desktop Organizer runner
 *
 * A single-purpose launcher: it spawns desktop-organizer.sh and waits. That is
 * all it can do. The launchd agent runs THIS binary, so Full Disk Access is
 * granted to just this file instead of to the shared /bin/sh interpreter.
 *
 * It deliberately spawns the script as a CHILD (posix_spawn) rather than
 * exec-replacing itself: TCC attributes the child's file access to the
 * responsible process — this runner — so the grant on the runner covers the
 * find/stat/mv the script performs. An execv would turn this process into
 * /bin/sh and the grant would no longer apply.
 *
 * SCRIPT_PATH is baked in at compile time by install.sh.
 */
#include <spawn.h>
#include <sys/wait.h>
#include <stdlib.h>

extern char **environ;

int main(void) {
    char *const argv[] = { (char *)SCRIPT_PATH, NULL };
    pid_t pid;

    if (posix_spawn(&pid, SCRIPT_PATH, NULL, NULL, argv, environ) != 0)
        return 1;

    int status;
    if (waitpid(pid, &status, 0) < 0)
        return 1;

    return WIFEXITED(status) ? WEXITSTATUS(status) : 1;
}
