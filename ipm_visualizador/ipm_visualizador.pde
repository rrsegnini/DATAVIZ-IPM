import picking.*;
import java.util.*;
import geomerative.*;
import java.util.Arrays;

Region ch, hn, ha, ce, pc, br; // Declare a variable of type PImage
PGraphics map;
int mapX = 200;
int mapY = 150;
Picker picker;
List<Region> regions = new ArrayList<Region>();
PShape square;
Table data;

class Region {
  RShape shape;
  int x,y;
  String name;
  boolean focus;
  int R,G,B;
  
  Region(String name, String path, int x, int y) {
    this.name = name;
    shape = RG.loadShape(path);
    RG.centerIn(shape, g);
    this.x = x;
    this.y = y;
  }
}


void setup() {
  size(1000,800,P2D);
  
  data = loadTable("data/pobreza_multidimensional.csv", "header");

  
  
  RG.init(this);
  RG.ignoreStyles(true);
  RG.setPolygonizer(RG.ADAPTATIVE);
  
  
  picker = new Picker(this);
  
  regions = Arrays.asList(
                          new Region("Chorotega", "data/regions/chorotega.svg", 50,20)
                          ,new Region("Huetar Norte", "data/regions/huetar_norte.svg", 180, 36)
                          ,new Region("Huetar Atlántica", "data/regions/huetar_atlantica.svg", 310, 95)
                          ,new Region("Central", "data/regions/central.svg", 215, 145)
                          ,new Region("Pacífico Central", "data/regions/pacifico_central.svg", 133, 150)
                          ,new Region("Brunca", "data/regions/brunca.svg", 322, 250)
                          );                          
  
   
  map = createGraphics(600, 450);
   
  // Map the first dimension  
  for (Region r : regions) {
    map(2021, "Educación", r);
  }

}

void draw() {
  background(255);

  drawMap();
  


}

void map(int year, String dimension, Region region){
  int max = findMax(year, dimension);
  int dimTotal = 0;
  for (TableRow row : data.rows()) {
    if (year == row.getInt("Año") && dimension.equals(row.getString("Dimensión"))) {
      for (int i = 0; i < row.getColumnCount(); i++) {
        
        if (region.name.equals(row.getColumnTitle(i))) {
          dimTotal += row.getInt(region.name);
        }
      }
    }
  }
  // Map size
  float m = map(dimTotal, 0, max, 0, 1.5);
  // Map color
  float r = map(dimTotal, 0, max, 0, 255);
  float g = map(dimTotal, 0, max, 0, 127);
  println(dimTotal);
  region.shape.scale(m);
  region.R = int(r);
  region.G = int(g);
}

// Finds the max value for a certain year and dimension
int findMax(int year, String dimension) {
  int[] max = {0,0,0,0,0,0};
  for (TableRow row : data.rows()) {
    if (year == row.getInt("Año") && dimension.equals(row.getString("Dimensión"))) {
      
      for (int i = 0; i < 6; i++) {
        max[i] += row.getInt(row.getColumnTitle(i+4));
      }
    }
  }
  Arrays.sort(max);

  return max[max.length-1];
}



void drawMap() {
  
  map.rect(5, 5, map.width+200, map.height+5);
  map.beginDraw();
  map.stroke(0);
  map.background(240);
  for (Region r : regions) {
    map.pushMatrix();
    map.fill(255-r.R,255-r.G,255);
    map.translate(r.x,r.y);
    r.shape.draw(map);
    RPoint p = new RPoint(mouseX - mapX - r.x, mouseY - mapY - r.y);
    if(r.shape.contains(p)){       
       r.focus = true;
    } else {
      r.focus = false;
    }
    
    map.popMatrix();
   
  }
  map.endDraw();
  
  image(map, mapX, mapY);
}



void mouseClicked() {
  for (Region r : regions) {
    if (r.focus) {
      // TODO: Open TREEMAP here
      print(r.name);
    }
  }
  
}
