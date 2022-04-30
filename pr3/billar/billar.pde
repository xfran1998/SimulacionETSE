// Billar Francés
// Oscar Marin Egea
// Francisco Sevillano Asensi


final float SIM_STEP = 0.01;   // Simulation time-step (s)
float _simTime = 0.0;   // Simulated time (s)

ParticleSystem _system;   // Particle system
ArrayList<PlaneSection> _planes;    // Planes representing the limits
boolean _computePlaneCollisions = true;

// Display values:

final boolean FULL_SCREEN = false;
final int DRAW_FREQ = 50;   // Draw frequency (Hz or Frame-per-second)
int DISPLAY_SIZE_X = 1000;   // Display width (pixels)
int DISPLAY_SIZE_Y = 1000;   // Display height (pixels)
final int BACKGROUND_COLOR = 50;
final color POOL_COLOR = color(44,130,87);

final float padding = 200;
final float proporcion = 1.78;
final float ancho = DISPLAY_SIZE_X-padding*2;
final float alto = ancho/proporcion;
final float altura = (DISPLAY_SIZE_Y/2)-(alto/2);

final int N_bolas = 5;
final int R_bolas = 10;
final float M_bolas = 1;

int target = -1;
PVector targetVel = new PVector(0,0);

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
  // ...
  // ...
  // ...
  
  initSimulation();
}

void initSimulation()
{
  _system = new ParticleSystem(N_bolas, R_bolas, M_bolas);
  _planes = new ArrayList<PlaneSection>();

  // crear los bordes
  _planes.add(new PlaneSection(padding, altura, padding+ancho, altura, true)); // ARRIBA
  _planes.add(new PlaneSection(padding, altura+alto, padding+ancho, altura+alto, false)); // ABAJO
  _planes.add(new PlaneSection(padding, altura, padding, altura+alto, false)); // IZQUIERDA
  _planes.add(new PlaneSection(padding+ancho, altura, padding+ancho, altura+alto, true)); // DERECHA
}

void drawStaticEnvironment()
{
  fill(POOL_COLOR);
  rect(padding,altura, ancho, alto);
  
  //dibujar los bordes
  for(int i = 0; i < _planes.size(); i++)
  {
    _planes.get(i).draw();
  }
  
  if (target >= 0)
  {
    Particle p = _system.getParticleArray().get(target);
    stroke(255);
    line(p.getPos().x, p.getPos().y, p.getPos().x+targetVel.x, p.getPos().y+targetVel.y);
    PVector arrow = targetVel.copy();
    arrow.normalize().mult(10);
    arrow.rotate(radians(45));
    line(p.getPos().x+targetVel.x, p.getPos().y+targetVel.y, p.getPos().x+targetVel.x-arrow.x, p.getPos().y+targetVel.y-arrow.y);
    arrow.rotate(radians(-90));
    line(p.getPos().x+targetVel.x, p.getPos().y+targetVel.y, p.getPos().x+targetVel.x-arrow.x, p.getPos().y+targetVel.y-arrow.y);
    
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

  // ...
  // ...
  // ...
}

void mouseClicked() 
{
  ArrayList<Particle> pa = _system.getParticleArray();
  
  if (target < 0)
  {
    for(int i = 0; i < pa.size(); i++)
    {
      Particle p = pa.get(i);
      
      if (PVector.sub(p.getPos(), new PVector(mouseX, mouseY)).mag() < p.getRadius())
      {
        print("entra");
        target = i;
      }
    }
  } else {
    Particle p = pa.get(target);
    
    p.setVel(targetVel);
    
    target = -1;
  }
}

void mouseMoved() 
{
  if (target >= 0)
  {
    Particle p = _system.getParticleArray().get(target);
    targetVel = PVector.sub(p.getPos(), new PVector(mouseX, mouseY));
  }
}

void keyPressed()
{
}
  
void stop()
{
}
