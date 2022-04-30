class Particle  //<>//
{
  ParticleSystem _ps;
  int _id;

  PVector _s;
  PVector _v;
  PVector _a;
  PVector _f;
  
  float k = 0.1;

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
        print(dist);
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
  
  void particleCollisionSpringModel()
  { 
    ArrayList<Particle> sistema = new ArrayList<Particle>();
    int total = 0;
    
    if(type == EstructuraDatos.values()[0])
    {
      total = _ps.getNumParticles();
      sistema = _ps.getParticleArray();
      
    } else if (type == EstructuraDatos.values()[1]) {
      
    } else {
      
    }
    
    for (int i = 0 ; i < total; i++)
    {
      // miramos que no se compare consigo misma
      if(_id != i){
        Particle p = sistema.get(i);
        
        PVector dist = new PVector(PVector.sub(p, _s));
        PVector distValue = dist.mag();
        PVector normal = dist.copy();
        normal.normalize();
       
        if(distance < _radius*2)
        {
          PVector target = PVector.mult(normal, _radius*2);
          ...
          float Fmuellex = (targetX - p._s.x) * Ke; //Distancia * constante elástica = fuerza del muelle
          float Fmuelley = (targetY - p._s.y) * Ke;
         
          //Nuevas velocidades de salida para ambas partículas: en estas actuará una fuerza del muelle determinada por sus posiciones
          this._v.x -= Fmuellex;
          this._v.y -= Fmuelley;
          p._v.x += Fmuellex;
          p._v.y += Fmuelley;
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
