import picking.*;
import java.util.*;
import geomerative.*;
import java.util.Arrays;
import controlP5.*;
import javafx.util.Pair;

ControlP5 cp5;

RadioButton r, r2;

Region ch, hn, ha, ce, pc, br; // Declare a variable of type PImage
PGraphics map;
int mapX = 350;
int mapY = 150;
List<Region> regions = new ArrayList<Region>();
List<Indicator> indicators = new ArrayList<Indicator>();
Map<String, Pair<Integer, Integer>> treemapPositions = new HashMap<String, Pair<Integer, Integer>>();

PShape square;
Table data;

float randomHue = random(0, 1);

int tX = 10;
int tY = 10;


int blockW = 300;
int  blockH = 300;

PFont decimal, decimalBig;

int year = 2019;
String dimension = "Educación";

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
  int[] colors = {#0054a6, #ed145b, #ffb000, #7cc576};
  

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
  decimalBig = createFont("Decimal-Semibold.otf",25);
  
  data = loadTable("data/pobreza_multidimensional.csv", "header");
  
  treemapPositions.put("Chorotega", new Pair(10, 10));
  treemapPositions.put("Huetar Norte", new Pair(10, 330));
  treemapPositions.put("Huetar Atlántica", new Pair(10, 660));
  treemapPositions.put("Central", new Pair(1000, 10));
  treemapPositions.put("Pacífico Central", new Pair(1000, 330));
  treemapPositions.put("Brunca", new Pair(1000, 660));



  RG.init(this);
  RG.ignoreStyles(true);
  RG.setPolygonizer(RG.ADAPTATIVE);

  loadRegions();
    
  map = createGraphics(600, 450);
  
  
  //noLoop();
  smooth();

  // Map the first dimension
  for (Region r : regions) {
    map(year, dimension, r);
  }
  
  cp5 = new ControlP5(this);
  r = cp5.addRadioButton("dimensionRadio")
         .setPosition(350,650)
         .setSize(40,20)
         .setColorForeground(color(240))
         .setColorBackground(color(#3C55D7))
         .setColorActive(color(100))
         .setColorLabel(color(0))
         .setItemsPerRow(3)
         .setSpacingColumn(200)
         .addItem("Educación",1)
         .addItem("Salud",2)
         .addItem("Trabajo",3)
         .addItem("Protección Social",4)
         .addItem("Vivienda y Uso de Internet",5)
         ;
     
     for(Toggle t:r.getItems()) {
       t.getCaptionLabel().setColorBackground(color(255,200));
       t.getCaptionLabel().setFont(decimal);
       t.getCaptionLabel().setPadding(7,3);
       t.getCaptionLabel().setWidth(45);
       t.getCaptionLabel().setHeight(13);
     }
   
  r2 = cp5.addRadioButton("yearRadio")
         .setPosition(525,720)
         .setSize(40,20)
         .setColorForeground(color(240))
         .setColorBackground(color(#3C55D7))
         .setColorActive(color(100))
         .setColorLabel(color(0))
         .setItemsPerRow(5)
         .setSpacingColumn(50)
         .addItem("2019",2019)
         .addItem("2020",2020)
         .addItem("2021",2021)
         ;
     
     for(Toggle t:r2.getItems()) {
       t.getCaptionLabel().setColorBackground(color(255,200));
       t.getCaptionLabel().setFont(decimal);
       t.getCaptionLabel().setPadding(7,3);
       t.getCaptionLabel().setWidth(45);
       t.getCaptionLabel().setHeight(13);
     }

  
}

void draw() {
  background(255);

  drawMap();

  for (Indicator t : indicators) {
    image(t.treemap, treemapPositions.get(t.name).getKey(), treemapPositions.get(t.name).getValue());
  }
  
  
  textFont(decimalBig);
  textAlign(CENTER);
  fill(0);
  text("Hogares pobres con privación en " + dimension +" según el Índice de Pobreza Multidimensional (" + year + ")", 400, 40, 500, 200);
  
}

void loadRegions() {
  regions = Arrays.asList(
      new Region("Chorotega", "data/regions/chorotega.svg", 50, 70)
      , new Region("Huetar Norte", "data/regions/huetar_norte.svg", 180, 36)
      , new Region("Huetar Atlántica", "data/regions/huetar_atlantica.svg", 310, 95)
      , new Region("Central", "data/regions/central.svg", 150, 145)
      , new Region("Pacífico Central", "data/regions/pacifico_central.svg", 140, 200)
      , new Region("Brunca", "data/regions/brunca.svg", 322, 300)
      );
}



void dimensionRadio(int a) {
  switch(a) {
    case(1): dimension="Educación"; break;
    case(2): dimension="Salud"; break;
    case(3): dimension="Trabajo"; break;
    case(4): dimension="Protección Social"; break;
    case(5): dimension="Vivienda y Uso de Internet"; break;
  }
  
  redrawMaps();
}

void yearRadio(int a) {
  year = a;
  redrawMaps();

}

void redrawMaps() {
  loadRegions();
  
  for (Region r : regions) {
    map(year, dimension, r);

    for (int i = 0; i < indicators.size(); i++) {
      // If it already exists, we remove it
      if (indicators.get(i).name.equals(r.name)) {
        indicators.remove(i);
        drawTreemap(year, dimension, r);
        break;
      }
    }
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
  map.background(255);
  for (Region r : regions) {
    map.pushMatrix();
    map.fill(0);
    map.textFont(decimal);
    map.text(r.name, r.x, r.y);
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


void drawTreemap(int year, String dimension, Region region) {
  PGraphics t;
  t = createGraphics(300, 312);
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
  
  t.treemap.fill(t.colors[t.cont]);
  t.treemap.rect(x1, y1, w1, h1); //we draw a rectangle    
  t.treemap.fill(1);
  
  t.treemap.textFont(decimal);
  t.treemap.text(t.indicators[t.cont] + " (" + str(value) + ")", x1+2, y1+1,w1-w1/8,h1-h1/8);
  t.cont = t.cont + 1;
  
  if (t.cont == 4) {
    t.treemap.fill(0);
    t.treemap.text(t.name, 2, 310);
  }
  t.treemap.endDraw();
}

int getPerfectSplitNumber(int[] numbers, int blockW, int blockH) {
  int valueA = numbers[0];
  int valueB = 0;
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

  if (widthA >= heightA) {
    diff = 1 - ratioHW ;
  } else {
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
