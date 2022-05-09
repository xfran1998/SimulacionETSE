 //<>//
import peasy.*;

final int MAP_CELLS = 150;
final float MAP_CELL_SIZE = 10;

// DISPLAY STUFF
final boolean FULL_SCREEN = false;
final int DRAW_FREQ = 50;   // Draw frequency (Hz or Frame-per-second)
int DISPLAY_SIZE_X = 1000;   // Display width (pixels)
int DISPLAY_SIZE_Y = 1000;   // Display height (pixels)

final float FOV = 60;   // Field of view (º)
final float NEAR = 0.01;   // Camera near distance (m)
final float FAR = 100000.0;   // Camera far distance (m)

final color BACKGROUND_COLOR = color(220, 240, 220);   // Background color (RGB)

PeasyCam _camera;   // mouse-driven 3D camera

// Time control:

int _lastTimeDraw = 0;   // Last measure of time in draw() function (ms)
float _deltaTimeDraw = 0.0;   // Time between draw() calls (s)
float _simTime = 0.0;   // Simulated time (s)
float _elapsedTime = 0.0;   // Elapsed (real) time (s)

HeightMap _mapa;   // Deformable mesh

void initSimulation()
{
  _simTime = 0.0;
  _elapsedTime = 0.0;
  _mapa = new HeightMap(MAP_CELL_SIZE, MAP_CELLS);
}

void settings()
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

void setup()
{
  frameRate(DRAW_FREQ);
  _lastTimeDraw = millis();
  
  float aspect = float(DISPLAY_SIZE_X)/float(DISPLAY_SIZE_Y);  
  perspective((FOV*PI)/180, aspect, NEAR, FAR);
  _camera = new PeasyCam(this, 0);

  initSimulation();
}

void draw(){
  int now = millis();
  _deltaTimeDraw = (now - _lastTimeDraw)/1000.0;
  _elapsedTime += _deltaTimeDraw;
  _lastTimeDraw = now;
  
  background(BACKGROUND_COLOR);
  _mapa.display();
  
  _mapa.update();
}

void keyPressed()
{
  if (key == 's')
  {
    _mapa.addWave(10, 0.5, 10, new PVector(1, 0, 0), 1);
    print("adios");
  }
}
