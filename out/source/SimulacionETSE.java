/* autogenerated by Processing revision 1279 on 2022-05-02 */
import processing.core.*;
import processing.data.*;
import processing.event.*;
import processing.opengl.*;

import java.util.TreeMap;
import peasy.*;

import java.util.HashMap;
import java.util.ArrayList;
import java.io.File;
import java.io.BufferedReader;
import java.io.PrintWriter;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.IOException;

public class SimulacionETSE extends PApplet {


public class Ball extends Particle
{
  float _r;     // Radius (m)
  int _color;   // Color (RGB)


  Ball(PVector s, PVector v, float m, float r, int c) 
  {
    super(s, v, m, false);
    
    _r = r;
    _color = c;
  }
  
   public float getRadius()
  {
    return _r;
  }
  
   public void draw()
  {
    pushMatrix();
    {
       translate(_s.x, _s.y, _s.z);
       fill(_color);
       stroke(0);
       sphereDetail(20);
       sphere(_r); 
    }
    popMatrix();
  }
}
public class DampedSpring
{
  Particle _p1;   // First particle attached to the spring
  Particle _p2;   // Second particle attached to the spring

  float _Ke;   // Elastic constant (N/m) 
  float _Kd;   // Damping coefficient (kg/m)

  float _lr;   // Rest length (m)
  float _l;    // Current length (m)
  float _lMax; // Maximum allowed distance before breaking apart (m)
  float _v;    // Current rate of change of length (m/s)

  PVector _e;   // Current elongation vector (m)
  PVector _eN;  // Current normalized elongation vector (no units)
  PVector _F;   // Force applied by the spring on particle 1 (the force on particle 2 is -_F) (N)
  float _FMax;  // Maximum allowed force before breaking apart (N)

  boolean _broken;   // True when the spring is broken 
  boolean _repulsionOnly;   // True if the spring only works one way (repulsion only)


  DampedSpring(Particle p1, Particle p2, float Ke, float Kd, boolean repulsionOnly, float maxForce, float maxDist)
  {
    _p1 = p1;
    _p2 = p2;

    _Ke = Ke;
    _Kd = Kd;

    _e = PVector.sub(_p2.getPosition(), _p1.getPosition());
    _eN = _e.copy();
    _eN.normalize();

    _l = _e.mag();
    _lr = _l; 

    _FMax = maxForce;
    _lMax = maxDist;

    _v = 0.0f;
    _broken = false;
    _repulsionOnly = repulsionOnly;

    _F = new PVector(0.0f, 0.0f, 0.0f);
  }

   public Particle getParticle1()
  {
    return _p1;
  }
  
   public Particle getParticle2()
  {
    return _p2;
  }
  
   public void setRestLength(float restLength)
  {
    _lr = restLength;
  }
  
   public void update(float simStep)
  {
    /* Este método debe actualizar todas las variables de la clase 
       que cambien según avanza la simulación (_e, _l, _v, _F, etc.),
       siguiendo las ecuaciones de un muelle con amortiguamiento lineal
       entre dos partículas.
     */
     
    // Si está roto no updatea
    if (_broken) return;

    // calcular distancia entre particulas
    _e = PVector.sub(_p2.getPosition(), _p1.getPosition());
    _l = _e.mag();
    _eN = _e.copy();
    _eN.normalize();

    if (_repulsionOnly && _l > _lr) return;
    
    // calcular la fuerza de repulsion
    _F = PVector.mult(PVector.mult(_eN, _l-_lr), _Ke*_Kd);
    
    // comprobar que la distancia no es mayor que la distancia o la fuerza es mayor que la permitida
    if (_l > _lMax || _F.mag() > _FMax) breakIt();
    // print("_l: " + _l + " _lMax: " + _lMax + " _F.mag(): " + _F.mag() + " _FMax: " + _FMax+"\n");
  }

   public void applyForces()
  { 
    _p1.addExternalForce(_F);
    _p2.addExternalForce(PVector.mult(_F, -1.0f));
  }

   public boolean isBroken()
  {
    return _broken;
  }

   public void breakIt()
  {
    _broken = true;
  }

   public void fixIt()
  {
    _broken = false;
  }
}


public class DeformableSurface 
{
  float _lengthX;   // Length of the surface in X direction (m)
  float _lengthY;   // Length of the surface in Y direction (m)
  
  int _numNodesX;   // Number of nodes in X direction
  int _numNodesY;   // Number of nides in Y direction

  SpringLayout _springLayout;  // Physical layout of the springs that define the surface
  boolean _isUnbreakable;   // True if the surface cannot be broken
  int _color;   // Color (RGB)

  Particle[][] _nodes;   // Particles defining the surface
  ArrayList<DampedSpring> _springsSurface;   // Springs joining the particles
  TreeMap<String, DampedSpring> _springsCollision;   // Springs for collision handling


  DeformableSurface(float lengthX, float lengthY, int numNodesX, int numNodesY, float surfacePosZ, float nodeMass, float Ke, float Kd, float maxForce, float breakLengthFactor, SpringLayout springLayout, boolean isUnbreakable, int c)
  {
    _lengthX = lengthX;
    _lengthY = lengthY;

    _numNodesX = numNodesX;
    _numNodesY = numNodesY;
    
    _springLayout = springLayout;
    _isUnbreakable = isUnbreakable;
    _color = c;

    _nodes = new Particle[_numNodesX][_numNodesY];
    _springsSurface = new ArrayList();
    _springsCollision = new TreeMap<String, DampedSpring>();

    createNodes(surfacePosZ, nodeMass);
    createSurfaceSprings(Ke, Kd, maxForce, breakLengthFactor);
  }

   public void createNodes(float surfacePosZ, float nodeMass)
  {
    /* Este método debe dar valores al vector de nodos ('_nodes') en función del
       tamaño que tenga la malla y de las propiedades de ésta (número de nodos, 
       masa de los mismos, etc.).
     */
     
     for (int i = 0; i < _numNodesY; i++){
        for (int j = 0; j < _numNodesX; j++){
          PVector pos = new PVector(j*(_lengthX/_numNodesX)-_lengthX/2, i*(_lengthY/_numNodesY)-_lengthY/2, surfacePosZ);
          PVector vel = new PVector(0,0,0);
          Boolean clamp = (i == 0 || i == _numNodesY-1 || j == 0 || j == _numNodesX-1);
          
          _nodes[j][i] = new Particle(pos, vel, nodeMass, clamp);
       }
     }
  }

   public void createSurfaceSprings(float Ke, float Kd, float maxForce, float breakLengthFactor)
  {
    /* Este método debe añadir muelles a la lista de muelles de la malla ('_springsSurfaces')
       en función de la disposición deseada para éstos dentro de la malla, y de los parámetros
       de los muelles (Ke, Kd, etc.).
     */
     
     switch(_springLayout)
     {
       case STRUCTURAL:
         for (int i = 0; i < _numNodesY; i++){
           for (int j = 0; j < _numNodesX; j++){
             if (j < _numNodesX-1)
               _springsSurface.add(new DampedSpring(_nodes[j][i], _nodes[j+1][i], Ke, Kd, false, maxForce, breakLengthFactor));
             if (i < _numNodesY-1)
               _springsSurface.add(new DampedSpring(_nodes[j][i], _nodes[j][i+1], Ke, Kd, false, maxForce, breakLengthFactor));
           }
         }
       break;
       
       case SHEAR:
       
       break;
       
       case STRUCTURAL_AND_SHEAR:
       
       break;
       
       case STRUCTURAL_AND_BEND:
       
       break;
       
       case STRUCTURAL_AND_SHEAR_AND_BEND:
       
       break;
     }
  }

   public void update(float simStep)
  {
    int i, j;

    for (i = 0; i < _numNodesX; i++)
      for (j = 0; j < _numNodesY; j++)
        if (_nodes[i][j] != null)
          _nodes[i][j].update(simStep);

    for (DampedSpring s : _springsSurface) 
    {
      s.update(simStep);
      s.applyForces();
    }

    for (DampedSpring s : _springsCollision.values()) 
    {
      s.update(simStep);
      s.applyForces();
    }
  }

   public void avoidCollision(Ball b, float Ke, float Kd, float maxForce, float breakLengthFactor)
  {
    /* Este método debe evitar la colisión entre la esfera y la malla deformable. Para ello
       se deben crear muelles de colisión cuando se detecte una colisión. Estos muelles
       se almacenarán en el diccionario '_springsCollision'. Para evitar que se creen muelles 
       duplicados, el diccionario permite comprobar si un muelle ya existe previamente y 
       así usarlo en lugar de crear uno nuevo.
     */

     // colision con la pelota

     for (int i = 0; i < _numNodesY; i++){
       for (int j = 0; j < _numNodesX; j++){
         // si la distancia con la bola es suficiente que se cree un muelle
         if (_nodes[j][i].getPosition().dist(_ball.getPosition()) < _ball.getRadius())
         {
           if (!_springsCollision.containsKey(_nodes[j][i].getId()+";")){
             _springsCollision.put(_nodes[j][i].getId()+";", new DampedSpring(_ball, _nodes[j][i], Ke, Kd, true, maxForce, breakLengthFactor));
              print("se crea muelle");
           }
         }
         else {
           _springsCollision.remove(_nodes[j][i].getId()+";");
         }
       }
     }
  }
 
   public void draw()
  {
    if (_isUnbreakable) 
        drawWithQuads();
    else
        drawWithSegments();
  }
 
   public void drawWithQuads()
  {
    int i, j;
    
    fill(255);
    stroke(_color);
 
    for (j = 0; j < _numNodesY - 1; j++)
    {
      beginShape(QUAD_STRIP);
      for (i = 0; i < _numNodesX; i++)
      {
        if ((_nodes[i][j] != null) && (_nodes[i][j] != null))
        {
          PVector pos1 = _nodes[i][j].getPosition();
          PVector pos2 = _nodes[i][j].getPosition();
 
          vertex(pos1.x, pos1.y, pos1.z);
          vertex(pos2.x, pos2.y, pos2.z);
        }
      }
      endShape();
    }
  }
 
   public void drawWithSegments()
  {
    stroke(_color);
 
    for (DampedSpring s : _springsSurface) 
    {
      if (!s.isBroken())
      {
        PVector pos1 = s.getParticle1().getPosition();
        PVector pos2 = s.getParticle2().getPosition();
 
        line(pos1.x, pos1.y, pos1.z, pos2.x, pos2.y, pos2.z);
      }
    }
  }
}
// Use PeasyCam for 3D rendering //<>//



// Spring Layout
enum SpringLayout 
{
  STRUCTURAL, 
  SHEAR, 
  STRUCTURAL_AND_SHEAR, 
  STRUCTURAL_AND_BEND, 
  STRUCTURAL_AND_SHEAR_AND_BEND
}


// Simulation values:

final boolean REAL_TIME = true;
final float TIME_ACCEL = 1.0f;   // To simulate faster (or slower) than real-time
float SIM_STEP = 0.001f;   // Simulation time-step (s)


// Problem parameters:

final PVector G = new PVector(0.0f, 0.0f, -9.81f);   // Acceleration due to gravity (m/(s*s))

final float NET_LENGTH_X = 600.0f;    // Length of the net in the X direction (m)
final float NET_LENGTH_Y = 400.0f;    // Length of the net in the Y direction (m)
final float NET_POS_Z = -500.0f;   // Position of the net in the Z axis (m)
final int NET_NUMBER_OF_NODES_X = 60;   // Number of nodes of the net in the X direction
final int NET_NUMBER_OF_NODES_Y = 40;   // Number of nodes of the net in the Y direction
final float NET_NODE_MASS = 0.1f;   // Mass of the nodes of the net (kg)

final float NET_KE = 150.0f;   // Ellastic constant of the net's springs (N/m) 
final float NET_KD = 5.0f;   // Damping constant of the net's springs (kg/m)
final float NET_MAX_FORCE = 1000.0f;   // Maximum force allowed for the net's springs (N)
final float NET_BREAK_LENGTH_FACTOR = 15.0f;   // Maximum distance factor (measured in number of times the rest length) allowed for the net's springs

boolean NET_IS_UNBREAKABLE = false;   // True if the net cannot be broken
SpringLayout NET_SPRING_LAYOUT;   // Current spring layout

final PVector BALL_START_POS = new PVector(0.0f, 0.0f, -200.0f);   // Initial position of the sphere (m)
PVector BALL_START_VEL = new PVector(0.0f, 0.0f, -100.0f);   // Initial velocity of the sphere (m/s)
final float BALL_MASS = 100;   // Mass of the sphere (kg)
final float BALL_RADIUS = 50.0f;   // Radius of the sphere (m)

final float COLLISION_KE = 150.0f;   // Ellastic constant of the collision springs (N/m) 
final float COLLISION_KD = 5;   // Damping constant of the net's springs (kg/m)
final float COLLISION_MAX_FORCE = 1500.0f;   // Maximum force allowed for the collision springs (N)
final float COLLISION_BREAK_LENGTH_FACTOR = BALL_RADIUS;   // Maximum distance factor (measured in number of times the rest length) allowed for the collision springs


// Display stuff:

final boolean FULL_SCREEN = false;
final int DRAW_FREQ = 50;   // Draw frequency (Hz or Frame-per-second)
int DISPLAY_SIZE_X = 1000;   // Display width (pixels)
int DISPLAY_SIZE_Y = 1000;   // Display height (pixels)

final float FOV = 60;   // Field of view (º)
final float NEAR = 0.01f;   // Camera near distance (m)
final float FAR = 100000.0f;   // Camera far distance (m)

final int BACKGROUND_COLOR = color(220, 240, 220);   // Background color (RGB)
final int NET_COLOR = color(0, 0, 0);   // Net lines color (RGB)
final int BALL_COLOR = color(250, 0, 0);   // Ball color (RGB)

PeasyCam _camera;   // mouse-driven 3D camera


// Time control:

int _lastTimeDraw = 0;   // Last measure of time in draw() function (ms)
float _deltaTimeDraw = 0.0f;   // Time between draw() calls (s)
float _simTime = 0.0f;   // Simulated time (s)
float _elapsedTime = 0.0f;   // Elapsed (real) time (s)


// Simulated entities:

Ball _ball;   // Sphere
DeformableSurface _net;   // Deformable mesh

// Main code:

 public void initSimulation(SpringLayout springLayout)
{
  _simTime = 0.0f;
  _elapsedTime = 0.0f;
  NET_SPRING_LAYOUT = springLayout;

  _net = new DeformableSurface(NET_LENGTH_X, NET_LENGTH_Y, NET_NUMBER_OF_NODES_X, NET_NUMBER_OF_NODES_Y, NET_POS_Z, NET_NODE_MASS, NET_KE, NET_KD, NET_MAX_FORCE, NET_BREAK_LENGTH_FACTOR, NET_SPRING_LAYOUT, NET_IS_UNBREAKABLE, NET_COLOR);
  _ball = new Ball(BALL_START_POS, BALL_START_VEL, BALL_MASS, BALL_RADIUS, BALL_COLOR);
}

 public void resetBall()
{
  _ball.setPosition(BALL_START_POS);
  _ball.setVelocity(BALL_START_VEL);
}

 public void updateSimulation()
{
  _ball.update(SIM_STEP);
  _net.avoidCollision(_ball, COLLISION_KE, COLLISION_KD, COLLISION_MAX_FORCE, COLLISION_BREAK_LENGTH_FACTOR);
  _net.update(SIM_STEP);

  _simTime += SIM_STEP;
}

 public void settings()
{
  if (FULL_SCREEN)
  {
    fullScreen(P3D);
    DISPLAY_SIZE_X = displayWidth;
    DISPLAY_SIZE_Y = displayHeight;
  } 
  else
  {
    size(DISPLAY_SIZE_X, DISPLAY_SIZE_Y, P3D);
  }
}

 public void setup()
{
  frameRate(DRAW_FREQ);
  _lastTimeDraw = millis();
  SIM_STEP *= TIME_ACCEL;
  
  float aspect = PApplet.parseFloat(DISPLAY_SIZE_X)/PApplet.parseFloat(DISPLAY_SIZE_Y);  
  perspective((FOV*PI)/180, aspect, NEAR, FAR);
  _camera = new PeasyCam(this, 0);

  initSimulation(SpringLayout.STRUCTURAL);
}

 public void printInfo()
{
  pushMatrix();
  {
    camera();
    fill(0);
    textSize(20);
    
    text("Frame rate = " + 1.0f/_deltaTimeDraw + " fps", width*0.025f, height*0.05f);
    text("Elapsed time = " + _elapsedTime + " s", width*0.025f, height*0.075f);
    text("Simulated time = " + _simTime + " s ", width*0.025f, height*0.1f);
    text("Spring layout = " + NET_SPRING_LAYOUT, width*0.025f, height*0.125f);
    text("Ball start velocity = " + BALL_START_VEL + " m/s", width*0.025f, height*0.15f);

    if (NET_IS_UNBREAKABLE)
      text("Net is unbreakable", width*0.025f, height*0.175f);
    else   
      text("Net is breakable", width*0.025f, height*0.175f);
  }
  popMatrix();
}

 public void drawStaticEnvironment()
{
  fill(255, 255, 255);
  sphere(1.0f);

  fill(255, 0, 0);
  box(200.0f, 0.25f, 0.25f);

  fill(0, 255, 0);
  box(0.25f, 200.0f, 0.25f);

  fill(0, 0, 255);
  box(0.25f, 0.25f, 200.0f);
}

 public void drawDynamicEnvironment()
{
  _net.draw();
  _ball.draw();
}

 public void draw()
{
  int now = millis();
  _deltaTimeDraw = (now - _lastTimeDraw)/1000.0f;
  _elapsedTime += _deltaTimeDraw;
  _lastTimeDraw = now;

  //println("\nDraw step = " + _deltaTimeDraw + " s - " + 1.0/_deltaTimeDraw + " Hz");

  background(BACKGROUND_COLOR);
  //drawStaticEnvironment();
  drawDynamicEnvironment();

  if (REAL_TIME)
  {
    float expectedSimulatedTime = TIME_ACCEL*_deltaTimeDraw;
    float expectedIterations = expectedSimulatedTime/SIM_STEP;
    int iterations = 0; 

    for (; iterations < floor(expectedIterations); iterations++)
      updateSimulation();

    if ((expectedIterations - iterations) > random(0.0f, 1.0f))
    {
      updateSimulation();
      iterations++;
    }

    //println("Expected Simulated Time: " + expectedSimulatedTime);
    //println("Expected Iterations: " + expectedIterations);
    //println("Iterations: " + iterations);
  } 
  else
    updateSimulation();

  printInfo();
}

 public void keyPressed()
{
  if (key == '1')
    initSimulation(SpringLayout.STRUCTURAL);

  if (key == '2')
    initSimulation(SpringLayout.SHEAR);

  if (key == '3')
    initSimulation(SpringLayout.STRUCTURAL_AND_SHEAR);

  if (key == '4')
    initSimulation(SpringLayout.STRUCTURAL_AND_BEND);    

  if (key == '5')
    initSimulation(SpringLayout.STRUCTURAL_AND_SHEAR_AND_BEND);  
  
  if (key == 'r')
    resetBall();

  if (keyCode == UP)
    BALL_START_VEL.mult(1.05f);

  if (keyCode == DOWN)
    BALL_START_VEL.div(1.05f);
    
  if (key == 'B' || key == 'b')
  {
    NET_IS_UNBREAKABLE = !NET_IS_UNBREAKABLE;
    initSimulation(NET_SPRING_LAYOUT);
  }
  
  if (key == 'I' || key == 'i')
    initSimulation(NET_SPRING_LAYOUT);
}
static int _lastParticleId = 0;

public class Particle 
{
  int _id;    // Unique id for each particle
  
  PVector _s;   // Position (m)
  PVector _v;   // Velocity (m/s)
  PVector _a;   // Acceleration (m/(s*s))
  PVector _F;   // Force (N)
  float _m;     // Mass (kg)
  boolean _clamped;   // If true, the particle will not move


  Particle(PVector s, PVector v, float m, boolean clamped) 
  {
    _id = _lastParticleId++;
    
    _s = s.copy();
    _v = v.copy();
    _m = m;
    _clamped = clamped;
    
    _a = new PVector(0.0f, 0.0f, 0.0f);
    _F = new PVector(0.0f, 0.0f, 0.0f);
  }

   public void update(float simStep) 
  {
    if (_clamped)
      return;

    updateForce();

    // Simplectic Euler:
    // v(t+h) = v(t) + h*a(s(t),v(t))
    // s(t+h) = s(t) + h*v(t+h)

    _a = PVector.div(_F, _m);
    _v.add(PVector.mult(_a, simStep));  
    _s.add(PVector.mult(_v, simStep));  

    _F.set(0.0f, 0.0f, 0.0f);
  }
  
   public int getId()
  {
    return _id;
  }
  
   public PVector getPosition()
  {
    return _s;
  }
  
   public void setPosition(PVector s)
  {
    _s = s.copy();
    _a.set(0.0f,0.0f,0.0f);
    _F.set(0.0f,0.0f,0.0f);
  }
  
   public void setVelocity(PVector v)
  {
    _v = v.copy();
  }

   public void updateForce()
  {
    PVector weigthForce = PVector.mult(G, _m);
    _F.add(weigthForce);
  }
  
   public void addExternalForce(PVector F)
  {
    _F.add(F);
  }
}


  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "SimulacionETSE" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
