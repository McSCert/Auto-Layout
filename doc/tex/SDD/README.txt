NOTES:
- The add_function_prototypes_to_SDD.py script is used to update the AutoLayout_sdd.tex file by copying and pasting the function prototypes and descriptions from the MATLAB function files.
- There are detailed comments in the script to help explain the code.
- The script ignores previous MATLAB functions and descriptions and overwrites them.
- The script assumes that the SDD document and the script are in the \tools\Simulink\Documentation\AutoLayout\doc\SDD directory.
- The script assumes that all of the functions used for the Auto Layout tool are in the directory \tools\Simulink\Tools\AutoLayout\src
- The script assumes that a subsection or subsubsection will have the name of a MATLAB function if and only if that section is used to describe the function.

WARNING:
- The script will override the entire latex document. So, save and have a backup for the latex document before running the script.

INSTRUCTIONS:
- Run the python script and the latex document will be updated with the current MATLAB function prototypes and descriptions.