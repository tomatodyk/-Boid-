import com.thomasdiewald.pixelflow.java.DwPixelFlow;
import com.thomasdiewald.pixelflow.java.fluid.DwFluid2D;

import processing.core.*;
import processing.opengl.PGraphics2D;

import ddf.minim.*;
Minim minim;
AudioPlayer player;
PImage img;
DwFluid2D fluid;
PGraphics2D pg_fluid;
float theta, step;  
int num=5, frames = 1200;  
Layer[] layers = new Layer[num];  //
ArrayList<Boid>boids = new ArrayList<Boid>();
ArrayList<Predator>preds = new ArrayList<Predator>();
int boidNum = 120 ;
int predNum=5;
PVector mouse;
float obstRad = 60;
int boolT = 0;
boolean flocking =true;
boolean arrow =true;
boolean circle=false;
boolean predBool = true;
boolean obsBool =false;


public void settings() {
  size(1080, 720, P2D);
}

public void setup() {
  background(#ffffff); 
  img=loadImage("1.jpg");

  minim = new Minim(this);
  player=minim.loadFile("2.mp3");
  player.play();
  for (int i=0; i<num; i++) {  
    layers[i] = new Layer(-20+i*step, random(1000), i+1);
  }
  for (int i=0; i<boidNum; i++) {
    boids.add(new Boid(new PVector(random(0, width), random(0, height))));
  }
  for (int j=0; j<predNum; j++) {
    preds.add(new Predator(new PVector(random(0, width), random(0, height)), 50));
  }

  // library context
  DwPixelFlow context = new DwPixelFlow(this);
  context.print();
  context.printGL();

  // 
  fluid = new DwFluid2D(context, width, height, 1);

  // some fluid parameters
  fluid.param.dissipation_velocity = 0.90f;
  fluid.param.dissipation_density  = 0.39f;

  // adding data to the fluid simulation
  fluid.addCallback_FluiData(new  DwFluid2D.FluidData() {
    public void update(DwFluid2D fluid) {
      for (Boid boid : boids) {
        float px     = boid.loc.x;
        float py     = height-boid.loc.y;
        float vx     = (boid.vel.x) * +15;
        float vy     = (boid.vel.y) * -15;
        fluid.addVelocity(px, py, 14, vx, vy);//boid.r, boid.g, boid.b
        fluid.addDensity (px, py, 10, boid.r, boid.g, boid.b, 1.0f);
        // boid.display(circle,arrow);
      }
      for (Predator pred : preds) {
        float px     = pred.loc.x;
        float py     = height-pred.loc.y;
        float vx     = (pred.vel.x) * +15;
        float vy     = (pred.vel.y) * -15;//pred.r1, pred.g1, pred.b1
        fluid.addVelocity(px, py, 14, vx, vy);
        fluid.addDensity (px, py, 20, pred.r1, pred.g1, pred.b1, 1.0f);
        //pred.display();
      }
    }
  }
  );

  // render-target
  pg_fluid = (PGraphics2D) createGraphics(width, height, P2D);

  frameRate(60);
}


public void draw() {  
  image(img, 0, 0);

  for (Boid boid : boids) {
    if (predBool) {
      for (Predator pred : preds) {
        PVector predBoid = pred.getLoc();
        boid.repelForce(predBoid, obstRad);
      }
    }
    if (obsBool) {
      mouse =new PVector(mouseX, mouseY);
      boid.repelForce(mouse, obstRad);
    }
    if (flocking) {
      boid.flockForce(boids);
    }
    boid.display(circle, arrow);
  }
  for (Predator pred : preds) {
    if (flocking) {
      pred.flockForce(boids);
      for (Predator otherpred : preds) {
        if (otherpred.getLoc()!=pred.getLoc()) {
          pred.repelForce(otherpred.getLoc(), 30.0);
        }
      }
    }
    pred.display();
  }

  // update simulation
  fluid.update();

  // clear render target
  pg_fluid.beginDraw();
  pg_fluid.background(255);
  pg_fluid.endDraw();

  // render fluid stuff
  fluid.renderFluidTextures(pg_fluid, 0);

  // display
  image(pg_fluid, 0, 0);
}

void mousePressed()
{
  
}
