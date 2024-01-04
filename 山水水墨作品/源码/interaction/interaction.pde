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
ArrayList<Boid>boids = new ArrayList<Boid>();
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


class Boid {

  PVector position;
  PVector velocity;
  PVector acceleration;
  float r;
  float maxforce;    // Maximum steering force
  float maxspeed;    // Maximum speed
float r1, g1, b1;
  Boid(float x, float y) {
    acceleration = new PVector(0,0);
    velocity = new PVector(random(-1,1),random(-1,1));
    position = new PVector(x,y);
    r = 3.0;
    maxspeed = 3;
    maxforce = 0.05;
    r1=random(1);
    g1=random(1);
    b1=random(1);
  }

  void run(ArrayList<Boid> boids) {
    flock(boids);
    update();
   // borders();
    //render();
  }

  void applyForce(PVector force) {
    // We could add mass here if we want A = F / M
    force.div(r);
    acceleration.add(force);
  }

  // We accumulate a new acceleration each time based on three rules
  void flock(ArrayList<Boid> boids) {
    PVector sep = separate(boids);   // Separation
    PVector ali = align(boids);      // Alignment
    PVector coh = cohesion(boids);   // Cohesion
    // Arbitrarily weight these forces
    sep.mult(1.5);
    ali.mult(1.0);
    coh.mult(1.0);
    // Add the force vectors to acceleration
    applyForce(sep);
    applyForce(ali);
    applyForce(coh);
  }

  // Method to update position
  void update() {
    velocity.add(acceleration);
    velocity.limit(maxspeed);
    position.add(velocity);
    acceleration.mult(0);
  }


  PVector seek(PVector target) {
    PVector desired = PVector.sub(target,position); 
    desired.normalize();
    desired.mult(maxspeed);
    PVector steer = PVector.sub(desired,velocity);
    steer.limit(maxforce);  // Limit to maximum steering force
    return steer;
  }
  
  void render() {
    // Draw a triangle rotated in the direction of velocity
    float theta = velocity.heading2D() + radians(90);
    fill(175);
    stroke(0);
    
  }

  //void borders() {
  //  if (position.x < -r) position.x = width+r;
  //  if (position.y < -r) position.y = height+r;
  //  if (position.x > width+r) position.x = -r;
  //  if (position.y > height+r) position.y = -r;
  //}

  PVector separate (ArrayList<Boid> boids) {
    float desiredseparation = 25.0f;
    PVector steer = new PVector(0,0,0);
    int count = 0;
    // For every boid in the system, check if it's too close
    for (Boid other : boids) {
      float d = PVector.dist(position,other.position);
      // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
      if ((d > 0) && (d < desiredseparation)) {
        // Calculate vector pointing away from neighbor
        PVector diff = PVector.sub(position,other.position);
        diff.normalize();
        diff.div(d);        // Weight by distance
        steer.add(diff);
        count++;            // Keep track of how many
      }
    }
    // Average -- divide by how many
    if (count > 0) {
      steer.div((float)count);
    }

    // As long as the vector is greater than 0
    if (steer.mag() > 0) {
      // Implement Reynolds: Steering = Desired - Velocity
      steer.normalize();
      steer.mult(maxspeed);
      steer.sub(velocity);
      steer.limit(maxforce);
    }
    return steer;
  }

  PVector align (ArrayList<Boid> boids) {
    float neighbordist = 50;
    PVector sum = new PVector(0,0);
    int count = 0;
    for (Boid other : boids) {
      float d = PVector.dist(position,other.position);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.velocity);
        count++;
      }
    }
    if (count > 0) {
      sum.div((float)count);
      sum.normalize();
      sum.mult(maxspeed);
      PVector steer = PVector.sub(sum,velocity);
      steer.limit(maxforce);
      return steer;
    } else {
      return new PVector(0,0);
    }
  }

  
  PVector cohesion (ArrayList<Boid> boids) {
    float neighbordist = 50;
    PVector sum = new PVector(0,0);   // Start with empty vector to accumulate all positions
    int count = 0;
    for (Boid other : boids) {
      float d = PVector.dist(position,other.position);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.position); // Add position
        count++;
      }
    }
    if (count > 0) {
      sum.div(count);
      return seek(sum);  // Steer towards the position
    } else {
      return new PVector(0,0);
    }
  }
}

public void settings() {
  size(1080, 720, P2D);
}

void setup() {


  for (int i = 0; i < 30; i++) {
     boids.add(new Boid(random(0, width), random(0, height)));
  }
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
      for (Boid boid: boids) {
        float px     = boid.position.x;
        float py     = height-boid.position.y;
        float vx     = (boid.velocity.x) * +15;
        float vy     = (boid.velocity.y) * -15;
        fluid.addVelocity(px, py, 7, vx, vy);
        fluid.addDensity (px, py, 9, boid.r1, boid.g1, boid.b1, 1.0f);
        // boid.display(circle,arrow);
      }
    }
  });
    pg_fluid = (PGraphics2D) createGraphics(width, height, P2D);

  frameRate(30);
  }


void draw() {
  background(255);
  for (Boid b : boids) {
      b.run(boids); 
  }
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
void mouseDragged() {
   boids.add(new Boid(mouseX,mouseY));
}
