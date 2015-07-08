$fn = 100;

// set this to some multiple of your nozzle width
shellWidth = 1.2;
wallWidth = shellWidth;

clearance = 0; // changing to 0 from 0.2

// how much to leave around the cutouts. this is tricky because of the
// rounding, though, so kinda takes up the wallWidth and possibly the clearance
// too.
edge = 3.5;

// actual dimensions plus clearance
length = 138.1 + 2*clearance;
width = 67 + 2*clearance;
height = 6.9 + 2*clearance;

phoneOffset = wallWidth + clearance;

// we're trying to make it as big as the phone plus a wall all around
xscale = (length + 2*wallWidth)/length;
yscale = (width + 2*wallWidth)/width;
zscale = (height + 2*wallWidth)/height;

// I'm really not sure about these. I tried to measure it with calipers and
// work it out, but it is tricky.
cornerRadius = 9;
edgeRadius = height/2;

// just for convenience
outsideLength = length*xscale;
outsideWidth = width*yscale;
outsideHeight = height*zscale;

// the default space around the things we're cutting out space for
cutoutExtra = 1.5;

// just how deep the part is that we diff. should basically just be more than
// the wall width, helps when debugging.
cutoutDepth = 5;

speakerWidth = 12.85 + 2*cutoutExtra;
speakerHeight = 1.98 + 2*cutoutExtra;
speakerOffset = 15.72;

// keepout cone
//chargerWidth = 13.65;
//chargerHeight = 6.85;

// something a bit more sane
chargerWidth = 8.7 + 2*cutoutExtra;
chargerHeight = 6;

// keepout area
earphoneDiameter = 6.5;
earphoneOffset = 13.08;

micWidth = earphoneDiameter;
micHeight = earphoneDiameter/2;
micOffset = earphoneOffset+earphoneDiameter/2;

muteWidth = 5.61 + 2*cutoutExtra;
muteHeight = 2.8 + 2*cutoutExtra;
muteOffset = 20.3;

volumeWidth = 22.81 + 2*cutoutExtra;
volumeHeight = 2.8 + 2*cutoutExtra;
volumeOffset = 40.8;

powerWidth = 12.2 + 2*cutoutExtra;
powerHeight = 2.25 + 2*cutoutExtra;
powerOffset = 34.49;

// a three dimensional rounded rectangle
module rounded(l, w, h, r) {
  // i for inner
  il = l - 2*r;
  iw = w - 2*r;

  union() {
    translate([r, r, 0]) {
      translate([-r, 0, 0])
      cube([l, iw, h]);

      translate([0, -r, 0])
      cube([il, w, h]);

      cylinder(h=h, r=r);

      translate([il, iw, 0])
      cylinder(h=h, r=r);

      translate([0, iw, 0])
      cylinder(h=h, r=r);

      translate([il, 0, 0])
      cylinder(h=h, r=r);
    }
  }
}

module roundedSlab(l, w, h, r, e) {
  // This routine is a bit fiddly. l and w each have to be bigger than e*2 and
  // I think d has to be smaller.
  up = (e*2+0.1)/2 - h/2;
  translate([0, 0, -up])
  intersection() {
    translate([e, e, e])
    minkowski() {
      rounded(l-e*2, w-e*2, 0.1, r-e);
      sphere(e);
    }
    // cut just the phone part out
    translate([0, 0, up])
    cube([l, w, h]);
  }
}

// alternative to scaling the outside is to just make another roundedSlab, but
// that's really slow.
module shell() {
  roundedSlab(l=outsideLength, w=outsideWidth, h=outsideHeight, r=cornerRadius, e=edgeRadius);
}

module phone() {
  roundedSlab(l=length, w=width, h=height, r=cornerRadius, e=edgeRadius);
}

module bottomCutout() {
  bottomCutoutLength = length - edge*2;
  bottomCutoutWidth = width - edge*2;

  translate([edge+wallWidth, edge+wallWidth, -0.1])
  rounded(
    l=bottomCutoutLength,
    w=bottomCutoutWidth,
    h=wallWidth+1,
    r=cornerRadius-3); // why 3?
}

module innerBrim() {
  brimLength = length-edge;
  brimWidth = width-edge;

  difference() {
    translate([wallWidth+edge/2, wallWidth+edge/2, 0])
    rounded(
      l=brimLength,
      w=brimWidth,
      h=0.2,
      r=cornerRadius);

    translate([wallWidth+10, wallWidth+10, -1])
    rounded(
      l=length-20,
      w=width-20,
      h=2,
      r=cornerRadius);
  }
}

module topCutout() {
  topCutoutLength = length - edge*2;
  topCutoutWidth = width - edge*2;

  translate([edge+wallWidth, edge+wallWidth, outsideHeight-wallWidth-0.1])
  rounded(
    l=topCutoutLength,
    w=topCutoutWidth,
    h=wallWidth+1,
    r=cornerRadius-3); // why 3?
}

module earphoneCutout() {
  translate([
    0,
    outsideWidth - (earphoneOffset + phoneOffset),
    outsideHeight/2
  ])
  rotate([90, 0, 90])
  cylinder(d=earphoneDiameter, h=cutoutDepth);
}

module micCutout() {
  translate([
    0,
    outsideWidth - phoneOffset - micOffset - micWidth/2,
    outsideHeight/2 - micHeight/2
  ])
  rotate([90, 0, 90])
  rounded(micWidth, micHeight, cutoutDepth, micHeight/2);
}

module chargerCutout() {
  translate([
    0,
    outsideWidth/2 - chargerWidth/2,
    outsideHeight/2 - chargerHeight/2
  ])
  rotate([90, 0, 90])
  rounded(chargerWidth, chargerHeight, cutoutDepth, chargerHeight/2);
}

module speakerCutout() {
  translate([
    0,
    phoneOffset + speakerOffset - speakerWidth/2,
    outsideHeight/2 - speakerHeight/2
  ])
  rotate([90, 0, 90])
  rounded(speakerWidth, speakerHeight, cutoutDepth, speakerHeight/2);
}

module muteCutout() {
  translate([
    outsideLength - phoneOffset - muteWidth/2 - muteOffset,
    outsideWidth,
    outsideHeight/2 - muteHeight/2
  ])
  rotate([90, 0, 0])
  rounded(muteWidth, muteHeight, cutoutDepth, muteHeight/2);
}

module volumeCutout() {
  translate([
    outsideLength - phoneOffset - volumeWidth/2 - volumeOffset,
    outsideWidth,
    outsideHeight/2 - volumeHeight/2]
  )
  rotate([90, 0, 0])
  rounded(volumeWidth, volumeHeight, cutoutDepth, volumeHeight/2);
}

module powerCutout() {
  translate([
    outsideLength - phoneOffset - powerWidth/2 - powerOffset,
    cutoutDepth/2,
    outsideHeight/2 - powerHeight/2]
  )
  rotate([90, 0, 0])
  rounded(powerWidth, powerHeight, cutoutDepth, powerHeight/2);
}

module cover() {
  difference() {
    // make the outer shell
    //shell();
    scale([xscale, yscale, zscale])
    phone();

    // cut out the inside
    translate([wallWidth, wallWidth, wallWidth])
    phone();

    // cut out the back side
    bottomCutout();

    // cut off the part above the screen
    topCutout();

    // cut out the hole for the charger
    chargerCutout();

    // cut out the hole for the earphones
    earphoneCutout();

    // the microphone next to the headphonephone socket
    micCutout();

    // cut out the speaker grill
    speakerCutout();

    // cut out the mute switch
    muteCutout();

    // cut out the volume buttons
    volumeCutout();

    // cut out the power button
    powerCutout();
  }
  //innerBrim();
}

//rotate([0, 180, 0])
//translate([-outsideLength/2, -outsideWidth/2, -outsideHeight])
translate([-outsideLength/2, -outsideWidth/2, 0])
cover();
//phone();
