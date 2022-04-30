class Particle  //<>//
{
  ParticleSystem _ps;
  int _id;

  PVector _s;
  PVector _v;
  PVector _a;
  PVector _f;
  ArrayList<PVector> _Fm; // lista de fuerzas de muelle
  
  float k = 0.9;

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
