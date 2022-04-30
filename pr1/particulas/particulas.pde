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

final float SIM_STEP = 0.01;   // Simulation time-step (s)
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
final int r_part = 5;
final int n_part = 1;

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
  _system = new ParticleSystem(100);
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
