
// Fluido y Estrructuas de datos
// Óscar Marín Egea
// Francisco Sevillano Asensi

// Descripcion del problema:
// Parrticulas con comportamientos diferentes que interaccionan entre si como muelles

enum EstructuraDatos 
{
  NONE,
  GRID,
  HASH
}

EstructuraDatos type = EstructuraDatos.NONE;

PrintWriter _output;

// Grid
Grid grid;
int rows = 30;
int cols = 30;

//Hash
HashTable hash;

int frame; // Frame counter

final float Gc = 9.801;   // Gravity constant (m/(s*s))
final PVector G = new PVector(0.0, Gc);   // Acceleration due to gravity (m/(s*s))

ParticleSystem _system;   // Particle system
ArrayList<PlaneSection> _planes;    // Planes representing the limits
boolean _computePlaneCollisions = true;

// Time control:
int _lastTimeDraw = 0;   // Last measure of time in draw() function (ms)
float _deltaTimeDraw = 0.0;   // Time between draw() calls (s)
// float _deltaTime
float _simTime = 0.0;   // Simulated time (s)
float _elapsedTime = 0.0;   // Elapsed (real) time (s)
final float SIM_STEP = 0.05;   // Simulation step (s)

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
final int n_part = 1000;
float m_part = 0.05;
float k = 0.4;
float ke = 1;
float k_pared = 0.1;
float L = r_part;    

Boolean shower = false;


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

  frame = 0;
}

void setup()
{
  initSimulation();
}

void initSimulation()
{
  _system = new ParticleSystem(n_part);
  _planes = new ArrayList<PlaneSection>();

  _planes.add(new PlaneSection(padding*2, padding, width-padding*2, padding, true)); //Arriba
  _planes.add(new PlaneSection(padding*2, padding, padding, padding*3,false)); //Izquierda 1
  _planes.add(new PlaneSection(padding, padding*3, padding_puerta, height/2, false)); //Izquierda 2
  _planes.add(new PlaneSection(width-padding*2, padding, width-padding, padding*3,true)); //Derecha 1
  _planes.add(new PlaneSection(width-padding, padding*3, width-padding_puerta, height/2, true)); //Derecha 2
  
  _planes.add(new PlaneSection(padding_puerta, height/2, padding_puerta+padding*2, height/2, false)); //Puerta
  
  
  grid = new Grid(rows, cols); 
  hash = new HashTable(_system.getNumParticles()*2, width/rows);
  _output = createWriter("data.csv");
  _output.println("tiempo,paso,framerate,n_part");
}

void drawStaticEnvironment()
{
  //hacer que se pueda activar y desactivar
  grid.display();
  
  for(int i = 0; i < _planes.size(); i++)
  {
      _planes.get(i).draw();
  }

  drawInfo();
  printInfo();
}

void drawInfo(){
  float padding = 40;
  float init_height = height * 0.5;
  float init_width = width * 0.035;
  float init_width2 = width * 0.7;
  // info por pantalla
  // fps
  textSize(40);
  fill(0, 408, 612);
  text("Frame rate = " + 1.0/_deltaTimeDraw + " fps", init_width, init_height);
  // simulated time
  text("Simulated time = " + _simTime + " s ", init_width, init_height+padding*1);
  // numero de particulas
  text("Num particle = " + _system._n, init_width, init_height+padding*2);
  // ms
  text("Delta time = " + _deltaTimeDraw + " ms", init_width, init_height+padding*3);

  // comandos de funcionamiento
  // Cambiar Fluidos (1, 2 y 3)
  // 1-GAS
  text("1 - GAS", init_width2, init_height+padding*0);
  // 2-LIQUID
  text("2 - LIQUID", init_width2, init_height+padding*1);
  // 3-SOLID
  text("3 - SOLID", init_width2, init_height+padding*2);

  // Quitar/Poner plano (p)
  text("p - Quitar/Poner plano", init_width2, init_height+padding*3);
  // Display Normal (n)
  text("n - Display Normal", init_width2, init_height+padding*4);
  // Display Grid (g)
  text("g - Display Grid", init_width2, init_height+padding*5);
  // Display Hash (h)
  text("h - Display Hash", init_width2, init_height+padding*6);
  // Añadir particula (Click)
  text("Click - Añadir particula", init_width2, init_height+padding*7);
}

void printInfo(){
  // framerate y numero de particulas por iteracion
  _output.println(_simTime + "," + SIM_STEP + "," + 1.0/_deltaTimeDraw + "," +_system._n);
}

void draw() 
{
  background(BACKGROUND_COLOR);

  int now = millis();
  _deltaTimeDraw = (now - _lastTimeDraw)/1000.0;
  _elapsedTime += _deltaTimeDraw;
  _lastTimeDraw = now;  
  
  drawStaticEnvironment();
    
  if (shower) {
    for (int i = 0; i < 5; i++){
      _system.addParticle(_system._n, new PVector(mouseX+random(-1,1), mouseY+random(-1,1)), new PVector(), m_part, r_part);
      _system._n++;
    }
  }

  float principio = millis();
  _system.run();
  _system.computeCollisions(_planes, _computePlaneCollisions);  
  float fin = millis();

  _system.display();  

  _simTime += SIM_STEP;
  frame++;
}

void keyPressed()
{
  if (key == 'p')
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
  
  if (key == 'n') {
    type = EstructuraDatos.NONE;
  }
  if (key == 'g') {
    type = EstructuraDatos.GRID;
  }
  if (key == 'h') {
    type = EstructuraDatos.HASH;
  }

  // Cambiar comportamiento particulas
  if (key == '1') {
    // Gaseoso
    m_part = 0.02;
    L = r_part;
    ke = 0.7;
    k_pared = 0.1;
    k = 0.4;
  }
  if (key == '2') {
    // Liquido
    m_part = 10;
    L = r_part;
    ke = 0.8;
    k_pared = 0.3;
  }
  if (key == '3') {
    // Viscoso
    m_part = 1;
    L = r_part;
    ke = 1;
    k_pared = 0.1;
  }
}
  
void stop()
{
}

void mousePressed()
{
  shower = true;
}

void mouseReleased()
{
  shower = false;
}
