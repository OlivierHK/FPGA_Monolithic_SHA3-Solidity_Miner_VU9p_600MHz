To generate the .VHD file with all the correct DRP values:


1- Run the .c file (MMCM_Coeff.c) after setting all the correct values (Fin,Fout Min/Max, Fsweet Delta,...).

2- Copy the .c output to the Excel File first table (DRP_Tables.ods). It will format the data for Tcl.

3- Copy the whole Excel first table inside the Tcl file end.

4- Run the Tcl file (DRP_Table_gen.Tcl )with Xilinx Vivado to generate all the DRP values.

5- copy the Tcl ouput to the Excel second table for formatting the data(DRP_Tables.ods).

6- Copy the last table of the Excel into the ROM VHDL File.

7- Enjoy.