# nematode
These macros are designed to measure the size of nematodes from photographs. There are two macros to be used in FIJI, a form of ImageJ.
FIJI is available to download from https://fiji.sc/. These macros should be downloaded and put in any folder. They can be run from FIJI by selecting plugins-run-macros.

In order to use the program, photographs of the worms should be placed in a sub folder called photos.
Each photo should have only one worm, and should have good contrast. 
The photos should be spatially calibrated. This can be done by photographing a known length at the same magnification and using the calibration option ImageJ or other imaging program.
An example of a suitable image is included.

First  the macro binary.ijm from FIJI.
You will be first asked to input the folder containing the sub folder photos.
You then have to choose which colour channel, red, green or blue, gives the best contrasted image of the worm. This can be done by trial and error.
The macro will produce a sub folder called binary containing binary photos of the worms.
The binary images should be examined to see that they conform to the orinal shape of the worms. You may have run the program again and choose a different colour channel to improve the binary images.

When this is done, you should run the macro worms from FIJI.
This will produce a sub folder output
There will be a text file called output(imagefilename).txt for each image, listing the pixel coordinates of the outline of the worm
There will also be a file output.txt containing a list of the length, volume and surface area of each worm iin the units used in the spatial calibration. 
A folder called straight contains bninary images of worms as they would have been if straight.
