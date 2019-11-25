//This program takes set of binary images of worms and calculates their length, colume and surface area.
// INSTRUCTIONS:
//This programme is run from ImageJ.
//Binary images of the worm should be loaded into a subdirectory called "binary". This can be done using 
//the program "binary.ijm". The results will be placed in the file "output.txt" subdirectory "output".
//For each worm there will also be a set of coordinates of the outline of the worm which can be used 
//in another program, such as Excel. There are in a file called "**output.txt" (** is the name of the
//image file) for each worm, also in the subdirectory "output". A straightened image of each worm 
//"**straight.tif" is saved in the subdirectory "straight". This macro uses the subroutines 
//"Convert to mask", Duplicate", "skeletonize (2D/3D)", "Analyse particles", "Make binary",
// and "Outline".

	//close any open images
	while (nImages>0) { 
	selectImage(nImages); 
	close(); 
	}
	//Initiate all the variables and arrays
	setOption("ExpandableArrays", true);
	//Pixelwidth = width of pixels = height of pixels (square)
	var pixelwidth="";
	//phi is the angle  the centre line of the worm makes to the horizontal 
	var phi="";
	//k is an integer giving length of the line drawn normal to worm.
	var k="";
	k=10;
	//xo and yo are integers giving the position in the x and y directions that the worm is measured
	//relative to the top left of the image.
	var xo="";
	var yo="";
	//deltax and deltay and distance moved along worm in x and y directions
	var deltax="";
	var deltay="";
	//i and j are the indeces in the arrays of points on the worm 
	var i="";
	var j="";
	//m defines the distance (in pixels) along the worm for each measuresment
	var m="";
	//x3 and y3 define the position of the end of the worm.
	var x3="";
	var y3="";
	//rmax is the maximum radius of worm.
	var rmax="";
	//imageheight and imagewidth are the height and width of image
	var imageheight="";
	var imagewidth="";
	//a and l are the distances of maxima from the end of profile line and centre of profile line respectively.
	var a="";
	var l="";
	//max is the number of maxima on the profile line.
	var max="";
	//xx[] and yy[] are arrays arrays giving the coordinates of the central line of the worm.
	var xx=newArray(1);
	var yy=newArray(1);
	// theta[] is an array of the angles the central line makes to the x-axis.
	var theta=newArray(1);
	//Deltal[] is an array of each section of the worm line.
	var Deltal=newArray(1);
	//ll[] is an array giving the length of the worm up to each meureent point
	var ll=newArray(1);
	//radius[] is an array of the radii of the worm at each point
	var radius=newArray(1);
	//xx1[], yy1[], xx2[] and yy2[] are arrays of the coordinates of each side of the outline of the worm
	var xx1=newArray(1);
	var yy1=newArray(1);
	var xx2=newArray(1);
	var yy2=newArray(1);
	//volume[], surface[] and length[] are arrays of the calculated volume, surface area and length 
	//respectively for each worm.
	var volume=newArray(1);
	var surface=newArray(1);
	var length=newArray(1);
	//Open directory with all the images in a subdirectory "binary" and reads them
	dir=getDirectory("Open a Directory with binary images in the subfolder binary");
	File.makeDirectory(dir+"/output/");
	File.makeDirectory(dir+"/straight/");
	list = getFileList(dir+"/binary");
	files=list.length;
	for(n=0;n<files;n++){
		file=list[n];
		//Open each image in turn and processes it
		open(dir+"/binary/"+file);
		//Find size of pixels
  		getPixelSize(unit, pixelwidth, pixelwidth);
		f=File.nameWithoutExtension;
		//Convert image to the right form for the Imagej tools
		setOption("BlackBackground", false);
		run("Convert to Mask");
		//Duplicate the image ans ave as edge.tif
		run("Duplicate...", "title=edge.tif");
		selectWindow(file);
		//erode the image of the worm down to the central line
		run("Skeletonize (2D/3D)");
		//Run function 'beginning', to find the start of the worm
		beginning();
		//Run function 'points', with the greatest resolution (m=1). It returns the position of the central 
		//line stored in the arrays xx[] and yy[]
		m=1;
		points();
		//Run function 'ends'. Since the "Skeletonize (2D/£D) function erodes the worm down to a line, the 
		//ends of the central line do not extend to the end of the worm. This fuction measures the length 
		//to the ends of the worm and draws a line on the image
		ends();
		//Select the image of the central line
		selectWindow(file);
		run("Convert to Mask");
		//Draw line around worm line and measure it
		run("Set Measurements...", "perimeter redirect=None decimal=3");
		run("Analyze Particles...", "size=0.00-10000 pixel show=Nothing clear");
		//Length of worm is half perimeter line. This is saved in length[] for each worm.
		length[n]=(getResult("Perim.",0))/2;
		//Run function 'points' again with the ends included.
		m=1;
		points();
		//Calculate length Deltal[] of each segment, and also ll[], the distance along the worm of the segment
		//from the start of the worm. This uses Pythogras to calculate the length. 
		ll[0]=0;
		for(j=1;j<=i-1;j++){
			Deltal[j]=sqrt((xx[j]-xx[j-1])*(xx[j]-xx[j-1])+(yy[j]-yy[j-1])*(yy[j]-yy[j-1]));
			ll[j]=ll[j-1]+Deltal[j];
		}
		ll[i]=ll[i-1]+Deltal[i-1];
		//Close the central line image
		selectWindow(file);
		close();
		//Set the volume and surface area for worm to zero.
		volume[n]=0;
		surface[n]=0;
		//Run function 'radii' which calculates the radii of the worm as explained below.
		radii();
		//Find the maximum radius rmax of worm
		rmax=0;
		for(j=0;j<i+1;j++){
			if(radius[j]>rmax){
				rmax=radius[j];	
			}
		}
		//Calculate and draw straightened worm
		newImage("Untitled", "8-bit white", 4*i+50, 2*rmax+40, 1);
		for (j=0;j<i;j++){
			drawLine(20+ll[j],20+rmax+radius[j],20+ll[j+1],20+rmax+radius[j+1]);
		}
		for (j=i-1;j>-1;j--){
		drawLine(20+ll[j+1],20+rmax-radius[j+1],20+ll[j],20+rmax-radius[j]);
	}
		//Change format of straightened image and fill.
		run("Invert");
		run("Make Binary");
		floodFill(2*i+25, rmax+20);
		run("Invert");
		run("Make Binary");
		//Save and close straighened image
		saveAs("Tiff",dir+"/straight/straight"+f+".tif");
		close();
		//Saves perimeter points to output
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
		//Volume of truncated cone is (1/3)*pi*height*(r^2+r*R+R^2) where r is one radius (radius[j])
		//and R is the other radius (radius[j-1]) and the height is deltal[j].
			volume[n]=volume[n]+PI*(radius[j]*radius[j]+radius[j]*radius[j-1]+radius[j-1]*radius[j-1])*Deltal[j]/3;
			//Lateral urface area of truncated cone is pi*(r+R)*(r-R)^2 + height^2)^0.5
			surface[n]=surface[n]+PI*(radius[j]+radius[j-1])*sqrt((radius[j]-radius[j-1])*(radius[j]-radius[j-1])+Deltal[j]*Deltal[j]);
		}
		//Take account of pixel size
		volume[n]=volume[n]*pixelwidth*pixelwidth*pixelwidth;
		surface[n]=surface[n]*pixelwidth*pixelwidth;
	}
	//saves output data to file output.txt	
	output=File.open(dir+"/output/output.txt");
	print(output,"File\tlength, "+unit+"\tvolume, "+unit+"^3\r\tsurface, "+unit+"^2 area");
	for(x=0;x<files;x++){
		print(output,list[x]+"\t"+length[x]+"\t"+volume[x]+"\t"+surface[x]);
	}
	File.close(output);

	//Function 'beginning' draws line to find worm and moves it to find the beginning of worm
	function beginning(){
		//Find size of image
		imageheight=getHeight;
		imagewidth=getWidth;
		//Set along the x direction for finding the end of worm.
		deltax=4;
		//Draw a line down middle of image from top to bottom	
		xo=imagewidth/2;
		makeLine(xo,0,xo,imageheight);
		//Get the intensity along line and find the maxima
		profile=getProfile;
		maxLocs=Array.findMaxima(profile, 30);
		//Assign the position of first maximum (where the line crosses the central line of worm) to y1
		y1=maxLocs[0];
		//Move the line to the left by deltax and repeat
		xo=xo-deltax;
		makeLine(xo,0,xo,imageheight);
		profile=getProfile;
		maxLocs=Array.findMaxima(profile, 30);
		//Assign the new position of ther first maximum to yo.
		yo=maxLocs[0];
		//This is used to calculate the slope of the worm line, phi
		deltay=yo-y1;
		phi=atan2(deltay,deltax);
		//Using this slope, the positions of a line is drawn normal to the worm line length 2*k
		//The intensity profile is measured along the line.
		//This line is moved along the worm while there is one maximum in the profile.
		max=1;
		while(max==1){
			xo=xo-deltax*cos(phi);
			yo=yo+deltax*sin(phi);
			x1=xo+k*sin(phi);
			x2=xo-k*sin(phi);
			y1=yo+k*cos(phi);
			y2=yo-k*cos(phi);
			makeLine(x1,y1,x2,y2);
			profile=getProfile;
			maxLocs=Array.findMaxima(profile,30);
			max=maxLocs.length;
			//Test whether there are any maxima on line, and if there are, move along worm.
			if (max!=0){
				a=maxLocs[0];
				l=a-k;
				xo=xo-l*sin(phi);
				yo=yo-l*cos(phi);
				phi=phi-atan2(l,deltax);
			}
		}
		//When there are no maxima, move the profile line slowly back to find where the wprm line starts.
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
		max=1;
		k=20;
		i=0;
		while(max>0){
			xx[i]=xo;
			yy[i]=yo;	
			theta[i]=phi;
			i=i+1;
			//Move along the worm
			xo=xo+m*cos(phi);
			yo=yo-m*sin(phi);
			//Draw profile line across the worm line.
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
				phi=atan2(l,m)+phi;
			}
		}
	}
	
	//Function'ends' extend to central worm line to the end of the worm.
	function ends(){
		//Open image and turn it into an outline.
		selectWindow("edge.tif");
		run("Outline");
		//Draw a profile line at the position of beginning of worm line
		x1=xx[0];
		y1=yy[0];
		k=50;
		x2=x1-k*cos(theta[0]);
		y2=y1+k*sin(theta[0]);
		makeLine(x1,y1,x2,y2);
		profile=getProfile;
		//Move the profile line away from the position of the worm line until there are no maxima
		//This means that the end of the worm has been located
		maxLocs=Array.findMaxima(profile,100);
		if(maxLocs.length>0){
			selectWindow(file);
			setColor("red");
			xo=x1-maxLocs[0]*cos(theta[0]);
			yo=y1+maxLocs[0]*sin(theta[0]);
			//Worm line is extended to end of worm in red.
			drawLine(x1,y1,xo,yo);
			phi=theta[0];
		}
		//The method is repeated for the other end of the worm.
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

	//Function radii calculates radii each segement of worm.
	function radii(){
		//Open the image giving outline of worm
		selectWindow("edge.tif");
		xo=xx[0];
		yo=yy[0];
		max=2;
		k=40;
		r=0;
		a=0;
		n=0;
		//Average the angle over several points to smooth out the line.
		for(a==0;a<i;a++){
			if(a>4 && a<i-5){
				phi=(theta[a-3]+theta[a-2]+theta[a-1]+theta[a]+theta[a+1]+theta[a+2]+theta[a+3])/7;
			}
			else{
				phi=theta[a];
			}
			//Draw a line normal to the centre point of line and measure profile.
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
				//Radius of worm is the modulus of the distance between the two maxima divided by 2
				r=sqrt((maxLocs[0]-maxLocs[1])*(maxLocs[0]-maxLocs[1]))/2;
				//Find the coordinates of the each side of the worm
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
			radius[a]=r;
		}
		//Assign the coordinates of the ends of the worm.
		xx1[1]=xx[0];
		yy1[1]=yy[0];
		xx2[1]=xx[0];
		yy2[1]=yy[0];
		xx1[i]=x3;
		yy1[i]=y3;
		xx2[i]=x3;
		yy2[i]=y3;
		radius[0]=0;
		radius[i]=0;
		//close edge image
		close();
	}
