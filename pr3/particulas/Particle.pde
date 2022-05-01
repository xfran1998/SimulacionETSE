class Particle 
{
  ParticleSystem _ps;
  int _id;

  PVector _s;
  PVector _v;
  PVector _a;
  PVector _f;
  
  float k = 0.1;
  float ke = 0.8;
  ArrayList<Particle> vecinos;

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

    vecinos = new ArrayList<Particle>();
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
    
    int total = 0;
    
    if(type == EstructuraDatos.values()[0])
    {
      vecinos = _ps.getParticleArray();
      print("o");
    } else if (type == EstructuraDatos.values()[1]) {
      // GRID
      vecinos = grid.getVecindario(this);
      print("x");
    } else {
      // HASH
      vecinos = hash.getVecindario(this);
      print("i");
    }
    
    total = vecinos.size();
    print(total + "\n");
    
    for (int i = 0 ; i < total; i++)
    {
      // miramos que no se compare consigo misma
      if(_id != i){
        Particle p = vecinos.get(i);
        
        PVector dist = PVector.sub(_s, p._s);
        float distValue = dist.mag();
        PVector normal = dist.copy();
        normal.normalize();
       
        if(distValue < _radius*2)
        {
          PVector target = PVector.add(p._s, PVector.mult(normal, _radius*2));
          
          PVector Fmuelle = PVector.mult(PVector.sub(target, _s), ke);
         
          _v.add(Fmuelle);
        }
      }
    }
  }
  
  void display() 
  {
    noStroke();
    fill(255, 100);
    circle(_s.x, _s.y, 2.0*_radius);
  }
}