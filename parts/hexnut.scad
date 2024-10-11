module hexnut(flats=10, depth=5){
  sliceangle = 360 / 6;
  pointradius = flats / (2 * cos(sliceangle/2));
  flatoffset = flats * tan(sliceangle/2) / 2;
  union(){
    for(angle=[0:sliceangle:360]) {
      rotate(angle,[0,0,1]) linear_extrude(height=depth) polygon(points=[[0,-1],[flatoffset,flats/2],[-flatoffset,flats/2]],paths=[[0,1,2]]);
    }
  }
}
