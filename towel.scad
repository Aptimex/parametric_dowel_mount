use <MCAD/triangles.scad>

$fn = 50;
e = .01;
dowelDia = 15.8; //mm, 5/8in
gripThickness = 2.4;
wallSpacing = 70;

//dowel inset
backThick = 3;
overlap = 5;
armThick = overlap+backThick;

//Arm Lock
//lockLen = 10;
//lockHoldW = 1.2;
//lockHoldD = 1.2;
lockSize = 5;
lockWallThick = 3;

//base
baseH = 80;
baseW = 25;
baseD = 2;
lockVOffset = 2;
lockCutoff = 2;

insetDia = dowelDia + (gripThickness*2);

module inset() {
    difference() {
        translate([0, 0, -backThick]) cylinder(d=insetDia, h=armThick);;
        cylinder(d=dowelDia, h=50); //cutout
    }
}

module arm() {
    length = wallSpacing+insetDia/2;
    difference() {
        translate([0, length/2, armThick/2-backThick]) cube(size=[insetDia, length, armThick], center=true);
        cylinder(d=insetDia-e, h=50, center=true);
    }
}

//Probably not the best attachment approach to use
/*
module armHook() {
    bridgeD = 5;
    bridgeH = 5;
    length = wallSpacing+(insetDia+bridgeD)/2;
    
    translate([-(insetDia-bridgeH)/2, length, armThick/2-backThick]) {
        difference() {
            cube(size=[bridgeH, bridgeD, armThick], center=true);
            translate([bridgeH/2, -bridgeD/2, 0]) cube(size=[bridgeH+e, bridgeD+e, armThick], center=true);
        }
    }
}
*/

module armLock() {
    difference() {
        union() {
            cube(size=[lockSize-lockCutoff+lockWallThick, lockSize+lockWallThick, insetDia], center=false);
            mirror([0, 1, 0]) cube(size=[lockSize-lockCutoff+lockWallThick, lockSize+lockWallThick, insetDia], center=false);
        }
        scale([1.05, 1.05, 1]) translate([lockSize-lockCutoff-e, 0, 0]) mirror([1, 0, 0]) baseLock();
    }
}

module baseLock() {
    stopThick = 2;
    
    difference() {
        union() {
            triangle(lockSize,lockSize,insetDia);
            mirror([0, 1, 0]) triangle(lockSize,lockSize,insetDia);
            
            //stopper
            translate([lockSize/2, 0, insetDia+(stopThick)/2]) cube(size=[lockSize, lockSize*2, 2], center=true);
        }
        translate([lockSize-lockCutoff, -lockSize-e, -e]) cube(size=[(lockSize+e)*2,(lockSize+e)*2,500]);
    }
}

module baseView() {
    extraLenSpace = lockSize-lockCutoff+lockWallThick/2;
    length = wallSpacing+(insetDia+baseD)/2+extraLenSpace;
    shiftDown = (baseH-insetDia)/2;
    
    translate([shiftDown, length, (overlap-backThick)/2]) rotate([90,0,0]) {
        cube(size=[baseH, baseW, baseD], center=true); //base
        translate([-baseH/2+.5, 0, baseD/2+lockSize-lockCutoff]) rotate([0, 90, 0]) baseLock();
    }
}

module base() {
    extraLenSpace = lockSize-lockCutoff+lockWallThick/2;
    length = wallSpacing+(insetDia+baseD)/2+extraLenSpace;
    shiftDown = (baseH-insetDia)/2;
    
    cube(size=[baseH, baseW, baseD], center=true); //base
    translate([-baseH/2+.5, 0, baseD/2+lockSize-lockCutoff]) rotate([0, 90, 0]) baseLock();
}

module holder() {
    inset();
    arm();
    //armHook();
    translate([insetDia/2, wallSpacing+insetDia/2+(lockSize-lockCutoff)+lockWallThick/2, (overlap-backThick)/2]) rotate([90, 0, -90]) armLock();
    //base();
}

module view() {
    rotate([0, 90, 0]) holder();
    rotate([0, 90, 0]) baseView();
}

module printHolder() {
    rotate([0, 90, 0]) holder();
}

module printBase() {
    translate([30, baseH/2, 0]) rotate([0, 0, -90]) base();
}

//view();
//printHolder();
printBase();

//translate([70, 0, 0]) base();
//translate([lockSize-lockCutoff-e, 0, 0]) mirror([1, 0, 0]) baseLock();
//armLock();

//triangle(10,5,1);
