// Billar Francés
// Oscar Marin Egea
// Francisco Sevillano Asensi


final float SIM_STEP = 0.05;   // Simulation time-step (s)
float _simTime = 0.0;   // Simulated time (s)
float _deltaTimeDraw = 0.0;   // Time since last draw (s)
float _lastTimeDraw = 0.0;   // Last draw time (s)
float _elapsedTime = 0.0;   // Elapsed time since simulation start (s)

ParticleSystem _system;   // Particle system
ArrayList<PlaneSection> _planes;    // Planes representing the limits
boolean _computeParticleCollisions = true;

PrintWriter _output;

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

final PVector Fg = new PVector(10,10);
Boolean gravedad;

final int R_bolas = 10;
final float M_bolas = 1;
int N_bolas = 100;

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
  _output = createWriter("data.csv");
  _output.println("tiempo,paso,framerate,n_part,tiemposindraw,tiempocondraw");
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

  _simTime = 0.0;
  _elapsedTime = 0.0;
  _lastTimeDraw = millis();
  gravedad = false;
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
  
  drawInfo();
}

void drawInfo(){
  float padding = 40;
  float init_height = height * 0.8;
  float init_width = width * 0.035;
  float init_width2 = width * 0.7;
  // info por pantalla
  // fps
  textSize(20);
  fill(0, 408, 612);
  text("Frame rate = " + 1.0/_deltaTimeDraw + " fps", init_width, init_height);
  // simulated time
  text("Simulated time = " + _simTime + " s ", init_width, init_height+padding*1);
  // numero de particulas
  text("Num particle = " + _system._n, init_width, init_height+padding*2);
  // tiempo de dibujado
  text("Draw time = " + _deltaTimeDraw + " ms ", init_width, init_height+padding*3);
  
  // Display Actual Estructura (medio pantalla)
  textSize(30);
  fill(0, 408, 612);
  text("Pulsa en una bola para disparar", width/2-220, height/2+200);

  // Comandos de funcionamiento
  textSize(20);
  fill(0, 408, 612);
  // Velocidades aleatorias para las particulas
  text("m - Velocidades aleatorias", init_width2, init_height+padding*0);
  // Alterar las coliisiones de las particulas
  text("c - Alternar colisiones", init_width2, init_height+padding*1);
  // Reiniciar la simulacion
  text("r - Resetear simulacion", init_width2, init_height+padding*2);
}

void printInfo(){
  _output.println(_elapsedTime + "," + SIM_STEP + "," + 1.0/_deltaTimeDraw + "," +_system._n);
}

void draw() 
{
  background(BACKGROUND_COLOR);
  int now = millis();
  _deltaTimeDraw = (now - _lastTimeDraw)/1000.0;
  _elapsedTime += _deltaTimeDraw;
  _lastTimeDraw = now; 
  
  drawStaticEnvironment();
    
  _system.run();
  _system.computeCollisions(_planes, _computeParticleCollisions);  
  _system.display();  

  _simTime += SIM_STEP;
  printInfo();
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
  if (key == 'm'){
    //velocidades aleatorias
    _system.velocidadesRand();
  }
  if (key == 'c'){
    //no colision entre particulas
    _computeParticleCollisions = !_computeParticleCollisions;
  }
  if (key == 'r'){
    //resetear simulacion
    initSimulation();
  }
  if (key == 'g'){
    //alterarnar gravedad
    gravedad = !gravedad;
  }
  if (key == 'e'){
    _output.flush(); // Writes the remaining data to the file 
    _output.close(); // Finishes the file 
    exit(); // Stops the program 
  }
}
  
void stop()
{
}
