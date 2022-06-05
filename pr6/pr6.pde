// Muy importante añadir la librería Fisica a processing Herramientas/Añadir Herramienta...
import fisica.*;    

final int NUM_OBJETOS = 50;
final int TAM_OBJETO_X = 60;
final int TAM_OBJETO_Y = 60;

FWorld _world;           
ArrayList<FBox> _objetos;
ArrayList<FDistanceJoint> _joints;
ArrayList<FBox> _fijos;
ArrayList<FBox> _molinos;
ArrayList<FallingBox> _falling_objs;

class FallingBox{
  FBox _box;
  float _ttl;
  final float _ttl_decrement = 0.1;

  FallingBox(float mouseX, float mouseY, float ttl){
    _box = new FBox(TAM_OBJETO_X, TAM_OBJETO_Y);
    _box.setPosition(mouseX, mouseY);
    _box.setFillColor(color(#00FF00));
    _box.setRestitution(0.5);
    _box.setFriction(0.5);
    _box.setDensity(0.5);

    _ttl = ttl;
    _world.add(_box);
  }

  boolean update(){
    _ttl -= _ttl_decrement;
    if (_ttl <= 0.0){
      print("Entra3\n");
      return true;
    }
    print("Entra2\n");
    return false;
  }

  void removeObj(){
    _world.remove(_box);
  }
}

void setup()
{
  size(1000, 1000);
  smooth();
  
  _objetos = new ArrayList<FBox>(0);
  _fijos = new ArrayList<FBox>(0);
  _molinos = new ArrayList<FBox>(0);
  _joints = new ArrayList<FDistanceJoint>(0);
  
  Fisica.init(this);
  _world = new FWorld();
  _world.setEdges();
   
   FBox objeto = new FBox(60, 700);
   
   int posX = 800;     
   int posY = 640;     
   
   objeto.setPosition(posX, posY);
   objeto.setDensity(1.0f);
   objeto.setStatic(true);
   
   _world.add(objeto);
   _fijos.add(objeto);
   
   _falling_objs = new ArrayList<FallingBox>();
   
   //molino
   
   for(int i = 0; i < 5; i++){
     FBox palo = new FBox(10, 120);
   
     int posX2 = (int)random(0, 700);     
     int posY2 = (int)random(450, 900);     
     
     palo.setPosition(posX2, posY2);
     palo.setSensor(true);
     palo.setStatic(true);
     
     FBox molino = new FBox(20, 120);
     molino.setPosition(posX2, posY2-30);
     molino.setDensity(1.0f);
     
     FDistanceJoint joint = new FDistanceJoint(molino, palo);
     joint.setLength(0.0);
     joint.setAnchor2(0, -60);
     
     _world.add(palo);
     _world.add(molino);
     _world.add(joint);
     _fijos.add(palo);
     _molinos.add(molino);
   }
}

void draw() 
{
  background(225, 225, 255);

  // Simulación de los objetos del mundo físico
  _world.step();
  
  // Cambio de color de los objetos en función de su estado
  for (int i = 0; i < _falling_objs.size(); i++)
  {
     FBox objeto = _falling_objs.get(i)._box;
     
     if (objeto.isSleeping())
        objeto.setFillColor(color(#FF0000));
     else
     {
        objeto.setFillColor(color(0,255,0,_falling_objs.get(i)._ttl*10));
       objeto.setStrokeColor(color(0,0,0,0));
     }
  }
  
  for (int i = 0; i < _molinos.size(); i++)
  {
     FBox objeto = _molinos.get(i);
     objeto.addTorque(1000);
  }
  
  for (FallingBox obj : _falling_objs){
    
    if (obj.update()){
      obj.removeObj();
      //_falling_objs.remove(obj);
    }
  }

  // Dibujado de los objetos del mundo físico
  _world.draw();
  printInfo();
}

void printInfo()
{
    camera();
    fill(0);
    textSize(20);
    
    text("haz click derecho para añadir cubos que rebotaran con los molinos", width*0.025, height*0.05);
    text("Con el click izquierdo puedes arrastrar los molinos desde los palos para reposicionarlos", width*0.025, height*0.075);

}

void mousePressed(){
  if (mouseButton == RIGHT) {
      _falling_objs.add(new FallingBox(mouseX, mouseY, 20));
  }
}
