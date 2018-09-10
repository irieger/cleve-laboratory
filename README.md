# Extension for Cleve Laboratory

### General notes
Original Cleve Laboratory information: [https://de.mathworks.com/matlabcentral/fileexchange/59085-cleve-laboratory](https://de.mathworks.com/matlabcentral/fileexchange/59085-cleve-laboratory)

This repository is intended to document a few changes to optimize performance and allow a few additional operations on fp16 half float datatype. It is mostly done as a reference to show Cleve the idea of the changes to maybe get some of them in the official Cleve Laboratory source.

### What are the contents of this repository
This repo contains the content of the ~/Documents/MATLAB/Add-Ons/Apps/CleveLaboratory extended by the licence.txt from the installation zip and this readme file.

### Changelog

Changes based on official release 3.60.0.0 (Uploaded 2018-06-11, downloaded 2018-09-10)

* Add a function to get access to underlying uint16 structure storing the IEEE 754-2008 based binary half float representation allowing binary operations on the data.
* Add fp16 constructor flag (string 'packed' or 'native' as the second argument besides initial values) to interpret uint16 data as already packed IEEE 754-2008 based binary half floats.
