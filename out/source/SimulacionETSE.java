/* autogenerated by Processing revision 1283 on 2022-05-01 */
import processing.core.*;
import processing.data.*;
import processing.event.*;
import processing.opengl.*;

import java.util.HashMap;
import java.util.ArrayList;
import java.io.File;
import java.io.BufferedReader;
import java.io.PrintWriter;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.IOException;


class Grid 
{
  ArrayList<ArrayList<Particle>> _cells;
  ArrayList<ArrayList<color>> _colors;
  
  int _nRows; 
  int _nCols; 
  int _numCells;
  float _cellSize;
  
  Grid(int rows, int cols) 
  {
    _cells = new ArrayList<ArrayList<Particle>>();
    _colors = new ArrayList<color>();
    
    _nRows = rows;
    _nCols = cols;
    _numCells = _nRows*_nCols;
    _cellSize = width/_nRows;
    
    for (int i = 0; i < _numCells; i++) 
    {
      ArrayList<Particle> cell = new ArrayList<Particle>();
      
      _cells.add(cell);
      _colors.add(new color(int(random(0,256)), int(random(0,256)), int(random(0,256)), 150));
    }
  }

  int getCelda(PVector pos)
  {
    int celda = 0;
    int fila = int(pos.y / _cellSize);
    int columna = int(pos.x / _cellSize);
    
    celda = fila*_nCols + columna;
    
    if (celda < 0 || celda >= grid._cells.size())
    {
      return 0;
    }
    else
      return celda;
  }
  
  void insert(Particle p, int celda){
    _cells.get(celda).add(p);
  }
  
  void restart()
  {
    for(int i = 0; i < grid._cells.size(); i++)
    {
      _cells.get(i).clear();
    }
  }
  
  void display()
  {
    strokeWeight(1);
    stroke(250);
    
    for(int i = 0; i < _nRows; i++)
    {
      line(0, i*_cellSize, width, i*_cellSize); // lineas horizontales
      line(i*_cellSize, 0, i*_cellSize, height); // lineas verticales
    }
  }

  // Gets the particles of the same cell as the particle p given and the colindant cells
  // PARAMS:
  // p: particle to get the cell of
  // 
  // RETURNS:
  // ArrayList<Particle> with the particles of the same cell as p and colindant cells
  void getParticleColliders(Particle p)
  {
    int ce
  }
}
class HashTable 
{
  ArrayList<ArrayList<Particle>> _table;
  
  int _numCells;
  float _cellSize;
  color[] _colors;
  
  HashTable(int numCells, float cellSize) 
  {
    _table = new ArrayList<ArrayList<Particle>>();
    
    _numCells = numCells; 
    _cellSize = cellSize;

    _colors = new color[_numCells];
    
    for (int i = 0; i < _numCells; i++)
    {
      ArrayList<Particle> cell = new ArrayList<Particle>();
      _table.add(cell);
      _colors[i] = color(int(random(0,256)), int(random(0,256)), int(random(0,256)), 150);
    }
  }
  
  void insertar(Particle p, int celda)
  {
    _table.get(celda).add(p);
  }
  
  void restart()
  {
    for(int i = 0; i < _table.size(); i++){
      _table.get(i).clear();
    }
  }
  
  int hash (PVector pos)
  {
    int celda = int((3 * pos.x + 5 * pos.y) % _table.size());
    return celda;
  } //<>// //<>//
}
class Particle  //<>//
{
  ParticleSystem _ps;
  int _id;

  PVector _s;
  PVector _v;
  PVector _a;
  PVector _f;
  ArrayList<PVector> _Fm; // lista de fuerzas de muelle
  
  float k = 0.5f;

  float _m;
  float _radius;
  color _color;
  
  Particle(ParticleSystem ps, int id, PVector initPos, PVector initVel, float mass, float radius) 
  {
    _ps = ps;
    _id = id;

    _s = initPos.copy();
    _v = initVel.copy();
    _a = new PVector(0.0, 0.0);
    _f = new PVector(0.0, 0.0);

    _m = mass;
    _radius = radius;
    _color = color(0, 100, 255, 150);

    // inicializamos la lista de fuerzas de muelle vacia
    _Fm = new ArrayList<PVector>();
  }

  void update() 
  {  
    updateForce();
    
    PVector a = PVector.div(_f, _m);
    _v.add(PVector.mult(a, SIM_STEP));
    _s.add(PVector.mult(_v, SIM_STEP)); 
  }

  void updateForce()
  {  
    _f = new PVector();
    
    // Fuerza del peso
    PVector Fg = PVector.mult(G, _m);
    _f.add(Fg);
    
    // Fueza rozamiento
    PVector Fr = PVector.mult(_v, -k);
    _f.add(Fr);

    // Fuerza de muelle
    for (int i = 0; i < _Fm.size(); i++)
    {
      _f.add(_Fm.get(i));
    }

    // Borramos la lista de fuerzas de muelle despues de usarlas
    _Fm.clear();
  }

  void planeCollision(ArrayList<PlaneSection> planes)
  { 
    for(int i = 0; i < planes.size(); i++)
    {
      PlaneSection p = planes.get(i);
      PVector N;
      
      if (p.isInside(_s)){
        
        // no necesitamos el lado dado que siempre estaran encerradas en la mesa
        N = p.getNormal();
        
        PVector _PB = PVector.sub(_s, p.getPoint1());
        float dist = N.dot(_PB);
        
        if (abs(dist) < _radius){
          //reposicionamos la particula
          float mover = _radius-abs(dist);
          _s.add(PVector.mult(N, mover));
          //modelo basico
          PVector delta_s = PVector.mult(N, mover);
          //se le resta en la direccion de la normal
          _s.sub(delta_s);
          
          //Respuesta a la colision
          float nv = (N.dot(_v));
          PVector Vn = PVector.mult(N, nv);
          PVector vt = PVector.sub(_v, Vn);
          //le cambiamos la direccion
          Vn.mult(-1);
          _v = PVector.add(vt, Vn);
        }
      }
    }
  } 
  
  void particleCollisionSpringModel(ArrayList<Particle> sistema)
  { 
    int total = 0;
    
    for (int i = 0 ; i < sistema.size(); i++)
    {
      // miramos que no se compare consigo misma
      if(_id != i){
        Particle p = sistema.get(i);
        PVector dist = p._s.copy();
        
        dist.sub(_s);
        float distValue = dist.mag();
        PVector normal = dist.copy();
        normal.normalize();
       
        if(distValue < _radius*2)
        {
          // collisionan --> FMuelle = -k*x 
          // k = constante de dureza del muelle
          // x = vector distancia

          PVector x = PVector.sub(p._s, _s);  // x direccion del muelle
          float xMag = _radius*2 - x.mag(); // magnitud del muelle
          x.setMag(xMag); // seteamos la magitud del muelle a x
          PVector Fm = PVector.mult(x, -k); // sacamos la fuerza del muelle

          // añadimos la fuerza al array de fuerzas de muelle
          _Fm.add(Fm);
        }
      }
    }
  }
  
  void display() 
  {
    /*** ¡¡Esta función se debe modificar si la simulación necesita conversión entre coordenadas del mundo y coordenadas de pantalla!! ***/
    
    noStroke();
    circle(_s.x, _s.y, 2.0*_radius);
  }
}
class ParticleSystem 
{
  ArrayList<Particle> _particles;
  int _n;
  int _cols;
  int _rows;
  

  ParticleSystem(int n)  
  {
    _particles = new ArrayList<Particle>();
    _n = n;
    _cols = (width-5*padding)/(r_part*2);
    _rows = n/cols;
    
    PVector Pos0 = new PVector(2.5*padding, 1.5*padding);
    PVector Vel0 = new PVector(0, 0);
    int ID = 0;
    //añadir un monton de particulas iniciales
    for (int i = 0; i < _rows; i++){      
      for(int j = 0; j < _cols ; j++){   
        PVector pos = new PVector(Pos0.x+j*r_part*2+5, Pos0.y+i*r_part*2+5);
        
        addParticle(ID, pos, Vel0, 1, r_part);
        ID++;
      }
    }

    _n = _particles.size();
  }

  void addParticle(int id, PVector initPos, PVector initVel, float mass, float radius) 
  { 
    _particles.add(new Particle(this, id, initPos, initVel, mass, radius));
  }
  
  void restart()
  {
  }
  
  int getNumParticles()
  {
    return _n;
  }
  
  ArrayList<Particle> getParticleArray()
  {
    return _particles;
  }

  void run() 
  {
    for (int i = _n - 1; i >= 0; i--) 
    {
      Particle p = _particles.get(i);
      p.update();
    }
  }
  
  void computeCollisions(ArrayList<PlaneSection> planes, boolean computeParticleCollision) 
  { 
    for(int i = 0; i < _n; i++)
    {
      Particle p = _particles.get(i);      
  
      // comprobando colisiones entre particulas
      if(computeParticleCollision)
      {
        p.particleCollisionSpringModel(_particles);
      }

      p.planeCollision(planes);
    }
  }
    
  void display() 
  {
    for (int i = _n - 1; i >= 0; i--) 
    {
      Particle p = _particles.get(i);      
      p.display();
    }    
  }
}
class PlaneSection 
{ 
  PVector _pos1;
  PVector _pos2;
  PVector _normal;
  float[] _coefs = new float[4];
  
  PVector P1;
  PVector P2;
  
  // Constructor to make a plane from two points (assuming Z = 0)
  // The two points define the edges of the finite plane section
  PlaneSection(float x1, float y1, float x2, float y2, boolean invert) 
  {
    _pos1 = new PVector(x1, y1);
    _pos2 = new PVector(x2, y2);
    
    setCoefficients();
    calculateNormal(invert);
    
    P1 = new PVector(0,0);
    P2 = new PVector(0,0);

    // P1.y = (A.y >= B.y) ? A.y : B.y;
    // P1.x = (A.x <= B.x) ? A.x : B.x;

    if (_pos1.y <= _pos2.y){
      P1.y = _pos1.y;
      P2.y = _pos2.y;
    } else {
      P1.y = _pos2.y;
      P2.y = _pos1.y;
    }

    if (_pos1.x <= _pos2.x){
      P1.x = _pos1.x;
      P2.x = _pos2.x;
    } else {
      P1.x = _pos2.x;
      P2.x = _pos1.x;
    }
  } 
  
  PVector getPoint1()
  {
    return _pos1;
  }
 
  PVector getPoint2()
  {
    return _pos2;
  }
  
  public Boolean isInside(PVector c){
    /*
    if (c.x > _pos2.x && c.x < _pos1.x && c.y < _pos2.y && c.y > _pos1.y)
      return true;
      
    if (c.x > _pos1.x && c.x < _pos2.x && c.y > _pos1.y && c.y < _pos2.y)
      return true;
    */
    
    if (c.x > P1.x && c.y > P1.y && c.x < P2.x && c.y < P2.y) return true;
    
    if (_pos1.x == _pos2.x) // VERTICAL
    {
      if(abs(c.x-_pos1.x) < r_part*3)
        return true;
    } else { // HORIZONTAL
      if(abs(c.y-_pos1.y) < r_part*3)
        return true;
    } 
    
    return false;
  }
  
  void setCoefficients()
  {
    PVector v = new PVector(_pos2.x - _pos1.x, _pos2.y - _pos1.y, 0.0);
    PVector z = new PVector(_pos2.x - _pos1.x, _pos2.y - _pos1.y, 1.0);
    
    _coefs[0] = v.y*z.z - z.y*v.z;
    _coefs[1] = -(v.x*z.z - z.x*v.z);
    _coefs[2] = v.x*z.y - z.x*v.y;
    _coefs[3] = -_coefs[0]*_pos1.x - _coefs[1]*_pos1.y - _coefs[2]*_pos1.z;
  }
  
  void calculateNormal(boolean inverted)
  {
    _normal = new PVector(_coefs[0], _coefs[1], _coefs[2]);
    _normal.normalize();
    
    if (inverted)
      _normal.mult(-1);
  }
  
  float getDistance(PVector p)
  {
    float d = (_coefs[0]*p.x + _coefs[1]*p.y + _coefs[2]*p.z + _coefs[3]) / (sqrt(_coefs[0]*_coefs[0] + _coefs[1]*_coefs[1] + _coefs[2]*_coefs[2]));
    return abs(d);
  }
  
  PVector getNormal()
  {
    return _normal;
  }

  void draw() 
  {
    /*** ¡¡Esta función se debe modificar si la simulación necesita conversión entre coordenadas del mundo y coordenadas de pantalla!! ***/
    
    stroke(200);
    strokeWeight(5);
    
    // Plane representation:
    line(_pos1.x, _pos1.y, _pos2.x, _pos2.y); 
    
    float cx = _pos1.x*0.5 + _pos2.x*0.5;
    float cy = _pos1.y*0.5 + _pos2.y*0.5;

    // Normal vector representation:
    line(cx, cy, cx + 5.0*_normal.x, cy + 5.0*_normal.y);    
  }
} 
// Fluido y Estrructuas de datos
// Óscar Marín Egea
// Francisco Sevillano Asensi

enum EstructuraDatos 
{
  NONE,
  GRID,
  HASH
}

EstructuraDatos type = EstructuraDatos.NONE;

// Grid
Grid grid;
int rows = 30;
int cols = 30;

//Hash
HashTable hash;

final float SIM_STEP = 0.05;   // Simulation time-step (s)
float _simTime = 0.0;   // Simulated time (s)

final float Gc = 9.801;   // Gravity constant (m/(s*s))
final PVector G = new PVector(0.0, Gc);   // Acceleration due to gravity (m/(s*s))

ParticleSystem _system;   // Particle system
ArrayList<PlaneSection> _planes;    // Planes representing the limits
boolean _computePlaneCollisions = true;

// Display values:

final boolean FULL_SCREEN = false;
final int DRAW_FREQ = 50;   // Draw frequency (Hz or Frame-per-second)
int DISPLAY_SIZE_X = 1500;   // Display width (pixels)
int DISPLAY_SIZE_Y = 1500;   // Display height (pixels)
final int BACKGROUND_COLOR = 5;

final int padding = 100;
final int padding_puerta = (DISPLAY_SIZE_X/2)-padding;
Boolean puerta = true;
final int r_part = 50;
final int n_part = 40;

void settings()
{
  if (FULL_SCREEN)
  {
    fullScreen();
    DISPLAY_SIZE_X = displayWidth;
    DISPLAY_SIZE_Y = displayHeight;
  } 
  else
    size(DISPLAY_SIZE_X, DISPLAY_SIZE_Y);
}

void setup()
{
  initSimulation();
}

void initSimulation()
{
  _system = new ParticleSystem(50);
  _planes = new ArrayList<PlaneSection>();

  _planes.add(new PlaneSection(padding*2, padding, width-padding*2, padding, true)); //Arriba
  _planes.add(new PlaneSection(padding*2, padding, padding, padding*3,false)); //Izquierda 1
  _planes.add(new PlaneSection(padding, padding*3, padding_puerta, height/2, false)); //Izquierda 2
  _planes.add(new PlaneSection(width-padding*2, padding, width-padding, padding*3,true)); //Derecha 1
  _planes.add(new PlaneSection(width-padding, padding*3, width-padding_puerta, height/2, true)); //Derecha 2
  
  _planes.add(new PlaneSection(padding_puerta, height/2, padding_puerta+padding*2, height/2, false)); //Puerta
  
  
  grid = new Grid(rows, cols); 
  hash = new HashTable(_system.getNumParticles()*2, width/rows);
}

void drawStaticEnvironment()
{
  
  
  for(int i = 0; i < _planes.size(); i++)
  {
      _planes.get(i).draw();
  }
}

void draw() 
{
  background(BACKGROUND_COLOR);
  
  drawStaticEnvironment();
    
  _system.run();
  _system.computeCollisions(_planes, _computePlaneCollisions);  
  _system.display();  

  _simTime += SIM_STEP;
}

void mouseClicked() 
{
}

void keyPressed()
{
  if (key == 'a')
  {
    if (puerta)
    {
      _planes.remove(5);
      puerta = false;
    }
    else
    {
      _planes.add(new PlaneSection(padding_puerta, height/2, padding_puerta+padding*2, height/2, false));
      puerta = true;
    }
  }
}
  
void stop()
{
}

