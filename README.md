<!-- prettier-ignore-start -->
[comment]: # (
SPDX-License-Identifier: GPL-3.0-or-later
)

[comment]: # (
SPDX-FileCopyrightText: 2021 Javier Arribas Lázaro <jarribas@cttc.es>
)
<!-- prettier-ignore-end -->

# Introduction
This repository contains a simple procedure for managing Xilinx Vivado projects with GIT. It is not invasive in the sense that it does not require any custom write_to_tcl script or any Vivado init modification. It uses what it comes with Vivado and a simple shell scripts. I tested it with Vivado 2018.3 and it comes with absolutely no warranty. The ultimate goal is a *painless* restore of Vivado projects in different computers with different users/folders structure.

Good luck and happy VHDL coding!

# How to start a Vivado project for GIT version control

1. Create a project directory (e.g. ~/git/my_project_name)
2. cd ~/git/my_project_name and type git init
3. Create a .gitignore file with these contents:

```
my_project_name*
!my_project_name.tcl
vivado*
```

This will avoid adding the auto-generated project files with the exception of the generated TCL project script obtained using Vivado write_project_tcl.

4. create the following directory structure:

```
--src
---design
----ip_instances
-----ip1_instance
-----ip2_instance
-----ipN_instance
----bd
-----bd1
-----bd2
-----bdN
---testbench
---ip_instances
----ip_instances
-----ip1_instance
-----ip2_instance
-----ipN_instance
```

Basically **all the project sources should be placed in the sdr folder**, that includes the VHDL/Verilog files and the Vivado IP instances with extension .xci. **Vivado requires that each IP instance is placed in a different subdirectory**.
Any other file, for instance the component.xml and the xgui files when designing a custom IP can be placed in git origin folder (e.g ~/git/my_project_name/component.xml and ~/git/my_project_name/xgui/)

5. Start Vivado and create the project with the project wizard, be sure to set the base directory to ~/git/my_project_name and the project name as my_project_name
In this way the project will be created in a subdirectory called my_project_name inside my_project_name. With the gitignore settings the project directory will not be added to GIT.

6. Fill the project but take into account these directives:
* When adding existing sources, copy first them to the appropriate subdirectory in ./src and add them to the project not enabling the copy sources to project checkbox.
* When creating new sources, always create them in the appropriate ./src subfolder
* Board Designs should also be created in their corresponding dedicated subfolder in ./src tree. Only the .bd file is required to be stored in GIT (see next Section for further details)

7. When the project is verified and ready to be uploaded to GIT, generate the Vivado project TCL script by executing the following TCL command from the the GIT project root folder (e.g. ~/git/my_project_name, double check it by executing pwd command!)

```
set proj_file [current_project].tcl
write_project_tcl -no_copy_sources -force $proj_file
```

OR if the design contains BD files

```
set proj_file [current_project].tcl
write_project_tcl -no_copy_sources -use_bd_files -force $proj_file
```

This should create a tcl script called my_project_name.tcl in ~/git/my_project_name.

8. Finally, goto console terminal and perform the usual GIT commands to commit and push the changes. E.g:
```
git add ./
git commit -m “My latest changes”
git push origin master
```
The .gitignore file takes care of not adding any autogenerated vivado project file.


# Special attention when working with board design files (.bd).
The board design file contains all the required information to rebuild the project, however, Vivado always produces sub-product files the first time the .bd diagram is opened from GUI. These files are stored in the same directory as the .bd file.
It is not necessary upload the board design sub-products to GIT. In order to ignore them, it is required to add each bd source folder to the gitignore list and exclude the .bd file itself.
Example of a complete .gitignore file with one board design:

```
my_project_name/*
!my_project_name.tcl
src/design/bd/system/*
!src/design/bd/system/system.bd
vivado*
!vivado_startup.tcl
```

# How to restore or update a Vivado project from GIT

1. Clone the repository or pull the latest changes to your local copy
2. Delete the vivado project directory if there is a previous version already on the local copy (e.g. rm -rf ~/git/my_project_name/my_project_name). Notice that this directory must be ignored by .gitignore because it will be rebuilt from TCL script.
3. Lanuch Vivado en batch mode to rebuild the project from the tcl script. Notice that the command must be issued from the git project directory (e.g. ~/git/my_project_name)

```
vivado -mode batch -source my_project_name.tcl
```
 
4. If everything goes well, Vivado will create a complete project inside ~/git/my_project_name/my_project_name. Launch again Vivado but if you are using Docker, this time with ./run_vivado.sh and open the project file in ~/git/my_project_name/my_project_name/my_project_name.xpr
5. Work normally and remember to add or create sources always in ./src subfolder.


# EXTRA: Start Vivado with external license file from Docker container

Included in this repository can be found a custom run_vivado shell script and an associated .tcl startup script, useful to start Vivado GUI from a Docker container, set the required license file from external location and disable webtalk.

Usage:

```
$./run_vivado.sh -l path_to_license_file.lic
```
