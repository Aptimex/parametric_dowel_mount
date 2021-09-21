use <MCAD/triangles.scad>

/* [What to Print] */
//Do not print this one, for visualization purposes only
visualize_assembly = false;
arm = true;
baseAndLock = true;
//Useful if you want to print the base lock in a different orientation and attach it
baseWithoutLock = false;
//Useful if you want to print the base lock in a different orientation and attach it
lockForBase = false;
//Print the standalone lock parts to make sure they're going to fit together well
lockingTest = false;

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

/* [Lock] */
//Height of the right triangles used in the locking mechanism
lockSize = 5;
//Amount of extra wall to surround the locking mechanism
lockWallD = 3;
//How much height of the triangles to cut off for the locking mechanism. Should be about lockSize/2
lockCutoff = 2;
//Height of the stopper on locking mechanism
lockStopH = 2;
//Adjusts the PERCENTAGE (scale) tolerance between the locking pieces. Increase for looser fit.
lockTolerance = 10;
//Amount to trim the sharp dovetail edges; helps locking mechanism slide better
dovetailTrim = .8;

//Don't include things past here in customizer
module blank() {}

$fn = 50;
e = .01;
armDep = dowelDep+dowelBackD;
insetDia = dowelDia + (dowelGripD*2);
lockBackD = 1.2;

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
    scalar = 1+(lockTolerance/100);
    
    difference() {
        translate([baseTolerance, 0, 0]) union() {
            cube(size=[lockSize-lockCutoff+lockWallD-baseTolerance, lockSize+lockWallD, insetDia], center=false);
            mirror([0, 1, 0]) cube(size=[lockSize-lockCutoff+lockWallD-baseTolerance, lockSize+lockWallD, insetDia], center=false);
        }
        
        //Cutout to slide over the base lock
        scale([scalar, scalar, 1]) translate([lockSize-lockCutoff-e, 0, 0]) mirror([1, 0, 0]) baseLock();
        
        //Truncate the overlap a bit
        color("red") translate([0, 0, insetDia/2+e])  cube(size=[lockSize, lockSize*5/4, insetDia+2*e], center=true);
    }
    
}

module baseLock() {
    trimSize = dovetailTrim*2;
    
    difference() {
        union() {
            triangle(lockSize,lockSize,insetDia);
            mirror([0, 1, 0]) triangle(lockSize,lockSize,insetDia);
            
            //stopper
            translate([lockSize/2, 0, insetDia+(lockStopH)/2]) cube(size=[lockSize, lockSize*2, 2], center=true);
        }
        
        //dovetail cutouts
        translate([lockSize-lockCutoff, -lockSize-e, -e]) cube(size=[(lockSize+e)*2,(lockSize+e)*2,500]);
        
        //Flatten the dovetail edges by 0.5mm
        translate([0, lockSize, insetDia/2-e]) cube(size=[trimSize, trimSize, insetDia+e], center=true);
        translate([0, -lockSize, insetDia/2-e]) cube(size=[trimSize, trimSize, insetDia+e], center=true);
    }
    //backing
    translate([lockSize-lockCutoff, -lockSize, 0]) cube(size=[lockBackD, lockSize*2, insetDia+lockStopH]);
}

module baseWithLock() {
    cube(size=[baseH, baseW, baseD], center=true); //base
    translate([-baseH/2, 0, baseD/2+lockSize-lockCutoff]) rotate([0, 90, 0]) baseLock();
}

module base() {
    difference() {
        cube(size=[baseH, baseW, baseD], center=true); //base
        translate([-baseH/2, 0, baseD/2+lockSize-lockCutoff]) rotate([0, 90, 0]) baseLock();
    }
}

module holder() {
    inset();
    arm();
    //armHook();
    translate([insetDia/2, armLen+insetDia/2+(lockSize-lockCutoff)+lockWallD/2, (dowelDep-dowelBackD)/2]) rotate([90, 0, -90]) armLock();
    //base();
}

module view() {
    rotate([0, 90, 0]) holder();
    
    extraLenSpace = lockSize-lockCutoff+lockWallD/2;
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
    translate([30, baseH/2, 0]) rotate([0, 0, -90]) base();
}

//Not nearly as durable as printBase()
module printBaseWithLock() {
    translate([30, baseH/2, 0]) rotate([0, 0, -90]) baseWithLock();
}

module printBaseLock() {
    translate([50, 0, insetDia+lockStopH]) rotate([180, 0, 0]) baseLock();
}

//Print the lock parts separately to make sure they're going to fit
module lockTest() {
    //translate([0, 0, 0]) rotate([0, 90, 0])
    translate([0, 0, lockSize-lockCutoff+lockBackD]) rotate([0, 90, 0])  baseLock();
    translate([-10, 0, 0]) armLock();
}

//Visualize the lock part fitting together (for development)
module lockVisualizer() {
    color("red") translate([lockSize-lockCutoff-e, 0, 0]) mirror([1, 0, 0]) baseLock();
    translate([10, 0, 0]) armLock();
}

if (visualize_assembly) {
    view();
}

if (arm) {
    translate([0, 0, insetDia/2]) printHolder();
}

if (baseAndLock) {
    translate([0, 0, baseD/2]) printBaseWithLock();
}

if (baseWithoutLock) {
    translate([0, 0, baseD/2]) printBase();
}

if (lockForBase) {
    printBaseLock();
}

if (lockingTest) {
    lockTest();
}


//lockVisualizer();
