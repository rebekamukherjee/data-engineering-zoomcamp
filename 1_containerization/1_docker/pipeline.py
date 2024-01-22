import sys
import pandas

print(pandas.__version__)
print('Pandas installation was successful!')

# sys.argv allows to pass arguments to the script from the commandline
# sys.argv[0] is name of the file
# sys.argv[1] is first argument passed
day = sys.argv[1]

print(f"Job finished successfully for day = {day}")