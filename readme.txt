
                               ____ ____  ____  _   _ ____      _           
                              / ___|  _ \|  _ \| \ | |___ \ ___(_)_ __ ___  
                             | |   | |_) | |_) |  \| | __) / __| | '_ ` _ \ 
                             | |___|  __/|  __/| |\  |/ __/\__ \ | | | | | |
                              \____|_|   |_|   |_| \_|_____|___/_|_| |_| |_|
______________________________________________________________________________________________________________

README

Product of Matter Assembly and Computation (MAC) Lab at University of Colorado, Boulder

CPPN2sim is a package for the programmatic simulation of CPPNs created with MAClab's Network Explorer App.

This package streamlines the ability to simulate and analyze actuators created with the aforementioned app
using both triangular (shell) and tetrahedral (tet) elements.

The function 'fullMonty' contains within it all functionalities of this package, so if you are confused
regarding the usage of any functions, examine this file. The function 'genFinger' is similar, but does not
create and simulate a tetrahedral representation of the input CPPN.

In addition to all dependencies provided in the dependencies folder, the entirety of the GIBBON package 
and ABAQUS CAE are required as well. The following lines provide one method of adding non-GIBBON 
dependencies to the path and removing them after executing arbitrary code.
---
    %% Add dependencies to path, save that path location, execute arbitrary code, and clean up the path
    dep_folder = genpath('dependencies');
    addpath(dep_folder);
    %{
        arbitrary code
    %}
    rmpath(dep_folder);
---

GIBBON Website Link
https://www.gibboncode.org/
______________________________________________________________________________________________________________

Original authors: Jacob Haimes and Lawrence Smith

Last updated: 2/7/2022
