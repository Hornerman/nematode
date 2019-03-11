//Macro to turn an image of a nematode into a binary image, aligned with its longest dimension horizontally. It is designed to be used together with the macro wprm.ijm to measure the size of nematodes.
//The colour images should be stored in a folder called "photos" (with no other files, and the binary images are stored in a folder called "binary", which will be created if it does not already exist.
//You should chouse the colour channel which produces the clearest binary image.

//This closes any open images
while (nImages>0) { 
selectImage(nImages); 
close(); 
}

setOption("ExpandableArrays", true);
//This allows you to choose the best colour channel
colour=getString("Choose best colour channel","blue");
//choose directory
dir=getDirectory("Open a Directory");
//find all images in the folder "photos".
list = getFileList(dir+"/photos");
for(n=0;n<list.length;n++){
//open the images one at a time.
file=list[n];
open(dir+"/photos/"+file);
getPixelSize(unit, ph, pw);

//separate colour channels, and delete all except one
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
run("Enhance Contrast...", "saturated=0.5");
//Turn into a binary images
run("Make Binary");
run("Dilate");
run("Fill Holes");
run("Erode");
m=0;
//apply the erode tool until there is only one object in the image, and then dilate back to the original size.
do{
run("Erode");
run("Analyze Particles...", "size=0-100000 pixel circularity=0.00-1.00 show=Nothing display exclude clear ");
m=m+1;
}
while(nResults>1)
for(k=0;k<m;k++){
run("Dilate");
}
w=getWidth;
h=getHeight;
if(h>w){
	size=2*h;
}
else{
	size=2*w;
}
w=w*2;
run("Make Binary");
run("Invert");
//enlarge the canvas.
run("Canvas Size...", "width=size height=size position=Center");
run("Invert");
//find angle to get width at a maximum
run("Set Measurements...", "feret's redirect=None decimal=3");
run("Analyze Particles...", "size=0.00-1000000 pixel show=Nothing clear");
//find the angle of the longest dimension
ang=getResult("FeretAngle",0);
//Rotate image so the longest dimension is horizontal.
run("Rotate... ", "angle=ang grid=1 interpolation=Bilinear");
//Set the scale of the binary image to be the same as the original image.
run("Set Scale...", "distance=1 known="+ph+" unit="+unit);
dir1=dir+"/binary/";
File.makeDirectory(dir1);
//Save the image in the folder "binary".
saveAs("tiff", dir1+file);
close();
}