import picking.*;
import java.util.*;
import geomerative.*;
import java.util.Arrays;
import controlP5.*;

ControlP5 cp5;

RadioButton r;

Region ch, hn, ha, ce, pc, br; // Declare a variable of type PImage
PGraphics map;
int mapX = 350;
int mapY = 150;
List<Region> regions = new ArrayList<Region>();
List<Indicator> indicators = new ArrayList<Indicator>();
PShape square;
Table data;

float randomHue = random(0, 1);

int tX, tY = 0;


int blockW = 300;
int  blockH = 300;

PFont decimal;

int year = 2021;
String dimension = "Salud";

boolean shouldScale = true;


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
  String name;
  PGraphics treemap;
  int x, y, cont;
  int[] numbers = {0, 0, 0, 0};
  String[] indicators = {"", "", "", ""};
  

  Indicator(PGraphics treemap, int x, int y, String name) {
    this.treemap = treemap;
    this.x = x;
    this.y = y;
    this.name = name;
  }
}


void setup() {
  size(1300, 1000, P2D);
  
  decimal = createFont("Decimal-Semibold.otf",13);
  
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
    map(year, dimension, r);
  }
  
  cp5 = new ControlP5(this);
  r = cp5.addRadioButton("radioButton")
         .setPosition(400,650)
         .setSize(40,20)
         .setColorForeground(color(240))
         .setColorActive(color(255))
         .setColorLabel(color(0))
         .setItemsPerRow(5)
         .setSpacingColumn(50)
         .addItem("Educación",1)
         .addItem("Salud",2)
         .addItem("Trabajo",3)
         .addItem("Protección Social",4)
         .addItem("Vivienda y Uso de Internet",5)
         ;
     
     for(Toggle t:r.getItems()) {
       t.getCaptionLabel().setColorBackground(color(255,200));
       t.getCaptionLabel().setPadding(7,3);
       t.getCaptionLabel().setWidth(45);
       t.getCaptionLabel().setHeight(13);
     }


  
}


void radioButton(int a) {
  println("a radio Button event: "+a);
  switch(a) {
    case(1): dimension="Educación"; break;
    case(2): dimension="Salud"; break;
    case(3): dimension="Trabajo"; break;
    case(4): dimension="Protección Social"; break;
    case(5): dimension="Vivienda y Uso de Internet"; break;
  }
  
  regions = Arrays.asList(
    new Region("Chorotega", "data/regions/chorotega.svg", 50, 20)
    , new Region("Huetar Norte", "data/regions/huetar_norte.svg", 180, 36)
    , new Region("Huetar Atlántica", "data/regions/huetar_atlantica.svg", 310, 95)
    , new Region("Central", "data/regions/central.svg", 215, 145)
    , new Region("Pacífico Central", "data/regions/pacifico_central.svg", 133, 150)
    , new Region("Brunca", "data/regions/brunca.svg", 322, 250)
    );
   println(dimension);
  for (Region r : regions) {
    map(year, dimension, r);
  }
}

void draw() {
  background(255);

  drawMap();

  for (Indicator t : indicators) {
    //map.beginDraw();
    //t.treemap.fill(0);
    //t.treemap.text(t.name, blockW, blockH);
    //map.endDraw();
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
      boolean exists = false;
      for (int i = 0; i < indicators.size(); i++) {
        // If it already exists, we remove it
        if (indicators.get(i).name.equals(r.name)) {
          exists = true;
          indicators.remove(i);
          break;
        }
      }
      
      if (!exists) {
        drawTreemap(year, dimension, r);
      } 
      
      
    }
  }
}

/////////////////////////////////////////////////////////////TREEMAPS///////////////////////////////////////////////////////
void drawTreemap(int year, String dimension, Region region) {
  PGraphics t;
  t = createGraphics(300, 300);
  Indicator indi = new Indicator(t, tX, tY, region.name);
  
  
  if (tY <= 500 ) {
    tY += 300;
  } else {
    tY = 0;
    tX = 1000;
  }
  
  randomHue = random(0, 1);

   
  int cont = 0;
  for (TableRow row : data.rows()) {
    if (year == row.getInt("Año") && dimension.equals(row.getString("Dimensión"))) {
      for (int i = 0; i < row.getColumnCount(); i++) {

        if (region.name.equals(row.getColumnTitle(i))) {
          indi.numbers[cont] = row.getInt(region.name);
          indi.indicators[cont] = row.getString("Indicador");
          cont++;
        }
      }
    }
  }

  indicators.add(indi);
  makeBlock(indi, 0, 0, blockW, blockH, indi.numbers);
}

void drawRect(Indicator t, int x1, int y1, int w1, int h1, int value) {
  t.treemap.imageMode(CENTER);
  t.treemap.beginDraw();
  t.treemap.colorMode(HSB, 1.0);
  t.treemap.stroke(1);
  float hStart = randomHue - 0.1;
  float hEnd = randomHue + 0.1;
  float h = random(hStart, hEnd);
  float s = random(0.07, 0.35);
  float b = random(0.7, 0.95);
  t.treemap.fill(h, s, b);
  t.treemap.rect(x1, y1, w1, h1); //we draw a rectangle    
  t.treemap.fill(1);
  
  t.treemap.textFont(decimal);
  t.treemap.text(t.indicators[t.cont] + " (" + str(value) + ")", x1+2, y1+1,w1-w1/8,h1-h1/8);
  t.cont = t.cont + 1;
  t.treemap.endDraw();
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

  if ((diff > 0.5) && (numbers.length >= 3)) {
    return 2;
  } else {
    return 1;
  }
}

void makeBlock(Indicator t, int refX, int refY, int blockW, int blockH, int[] numbers) {
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

  if (numbersA.length >= 2) {
    makeBlock(t, xA, yA, widthA, heightA, numbersA);
  } else {
    drawRect(t, xA, yA, widthA, heightA, valueA);
  }



  if (numbersB.length >= 2) {
    makeBlock(t, xB, yB, widthB, heightB, numbersB);
  } else {
    drawRect(t, xB, yB, widthB, heightB, valueB);
  }
}
