// Muy importante añadir la librería Fisica a processing Herramientas/Añadir Herramienta...
import fisica.*;    

final int NUM_OBJETOS = 10;
final int TAM_OBJETO_X = 60;
final int TAM_OBJETO_Y = 60;

FWorld _world;           
ArrayList<FCircle> _objetos;

FRevoluteJoint joint;

void setup()
{
  size(1000, 1000);
  smooth();
  
  _objetos = new ArrayList<FCircle>(0);
  
  Fisica.init(this);
  _world = new FWorld();
  _world.setEdges();
  _world.setGravity(0.0, 0.0);
   
  //FJoint join = new FJoint();
   
  FCircle circulo1 = new FCircle(TAM_OBJETO_X);
  FCircle circulo2 = new FCircle(TAM_OBJETO_X);
  
  circulo1.setPosition(width/2-200, height/2);
  circulo2.setPosition(width/2+200, height/2);
  
  circulo1.setAngularDamping(0.0);
  circulo2.setAngularDamping(0.0);
  
  joint = new FRevoluteJoint(circulo1, circulo2);
  joint.setEnableLimit(true);
  joint.setLowerAngle(0.0);
  joint.setUpperAngle(0.0);
  
  _world.add(circulo1);
  _world.add(circulo2);
  _world.add(joint);
  
  _objetos.add(circulo1);
  _objetos.add(circulo2);
}

void draw() 
{
  background(225, 225, 255);

  // Simulación de los objetos del mundo físico
  _world.step();
  // Cambio de color de los objetos en función de su estado
  for (int i = 0; i < _objetos.size(); i++)
  {
     FCircle objeto = _objetos.get(i);
     
     if (i == 0)
       objeto.addTorque(2000);
     
     if (objeto.isSleeping())
        objeto.setFillColor(color(#FF0000));
     else
        objeto.setFillColor(color(#FFFF00));
  }

  // Dibujado de los objetos del mundo físico
  _world.draw();
}

void mousePressed(){
  _world.remove(joint);
  
  FCircle objeto = _objetos.get(0);
  objeto.setPosition(mouseX, mouseY);
  
  joint = new FRevoluteJoint(_objetos.get(0), _objetos.get(1));
  joint.setEnableLimit(true);
  joint.setLowerAngle(0.0);
  joint.setUpperAngle(0.0);
  
  _world.add(joint);
}
