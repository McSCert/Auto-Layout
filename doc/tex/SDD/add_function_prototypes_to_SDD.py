# This script copies and pastes the function prototype and descriptions of the MATLAB functions used for the Auto Layout tool into the latex document.
# It also maintains the MATLAB format while pasting the information, and overrides any previous function prototype and descriptions in the latex document.

import os #used to change directory and get path names

# Determine if the subsection is the name of a MATLAB script. If so, return the index of where to find it in the list of MATLAB scripts used for the tool.
def find_matlab_script(name,list_of_fncs):
        for i in range(0,len(list_of_fncs)):
                if(name == list_of_fncs[i]): #script name exists
                        return i #return index to find it
        return -1 #did not find a matching script name

#open the latex document for reading and writing 
f_tex = open("AutoLayout_sdd.tex","r+")
#read all lines in the document and store it in a list
lines_sdd = f_tex.readlines()           

#set directory to src code to find all functions used in the tool
os.chdir("..\..\..\.."); 
os.chdir("Tools\AutoLayout\src");

#create a list of all matlab scripts/functions in the AutoLayout src directory and their paths
#the ith element in list of function names corresponds to the ith element in the list of paths
list_of_fncs = []
list_of_paths = []

#for each path found in the current directory
for root, dirs, files in os.walk("."):
        #for each file
        for filename in files:
                #Look for only matlab scripts by checking the extension of the file
                if(filename.endswith(".m")): #file is a matlab script
                        #get the file path and the file name
                        pathname = os.path.join(root,filename)
                        #add the file name to the list of functions while ignoring the extension (i.e. last two characters)
                        list_of_fncs.append(filename[0:-2])
                        #add the file path to the list of paths
                        #note: pathname string always starts with ".\", so ignore the first two character
                        list_of_paths.append(pathname[2:])

#create a list of lines to write into the latex document
new_latex = []
#variable is used to determine if a line being read from the latex document should not be added to the list of lines to write into the latex document
skipLines = False

#add lines from the latex document one at a time by iterating through list of lines created for the latex document previously
#ignore any lines between the lslisting sections (inclusive) because those are previous matlab function prototypes and descriptions
#while adding lines to new_latex, check if the current subsection corresponds to a matlab function
#if so, open the matlab script and copy and paste the function prototye and description to new_latex in between a lslisting section
for currLine_latex in lines_sdd:
        #ignore previous lslsting sections (i.e. previous MATLAB prototype and description)
        if(currLine_latex.startswith("\\begin{lstlisting}")):
                skipLines = True;
        #last line to ignore if the beginning of a lstlisting was found
        if(currLine_latex.startswith("\\end{lstlisting}")):
                skipLines = False;
        #skip adding the current line if the line is part of a lslisting section
        if(skipLines or currLine_latex == "\\end{lstlisting}"):
              continue
        
        new_latex.append(currLine_latex)

        #all matlab function sections are in a \subsection{}, so only check those lines from the latex document for matlab function sections
        if(currLine_latex.find("subsection{")):
                #get the text withing the curly brackets by finding the indices of where they are
                start_index = currLine_latex.find("{")
                end_index = currLine_latex.find("}")
                fnc_name = currLine_latex[start_index+1:end_index]
                #functions with "_" in the string are written with "\_" in latex, so get rid of the backslash
                fnc_name = fnc_name.replace("\\","")
                #check if the subsection corresponds to a matlab function
                #i is -1 if no function is found or it is the index of the function name and path in the list created previously
                i = find_matlab_script(fnc_name,list_of_fncs)
                if(i >= 0): #subsection is a matlab function
                        #open the MATLAB script for reading and read all lines
                        f = open(list_of_paths[i],"r")
                        lines = f.readlines()
                        #insert the starting point of the lstlisting section
                        new_latex.append("\\begin{lstlisting}\n")
                        #first line of MATLAB script is always the function prototype
                        new_latex.append(lines[0])
                        #use varriable j to iterate through the MATLAB script files
                        j = 1
                        currLine = lines[j]
                        #only add the first few MATLAB comment lines because the function description are included in these comments
                        while(currLine.startswith("%")):
                                new_latex.append(currLine)
                                j += 1
                                currLine = lines[j]
                        #insert the ending point of the lstlisting section
                        new_latex.append("\\end{lstlisting}\n")
                        f.close()

#set the file pointer to the beginning of the file
f_tex.seek(0,0)
#write all lines
f_tex.writelines(new_latex)           
f_tex.close()
