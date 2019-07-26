//This program takes set of binary images of worms and calculates their length, colume and surface area.
// INSTRUCTIONS:
//This programme is run from ImageJ.
//Binary images of the worm should be loaded into a subdirectory called "binary". This can be done using the program "binary.ijm"
//The results will be placed in the file "output.txt" subdirectory "output"
//For each worm there will also be a set of coordinates of the outline of the worm which can be used in another program, such as Excel.
//There are in a file called "**output.txt" (** is the name of the image file) for each worm, also in the subdirectory "output".
//A straightened image of each worm "**straight.tif" is saved in the subdirectory "straight"

//close any open images
while (nImages>0) { 
selectImage(nImages); 
close(); 
}
//find all images
setOption("ExpandableArrays", true);
//Initiate all the variables
var phi="";
var k="";
var xo="";
var yo="";
var i="";
var vol="";
var l1="";
var l2="";
var l3="";
var m="";
var x3="";
var y3="";
var xx=newArray(1);
var yy=newArray(1);
var theta=newArray(1);
var Dl=newArray(1);
var rr=newArray(1);
var xx1=newArray(1);
var yy1=newArray(1);
var xx2=newArray(1);
var yy2=newArray(1);
var vol=newArray(1);
var surface=newArray(1);
var length=newArray(1);
var ll=newArray(1);
//Opens directory with all the images in a subdiectory "binary"
dir=getDirectory("Open a Directory with binary images in the subfolder binary");
File.makeDirectory(dir+"/output/");
File.makeDirectory(dir+"/straight/");
list = getFileList(dir+"/binary");
files=list.length;
for(n=0;n<files;n++){
	file=list[n];
//opens ech image in turn
	open(dir+"/binary/"+file);
  	getPixelSize(unit, ph, pw);
	f=File.nameWithoutExtension;
//converts image to the right form for the Imagej tools
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Duplicate...", "title=edge.tif");
	selectWindow(file);
//Turns into line down centre of worm
	run("Skeletonize (2D/3D)");
	k=10;
//Runs function beginning
	beginning();
	m=1;
//runs function points
	points();
//runs function ends
	ends();
	selectWindow(file);
	run("Convert to Mask");
//draws line around edge of worm line and measures it
	run("Set Measurements...", "perimeter redirect=None decimal=3");
	run("Analyze Particles...", "size=0.00-10000 pixel show=Nothing clear");
//length of worm is half perimeter line.
	length[n]=(getResult("Perim.",0))/2;
	m=4;
//subroutine points smooths out the worm line.
	points();
	ll[0]=0;
	for(j=1;j<=i-1;j++){
		Dl[j]=sqrt((xx[j]-xx[j-1])*(xx[j]-xx[j-1])+(yy[j]-yy[j-1])*(yy[j]-yy[j-1]));
		ll[j]=ll[j-1]+Dl[j];
	}
	ll[i]=ll[i-1]+Dl[i-1];
	selectWindow(file);
	close();
	vol[n]=0;
	surface[n]=0;
//runs function volume
	volume();
	close();
	rrr=0;
	for(jj=0;jj<i+1;jj++){
		if(rr[jj]>rrr){
			rrr=rr[jj];	
		}
	}
//calculates straightened worm
	newImage("Untitled", "8-bit white", 4*i+50, 2*rrr+40, 1);
	for (y=0;y<i;y++){
		drawLine(20+ll[y],20+rrr+rr[y],20+ll[y+1],20+rrr+rr[y+1]);
	}
	for (y=i-1;y>-1;y--){
		drawLine(20+ll[y+1],20+rrr-rr[y+1],20+ll[y],20+rrr-rr[y]);
	}
	run("Invert");
	run("Make Binary");
	floodFill(2*i+25, rrr+20);
	run("Invert");
	run("Make Binary");
//saves straighened worm
	saveAs("Tiff",dir+"/straight/straight"+f+".tif");
	close();
//Saves perimeter poimnts to output
	out=File.open(dir+"/output/"+f+"output.txt");
	for(j=1;j<i+1;j++){
		print(out,xx1[j]+"\t"+yy1[j]);
	}
	for(j=1;j<i+1;j++){
		print(out,xx2[j]+"\t"+yy2[j]);
	}
	File.close(out);
//Calculates output volume and surface area by adding volume and surface area of each segment
	for(j=1;j<=i-2;j++){
		vol[n]=vol[n]+PI*(rr[j]*rr[j]+rr[j]*rr[j-1]+rr[j-1]*rr[j-1])*Dl[j]/3;
		surface[n]=surface[n]+PI*(rr[j]+rr[j-1])*sqrt((rr[j]-rr[j-1])*(rr[j]-rr[j-1])+Dl[j]*Dl[j]);
	}
	vol[n]=vol[n]*pw*pw*pw;
	surface[n]=surface[n]*pw*pw;
}
//saves output data
output=File.open(dir+"/output/output.txt");
print(output,"File\tlength, "+unit+"\tvolume, "+unit+"^3\r\tsurface, "+unit+"^2 area");
for(x=0;x<files;x++){
	print(output,list[x]+"\t"+length[x]+"\t"+vol[x]+"\t"+surface[x]);
}
File.close(output);
//Function beginning draws line to find worm and moves it to find the beginning of worm
function beginning(){
	h=getHeight;
	w=getWidth;
	Dx=4;
	xo=w/2;
	makeLine(xo,0,xo,h);
	profile=getProfile;
	maxLocs=Array.findMaxima(profile, 30);
	y1=maxLocs[0];
	xo=xo-Dx;
	makeLine(xo,0,xo,h);
	profile=getProfile;
	maxLocs=Array.findMaxima(profile, 30);
	yo=maxLocs[0];
	Dy=yo-y1;
	phi=atan2(Dy,Dx);
	max=1;
	while(max==1){
		xo=xo-Dx*cos(phi);
		yo=yo+Dx*sin(phi);
		x1=xo+k*sin(phi);
		x2=xo-k*sin(phi);
		y1=yo+k*cos(phi);
		y2=yo-k*cos(phi);
		makeLine(x1,y1,x2,y2);
		profile=getProfile;
		maxLocs=Array.findMaxima(profile,30);
		max=maxLocs.length;
		if (max!=0){
			a=maxLocs[0];
			l=a-k;
			xo=xo-l*sin(phi);
			yo=yo-l*cos(phi);
			phi=phi-atan2(l,Dx);
		}
	}
	max=0;
	while(max==0){
		xo=xo+cos(phi);
		yo=yo-sin(phi);
		x1=xo+k*sin(phi);
		x2=xo-k*sin(phi);
		y1=yo+k*cos(phi);
		y2=yo-k*cos(phi);
		makeLine(x1,y1,x2,y2);
		profile=getProfile;
		maxLocs=Array.findMaxima(profile,30);
		max=maxLocs.length;
	}
	a=maxLocs[0];
	l=a-k;
	xo=xo-l*sin(phi);
	yo=yo-l*cos(phi);
}
//Function points finds the outline of worm by moving along central worm line
function points(){
	selectWindow(file);
	poin=1;
	k=20;
	i=0;
	while(poin>0){
		xx[i]=xo;
		yy[i]=yo;	
		theta[i]=phi;
		i=i+1;
		xo=xo+m*cos(phi);
		yo=yo-m*sin(phi);
		x1=xo+k*sin(phi);
		x2=xo-k*sin(phi);
		y1=yo+k*cos(phi);
		y2=yo-k*cos(phi);
		makeLine(x1,y1,x2,y2);
		profile=getProfile;
		maxLocs=Array.findMaxima(profile,30);
		poin=maxLocs.length;
		if (poin!=0){
			a=maxLocs[0];
			l=a-k;
			xo=xo-l*sin(phi);
			yo=yo-l*cos(phi);
			phi=atan2(l,m)+phi;
		}
	}
}
//Function ends extend to central line to the end of the worm.
function ends(){
	selectWindow("edge.tif");
	run("Outline");
	x1=xx[0];
	y1=yy[0];
	k=50;
	x2=x1-k*cos(theta[0]);
	y2=y1+k*sin(theta[0]);
	makeLine(x1,y1,x2,y2);
	profile=getProfile;
	maxLocs=Array.findMaxima(profile,100);
	if(maxLocs.length>0){
		selectWindow(file);
		setColor("red");
		xo=x1-maxLocs[0]*cos(theta[0]);
		yo=y1+maxLocs[0]*sin(theta[0]);
		drawLine(x1,y1,xo,yo);
		phi=theta[0];
	}
	selectWindow("edge.tif");
	x1=xx[i-1];
	y1=yy[i-1];
	x2=x1+k*cos(theta[i-1]);
	y2=y1-k*sin(theta[i-1]);
	makeLine(x1,y1,x2,y2);
	profile=getProfile;
	maxLocs=Array.findMaxima(profile,100);
	if(maxLocs.length>0){
		selectWindow(file);
		x3=x1-maxLocs[0]*cos(theta[0]);
		y3=y1+maxLocs[0]*sin(theta[0]);
		drawLine(x1,y1,x3,y3);
	}
	else{
		x3=x1;
		y3=y1;
	}
}
//Function volume calculates volume each segement of worm.
function volume(){
	selectWindow("edge.tif");
	xo=xx[0];
	yo=yy[0];
	poin=2;
	k=40;
	r=0;
	a=0;
	n=0;
	for(a==0;a<i;a++){
		if(a>4 && a<i-5){
			phi=(theta[a-3]+theta[a-2]+theta[a-1]+theta[a]+theta[a+1]+theta[a+2]+theta[a+3])/7;
		}
		else{
			phi=theta[a];
		}
		xo=xx[a];	
		yo=yy[a];
		x1=xo+k*sin(phi);
		x2=xo-k*sin(phi);
		y1=yo+k*cos(phi);
		y2=yo-k*cos(phi);
		makeLine(x1,y1,x2,y2);
		profile=getProfile;
		maxLocs=Array.findMaxima(profile,30);
		if(maxLocs.length>1){
			r=sqrt((maxLocs[0]-maxLocs[1])*(maxLocs[0]-maxLocs[1]))/2;
			if(maxLocs[1]>maxLocs[0]){
				xx1[a+1]=x1-maxLocs[0]*sin(phi);
				yy1[a+1]=y1-maxLocs[0]*cos(phi);
				xx2[a+1]=x1-maxLocs[1]*sin(phi);
				yy2[a+1]=y1-maxLocs[1]*cos(phi);
			}
			else{
			xx2[a+1]=x1-maxLocs[0]*sin(phi);
			yy2[a+1]=y1-maxLocs[0]*cos(phi);
			xx1[a+1]=x1-maxLocs[1]*sin(phi);
			yy1[a+1]=y1-maxLocs[1]*cos(phi);
			}
		}
		rr[a]=r;
	}
	xx1[1]=xx[0];
	yy1[1]=yy[0];
	xx2[1]=xx[0];
	yy2[1]=yy[0];
	xx1[i]=x3;
	yy1[i]=y3;
	xx2[i]=x3;
	yy2[i]=y3;
	rr[0]=0;
	rr[i]=0;
}
