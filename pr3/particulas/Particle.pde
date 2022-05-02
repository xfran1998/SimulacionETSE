class Particle 
{
  ParticleSystem _ps;
  int _id;

  PVector _s;
  PVector _v;
  PVector _a;
  PVector _f;

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
    //_m = mass; comentado para facilidad a la hora de trannsformar en gas
    _radius = radius;
    _color = color(0, 100, 255, 150);
  }

  void update() 
  {  
    updateForce();
    
    PVector a = PVector.div(_f, m_part);
    _v.add(PVector.mult(a, SIM_STEP));
    _s.add(PVector.mult(_v, SIM_STEP)); 
  }

  void updateForce()
  {  
    _f = new PVector();
    
    // Fuerza del peso
    PVector Fg = PVector.mult(G, m_part);
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
      
      if (p.isInside(_s)){
        
        // no necesitamos el lado dado que siempre estaran encerradas en la mesa
        PVector N = p.getNormal();
        
        PVector _PB = PVector.sub(_s, p.getPoint1());
        float dist = N.dot(_PB);
        if (abs(dist) < _radius){
          //reposicionamos la particula
          float mover = _radius-abs(dist);
          _s.add(PVector.mult(N, mover));
          
          //Respuesta a la colision
          float nv = (N.dot(_v));
          PVector Vn = PVector.mult(N, nv);
          PVector vt = PVector.sub(_v, Vn);
          //le cambiamos la direccion
          Vn.mult(-1*k_pared);
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
    } else if (type == EstructuraDatos.values()[1]) {
      // GRID
      vecinos = grid.getVecindario(this);
    } else {
      // HASH
      vecinos = hash.getVecindario(this);
    }
    
    total = vecinos.size();
    
    for (int i = 0 ; i < total; i++)
    {
      // miramos que no se compare consigo misma
      if(_id != i){
        Particle p = vecinos.get(i);
        
        PVector dist = PVector.sub(_s, p._s);
        float distValue = dist.mag();
        PVector normal = dist.copy();
        normal.normalize();
       

        if(distValue < L)
        {
          PVector Fmuelle = PVector.mult(normal, (L-distValue)*ke);

          _v.add(Fmuelle);
        }
      }
    }
  }
  
  void display() 
  {
    noStroke();
    if(type == EstructuraDatos.values()[0])
    {
      fill(255, 100);
    } else if (type == EstructuraDatos.values()[1]) {
      // GRID
      fill(grid.getColor(_s));
    } else {
      // HASH
      fill(hash.getColor(_s));
    }
    
    circle(_s.x, _s.y, 2.0*_radius);
  }
}