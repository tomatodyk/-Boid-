class Boid {
  PVector loc;
  PVector vel;
  PVector acc;
  int mass;
  int maxForce = 8;
  float r, g, b;
  Boid(PVector location) {
    loc = location;
    vel = new PVector();
    acc = new PVector();
    mass = int (random(5, 10));
    r=random(1);
    g=random(1);
    b=random(1);
  }
  void flockForce(ArrayList<Boid>boids) {
    avoidForce(boids);
    approachForce(boids);
    alignForce(boids);
  }

  void update() {



    vel.add(acc);
    loc.add(vel);
    acc.mult(0);
    vel.limit(3);
    if (loc.x<=0) {
      loc.x = width;
    }
    if (loc.x>width) {
      loc.x = 0;
    }
    if (loc.y<=0) {
      loc.y = height;
    }
    if (loc.y>height) {
      loc.y=0;
    }
  }
  void applyF(PVector force) {
    force.div(mass);
    acc.add(force);
  }

  void display(boolean circle, boolean arrow) {
    update();
    fill(0, 0);
    stroke(0);
    if (circle) {
      //ellipse(loc.x,loc.y,mass,mass);
    }
    if (arrow) {
      // line(loc.x,loc.y,loc.x+3*vel.x,loc.y+3*vel.y);
      // pushMatrix();
      // translate(loc.x+3*vel.x,loc.y+3*vel.y);
      // rotate(vel.heading());
      // line(0,0,-5,-5);
      // line(0,0,-5,5);
      // popMatrix();
    }
  }
  void displayCircle() {
    ellipse(loc.x, loc.y, mass, mass);
  }
  void displayArrow() {
    line(loc.x, loc.y, loc.x+3*vel.x, loc.y+3*vel.y);

    pushMatrix();
    translate(loc.x+3*vel.x, loc.y+3*vel.y);
    rotate(vel.heading());
    line(0, 0, -5, -5);
    line(0, 0, -5, 5);
    popMatrix();
  }
  void avoidForce(ArrayList<Boid>boids) {
    float count =0;
    PVector locSum =new PVector();

    for (Boid other : boids) {
      int separation =mass+20;
      PVector dist = PVector.sub(other.getLoc(), loc);
      float d = dist.mag();

      if (d!=0&&d<separation) {
        PVector otherLoc = other.getLoc();
        locSum.add(otherLoc);
        count++;
      }
    }
    if (count>0) {
      locSum.div(count);
      PVector avoidVec = PVector.sub(loc, locSum);
      avoidVec.limit(maxForce*2.5);
      applyF(avoidVec);
    }
  }
  void approachForce(ArrayList<Boid>boids) {
    float count =0;
    PVector locSum =new PVector();

    for (Boid other : boids) {
      int approachRadius =mass+60;
      PVector dist = PVector.sub(other.getLoc(), loc);
      float d = dist.mag();

      if (d!=0&&d<approachRadius) {
        PVector otherLoc = other.getLoc();
        locSum.add(otherLoc);
        count++;
      }
    }
    if (count>0) {
      locSum.div(count);
      PVector approachVec = PVector.sub(locSum, loc);
      approachVec.limit(maxForce);
      applyF(approachVec);
    }
  }
  void alignForce(ArrayList<Boid>boids) {
    float count =0;
    PVector velSum =new PVector();

    for (Boid other : boids) {
      int alignRadius =mass+100;
      PVector dist = PVector.sub(other.getLoc(), loc);
      float d = dist.mag();

      if (d!=0&&d<alignRadius) {
        PVector otherVel = other.getVel();
        velSum.add(otherVel);
        count++;
      }
    }
    if (count>0) {
      velSum.div(count);
      PVector alignVec = velSum;
      alignVec.limit(maxForce);
      applyF(alignVec);
    }
  }

  void repelForce(PVector obstacle, float radius) {
    PVector futPos =PVector.add(loc, vel);
    PVector dist =PVector.sub(obstacle, futPos);
    float d= dist.mag();
    if (d<=radius) {
      PVector repelVec=PVector.sub(loc, obstacle);
      repelVec.normalize();
      if (d!=0) {
        float scale = 1.0/d;
        repelVec.normalize();
        repelVec.mult(maxForce*7);
        if (repelVec.mag()<0) {
          repelVec.y=0;
        }
      }
      applyF(repelVec);
    }
  }
  PVector getLoc() {
    return loc;
  }
  PVector getVel() {
    return vel;
  }
}
class Predator extends Boid {
  float maxForce = 10;
  float r1, g1, b1;
  Predator(PVector location, int scope) {
    super(location);
    mass=int(random(8, 15));
    r1=random(1);
    g1=random(1);
    b1=random(1);
  }
  void display() {
    update();
    fill(255, 140, 130);
    noStroke();
  }
  void update() {
    vel.add(acc);
    loc.add(vel);
    acc.mult(0);
    vel.limit(6);
    if (loc.x<=0) {
      loc.x = width;
    }
    if (loc.x>width) {
      loc.x = 0;
    }
    if (loc.y<=0) {
      loc.y = height;
    }
    if (loc.y>height) {
      loc.y=0;
    }
  }
  void approachForce(ArrayList<Boid>boids) {
    float count =0;
    PVector locSum =new PVector();

    for (Boid other : boids) {
      int approachRadius =mass+20;
      PVector dist = PVector.sub(other.getLoc(), loc);
      float d = dist.mag();

      if (d!=0&&d<approachRadius) {
        PVector otherLoc = other.getLoc();
        locSum.add(otherLoc);
        count++;
      }
    }
    if (count>0) {
      locSum.div(count);
      PVector approachVec = PVector.sub(locSum, loc);
      approachVec.limit(maxForce);
      applyF(approachVec);
    }
  }
}
