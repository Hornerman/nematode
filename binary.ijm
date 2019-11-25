//Macro to turn an image of a nematode into a binary image, aligned with its longest dimension horizontally. 
//It is designed to be used together with the macro worm.ijm to measure the size of nematodes.

//INSTRUCTIONS
//First you need to select the images of the nematodes. If there are more than one nematode in a photo (or other extranious objects),
//you should crop the image so that the worm is on its own.

//The colour images should be stored in a subfolder called "photos" (with no other files).
//The binary images will be put in a subfolderfolder called "binary", which will be created if it does not already exist.

//You should choose the colour channel (red, green or blue which produces the clearest binary image. It will ask you to choose a colour, and you
//should choose either red, green or blue. The one that gives the clearest set of binary images is the best.
//This macro requires the built in routines "Split chnannels", "Make binary", "Fill holes", "Dilate", "Erode", "Analyse particles",
//"Invert", "Canvas size", "Enhance particles", "Set measurement", "Rotate", "Set scale", 

//This closes any open images
while (nImages>0) { 
	selectImage(nImages); 
	close(); 
}
//Declare variables used in the program
//pixelheight and pixelwidth are the height and width of each pixel respectively
var pixelheight="";
var pixelwidth="";
//n is the number of the image.
var n="";
//m is the total number of times the image is eroded to get rid of extranious objects.
var m="";
//k is an integer to count the number of dilations
var k="";
//imagewidth and imageheight are the image widths and heights respectively
var imagewidth="";
var imageheight="";
//angl is the Feret angle.
var angl="";
//This allows you to choose the best colour channel
colour=getString("Choose best colour channel (red, green or blue)","blue");
//choose directory
dir=getDirectory("Open a Directory");
//find all images in the folder "photos".
list = getFileList(dir+"/photos");
for(n=0;n<list.length;n++){
	//open the images one at a time.
	file=list[n];
	open(dir+"/photos/"+file);
	getPixelSize(unit, pixelheight, pixelwidth);
	//Separate colour channels, and delete all except the one you have chosen
	run("Split Channels");
	if(colour!="red"){
		selectWindow(file+" (red)");
		close();
	}
	if(colour!="blue"){
		selectWindow(file+" (blue)");
		close();
	}
	if(colour!="green"){
		selectWindow(file+" (green)");
		close();
	}
	//Increase he contrast in the chosen image, turn it into a binary image and fill in any holes, dilating
	//and then eroding the image produces a cleaner outline.	
	run("Enhance Contrast...", "saturated=0.5");
	run("Make Binary");
	run("Dilate");
	run("Fill Holes");
	run("Erode");
	m=0;
	//Apply the erode tool until there is only one object in the image, and then dilate back to the original size.
	run("Analyze Particles...", "size=0-100000 pixel circularity=0.00-1.00 show=Nothing display exclude clear ");
	if(nResults>1){
		do{
			run("Erode");
			run("Analyze Particles...", "size=0-100000 pixel circularity=0.00-1.00 show=Nothing display exclude clear ");
			m=m+1;
		}
		while(nResults>1)
		for(k=0;k<m;k++){
			run("Dilate");
		}
	}
		//Find the width of the canvas and enlarge it to double the width so that rotating the image of the worm 
		//will stay within the canvas.
		imagewidth=getWidth;
		imageheight=getHeight;
		if(imageheight>imagewidth){
			size=2*imageheight;
		}
		else{
			imagewidth=2*imagewidth;
		}
	run("Make Binary");
	run("Invert");
	run("Canvas Size...", "width=imagewidth height=imagewidth position=Center");
	run("Invert");
	//Find angle to get width at a maximum. The Feret angle is the angle between the Feret diameter (the longest distance between
	//any two points on the image) and the horizontal 
	run("Set Measurements...", "feret's redirect=None decimal=3");
	run("Analyze Particles...", "size=0.00-1000000 pixel show=Nothing clear");
	angl=getResult("FeretAngle",0);
	//Rotate image so the longest dimension (Feret diameter) is horizontal.
	run("Rotate... ", "angle=angl grid=1 interpolation=Bilinear");
	//Set the scale of the binary image to be the same as the original image.
	run("Set Scale...", "distance=1 known="+pixelheight+" unit="+unit);
	//Save the image in the folder "binary", opening a new folder if necessary.
	dir1=dir+"/binary/";
	File.makeDirectory(dir1);
	saveAs("tiff", dir1+file);
	close();
}