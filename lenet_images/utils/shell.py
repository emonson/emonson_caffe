import subprocess

# Generic command string running under bash shell
def run_command(command_string):
    try:
        retcode = subprocess.call(command_string, shell=True)
        if retcode < 0:
            print >>sys.stderr, "Child was terminated by signal", -retcode
    except OSError as e:
        print >>sys.stderr, "Execution failed:", e

