import picking.*;
import java.util.*;
import geomerative.*;
import java.util.Arrays;

Region ch, hn, ha, ce, pc, br; // Declare a variable of type PImage
PGraphics map;
int mapX = 200;
int mapY = 150;
List<Region> regions = new ArrayList<Region>();
List<Indicator> indicators = new ArrayList<Indicator>();
PShape square;
Table data;

float randomHue = random(0, 1); //color matching... the key to everything!
float totalValue = 0; //the total values of all elements together, just to write % on square.

class Region {
  RShape shape;
  int x, y;
  String name;
  boolean focus;
  int R, G, B;

  Region(String name, String path, int x, int y) {
    this.name = name;
    shape = RG.loadShape(path);
    RG.centerIn(shape, g);
    this.x = x;
    this.y = y;
  }
}

class Indicator {
  PGraphics treemap;
  int x, y;

  Indicator(PGraphics treemap, int x, int y) {
    this.treemap = treemap;
    this.x = x;
    this.y = y;
  }
}


void setup() {
  size(1000, 800, P2D);
 
  
  data = loadTable("data/pobreza_multidimensional.csv", "header");



  RG.init(this);
  RG.ignoreStyles(true);
  RG.setPolygonizer(RG.ADAPTATIVE);

  regions = Arrays.asList(
    new Region("Chorotega", "data/regions/chorotega.svg", 50, 20)
    , new Region("Huetar Norte", "data/regions/huetar_norte.svg", 180, 36)
    , new Region("Huetar Atlántica", "data/regions/huetar_atlantica.svg", 310, 95)
    , new Region("Central", "data/regions/central.svg", 215, 145)
    , new Region("Pacífico Central", "data/regions/pacifico_central.svg", 133, 150)
    , new Region("Brunca", "data/regions/brunca.svg", 322, 250)
    );
    
  map = createGraphics(600, 450);
  
  
  //noLoop();
  smooth();

  // Map the first dimension
  for (Region r : regions) {
    map(2021, "Educación", r);
  }


  
}

void draw() {
  //background(255);

  drawMap();

  for (Indicator t : indicators) {
    image(t.treemap, t.x, t.y);
  }
  
  
}



void map(int year, String dimension, Region region) {
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
  int[] max = {0, 0, 0, 0, 0, 0};
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
    map.fill(255-r.R, 255-r.G, 255);
    map.translate(r.x, r.y);
    r.shape.draw(map);
    RPoint p = new RPoint(mouseX - mapX - r.x, mouseY - mapY - r.y);
    if (r.shape.contains(p)) {
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
      drawTreemap(2019, "Educación", r);
      
      
      print(r.name);
    }
  }
}

/////////////////////////////////////////////////////////////TREEMAPS///////////////////////////////////////////////////////
void drawTreemap(int year, String dimension, Region region) {
  PGraphics t;
  t = createGraphics(300, 300);
  indicators.add(new Indicator(t, region.x, region.y));
  
  randomHue = random(0, 1);

  int[] numbers = {0, 0, 0, 0}; 
  int cont = 0;
  for (TableRow row : data.rows()) {
    if (year == row.getInt("Año") && dimension.equals(row.getString("Dimensión"))) {
      for (int i = 0; i < row.getColumnCount(); i++) {

        if (region.name.equals(row.getColumnTitle(i))) {
          numbers[cont] = row.getInt(region.name);
          cont++;
        }
      }
    }
  }
  
  println(numbers);


  int blockW = 200;
  int  blockH = 200; 
  int  refX = 0;
  int  refY = 0;

  makeBlock(t, 0, 0, blockW, blockH, numbers);
}

void drawRect(PGraphics t, int x1, int y1, int w1, int h1, int value) {
  t.imageMode(CENTER);
  t.beginDraw();
  t.colorMode(HSB, 1.0);
  t.stroke(1);
  float hStart = randomHue - 0.1;
  float hEnd = randomHue + 0.1;
  float h = random(hStart, hEnd);
  float s = random(0.07, 0.35);
  float b = random(0.7, 0.95);
  t.fill(h, s, b);
  t.rect(x1, y1, w1, h1); //we draw a rectangle    
  t.fill(1);
  //  text(str(value), x1+6, y1+20);  (we don't care about the actual value now that we have the pcnt...)
  String myPcntStr ;
  int myPcnt = int(round ((value / totalValue) *100)) ;

  float myPcntDecimal = int(round ((value / totalValue) *1000)) ;
  myPcntDecimal = myPcntDecimal/10;
  //myPcnt = floor (myPcnt);

  if (myPcntDecimal > 10) { //bigger than 10%, we round it up.
    myPcntStr = str(myPcnt) + "%";
  } else {
    myPcntStr = str (myPcntDecimal) + "%";
  }
  t.text(myPcntStr, x1+(w1/2)-10, y1+(h1/2)+5);
  t.endDraw();
  //image(t, 0, 0);
}

int getPerfectSplitNumber(int[] numbers, int blockW, int blockH) {
  int valueA = numbers[0];//our biggest value
  int valueB = 0;//value B will correspond to the sum of all remmaining objects in array
  for ( int i=1; i < numbers.length; i++ ) {
    valueB += numbers[i];
  }

  float ratio = float(valueA) / float(valueB + valueA);

  int heightA, widthA;
  if (blockW >= blockH) {
    heightA = blockH;
    widthA  = floor(blockW * ratio);
  } else {
    heightA = floor(blockH * ratio);
    widthA  = blockW;
  }

  float ratioWH = float(widthA) / float(heightA) ;
  float ratioHW = float(heightA) / float(widthA);
  float diff;

  if (widthA >= heightA) {// Larger rect //ratio = largeur sur hauteur,
    //we should spit vertically...
    diff = 1 - ratioHW ;
  } else {//taller rectangle ratio
    diff = 1- ratioWH;
  }

  if ((diff > 0.5) && (numbers.length >= 3)) { //this is a bit elongated (bigger than 2:1 ratio)
    return 2; //TEMPORARY !!!!
  } else { //it's a quite good ratio! we don't touch it OR, it's the last one, sorry, no choice.   
    return 1;
  }
}

void makeBlock(PGraphics t, int refX, int refY, int blockW, int blockH, int[] numbers) {
  numbers = reverse(sort(numbers));

  int nbItemsInABlock= getPerfectSplitNumber(numbers, blockW, blockH);


  int valueA = 0;
  int valueB = 0;
  int[] numbersA = { };
  int[] numbersB = { }; 

  for ( int i=0; i < numbers.length; i++ ) {
    if (i < nbItemsInABlock) {
      numbersA = append(numbersA, numbers[i]);
      valueA += numbers[i];
    } else {
      numbersB = append(numbersB, numbers[i]);
      valueB += numbers[i];
    }
  }
  float ratio = float(valueA) / float(valueB + valueA);

  int xA, yA, heightA, widthA, xB, yB, heightB, widthB;
  if (blockW > blockH) {

    xA = refX;
    yA = refY;
    heightA = blockH;
    widthA  = floor(blockW * ratio);

    xB = refX + widthA;
    yB = refY;
    heightB = blockH;
    widthB = blockW - widthA;
  } else {
    xA = refX;
    yA = refY;
    heightA = floor(blockH * ratio);
    widthA  = blockW;

    xB = refX;
    yB = refY+ heightA;
    heightB = blockH - heightA;
    widthB = blockW;
  }

  if (numbersA.length >= 2) {//this mean there is still stuff in this arary...
    makeBlock(t, xA, yA, widthA, heightA, numbersA);
  } else {
    drawRect(t, xA, yA, widthA, heightA, valueA);
  }



  if (numbersB.length >= 2) {//this mean there is still stuff in this arary...
    makeBlock(t, xB, yB, widthB, heightB, numbersB);
  } else {
    drawRect(t, xB, yB, widthB, heightB, valueB);
  }
}
