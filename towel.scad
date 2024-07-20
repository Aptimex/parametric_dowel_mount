//use <MCAD/triangles.scad>
//triange() included at bottom for better compatibility

/* [What to Print] */
//Do not print this one, for visualization purposes only
visualize_assembly = 0; // [0:false, 1:true]
arm = 1; // [0:false, 1:true]
baseAndLock = 1; // [0:false, 1:true]
//Useful if you want to print the base lock in a different orientation and attach it
baseWithoutLock = 0; // [0:false, 1:true]
//Useful if you want to print the base lock in a different orientation and attach it
lockForBase = 0; // [0:false, 1:true]
//Print the standalone lock parts to make sure they're going to fit together well
lockingTest = 0; // [0:false, 1:true]

/* [Dowel] */
//Dowel diamerter in mm
dowelDia = 16; //mm, 5/8in
//Depth of material (grip) surrounding the dowel circumference
dowelGripD = 2.4;
//Depth of material backing the dowel end
dowelBackD = 3;
//How far the grip will cover the dowel end
dowelDep = 5;

/* [Arm] */
//Length of the arm
armLen = 70;

/* [Base] */
//Height of base
baseH = 80;
//Wdith of base
baseW = 25;
//Depth/thickness of base
baseD = 2.4;

/* [Dovetail] */
//Height of the right triangles used in the dovetail
dovetailSize = 5;
//Amount of extra wall to surround the dovetail
dovetailWallD = 3;
//How much height of the triangles to cut off for the dovetail. Should be about dovetailSize/2
dovetailCutoff = 2;
//Height of the stopper on locking mechanism
dovetailStopH = 2;
//Adjusts the PERCENTAGE (scale) tolerance between the locking pieces. Increase for looser fit.
dovetailTolerance = 8;
//Amount to trim the sharp dovetail edges; helps locking mechanism slide better
dovetailTrim = .4;
// How far the friction stop bar should stick out; too big and you won't be able to slide things into place
stopBar = .5;

//Don't include things past here in customizer
module blank() {}

//+0 to prevent customizer from using these
$fn = 100 + 0;
e = .01 + 0;
armDep = dowelDep+dowelBackD;
insetDia = dowelDia + (dowelGripD*2);
lockBackD = 1.2 + 0;

module inset() {
    difference() {
        translate([0, 0, -dowelBackD]) cylinder(d=insetDia, h=armDep);;
        cylinder(d=dowelDia, h=50); //cutout
    }
}

module arm() {
    length = armLen+insetDia/2;
    difference() {
        translate([0, length/2, armDep/2-dowelBackD]) cube(size=[insetDia, length, armDep], center=true);
        cylinder(d=insetDia-e, h=50, center=true);
    }
}

module armLock() {
    baseTolerance = 0.5;
    scalar = 1+(dovetailTolerance/100);
    
    difference() {
        translate([baseTolerance, 0, 0]) union() {
            cube(size=[dovetailSize-dovetailCutoff+dovetailWallD-baseTolerance, dovetailSize+dovetailWallD, insetDia], center=false);
            mirror([0, 1, 0]) cube(size=[dovetailSize-dovetailCutoff+dovetailWallD-baseTolerance, dovetailSize+dovetailWallD, insetDia], center=false);
        }
        
        //Cutout to slide over the base lock
        scale([scalar, scalar, 1]) translate([dovetailSize-dovetailCutoff-e, 0, 0]) mirror([1, 0, 0]) baseLock();
        
        //Truncate the overlap a bit
        color("red") translate([0, 0, insetDia/2+e])  cube(size=[dovetailSize, dovetailSize*5/4, insetDia+2*e], center=true);
    }
    
}

module baseLock() {
    trimSize = dovetailTrim*2;
    
    difference() {
        union() {
            triangle(dovetailSize,dovetailSize,insetDia);
            mirror([0, 1, 0]) triangle(dovetailSize,dovetailSize,insetDia);
            
            //stopper
            translate([dovetailSize/2, 0, insetDia+(dovetailStopH)/2]) cube(size=[dovetailSize, dovetailSize*2, 2], center=true);
        }
        
        //dovetail cutouts
        translate([dovetailSize-dovetailCutoff, -dovetailSize-e, -e]) cube(size=[(dovetailSize+e)*2,(dovetailSize+e)*2,500]);
        
        //Flatten the dovetail edges
        translate([0, dovetailSize, insetDia/2-e]) cube(size=[trimSize, trimSize, insetDia+e], center=true);
        translate([0, -dovetailSize, insetDia/2-e]) cube(size=[trimSize, trimSize, insetDia+e], center=true);
        
        //snapping ridge
        translate([0, 0, 3.6]) rotate([90, 0, 0]) cylinder(d=stopBar*2, h=(dovetailSize)*2-trimSize-2.4, center=true);
    }
    //backing
    translate([dovetailSize-dovetailCutoff, -dovetailSize, 0]) cube(size=[lockBackD, dovetailSize*2, insetDia+dovetailStopH]);
}

module baseWithLock() {
    cube(size=[baseH, baseW, baseD], center=true); //base
    translate([-baseH/2, 0, baseD/2+dovetailSize-dovetailCutoff]) rotate([0, 90, 0]) baseLock();
}

module base() {
    difference() {
        cube(size=[baseH, baseW, baseD], center=true); //base
        translate([-baseH/2, 0, baseD/2+dovetailSize-dovetailCutoff]) rotate([0, 90, 0]) baseLock();
    }
}

module holder() {
    inset();
    arm();
    //armHook();
    translate([insetDia/2, armLen+insetDia/2+(dovetailSize-dovetailCutoff)+dovetailWallD/2, (dowelDep-dowelBackD)/2]) rotate([90, 0, -90]) armLock();
    //base();
}

module view() {
    rotate([0, 90, 0]) holder();
    
    extraLenSpace = dovetailSize-dovetailCutoff+dovetailWallD/2;
    length = armLen+(insetDia+baseD)/2+extraLenSpace;
    shiftDown = (baseH-insetDia)/2;
    rotate([0, 90, 0]) {
        translate([shiftDown, length, (dowelDep-dowelBackD)/2]) rotate([90,0,0]) {
            baseWithLock();
        }
    }
    //rotate([0, 90, 0]) baseView();
}

module printHolder() {
    rotate([0, 90, 0]) holder();
}

module printBase() {
    translate([0, baseH/2, 0]) rotate([0, 0, -90]) base();
}

//Not nearly as durable as printBase()
module printBaseWithLock() {
    translate([0, baseH/2, 0]) rotate([0, 0, -90]) baseWithLock();
}

module printBaseLock() {
    translate([50, 0, insetDia+dovetailStopH]) rotate([180, 0, 0]) baseLock();
}

//Print the lock parts separately to make sure they're going to fit
module lockTest() {
    //translate([0, 0, 0]) rotate([0, 90, 0])
    translate([0, 0, dovetailSize-dovetailCutoff+lockBackD]) rotate([0, 90, 0])  baseLock();
    translate([-10, 0, 0]) armLock();
}

//Visualize the lock part fitting together (for development)
module lockVisualizer() {
    color("red") translate([dovetailSize-dovetailCutoff-e, 0, 0]) mirror([1, 0, 0]) baseLock();
    translate([5, 0, 0]) armLock();
}

if (visualize_assembly) {
    view();
}

if (arm) {
    translate([0, 0, insetDia/2]) printHolder();
}

if (baseAndLock) {
    translate([baseW/2+armDep+10, 0, baseD/2]) printBaseWithLock();
}

if (baseWithoutLock) {
    translate([baseW/2+armDep+10, 0, baseD/2]) printBase();
}

if (lockForBase) {
    printBaseLock();
}

if (lockingTest) {
    lockTest();
}

/*
difference() {
    lockVisualizer();
    translate([0, -50/2, 0]) cube(size=[50, 50, 50], center=true);
}
*/

//translate([20, 0, 0]) baseLock();


//Copied from <MCAD/triangles.scad> to avoid potential Thingiverse Customizer issues.
/**
 * Standard right-angled triangle
 *
 * @param number  o_len  Length of the opposite side
 * @param number  a_len  Length of the adjacent side
 * @param number  depth  How wide/deep the triangle is in the 3rd dimension
 * @param boolean center Whether to center the triangle on the origin
 * @todo a better way ?
 */
module triangle(o_len, a_len, depth, center=false)
{
    centroid = center ? [-a_len/3, -o_len/3, -depth/2] : [0, 0, 0];
    translate(centroid) linear_extrude(height=depth)
    {
        polygon(points=[[0,0],[a_len,0],[0,o_len]], paths=[[0,1,2]]);
    }
}
