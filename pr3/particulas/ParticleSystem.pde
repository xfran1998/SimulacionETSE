class ParticleSystem 
{
  ArrayList<Particle> _particles;
  int _n;
  int _cols;
  int _rows;
  

  ParticleSystem(int n)  
  {
    _particles = new ArrayList<Particle>();
    _n = n;
    _cols = (width-5*padding)/(r_part*2);
    _rows = n/cols;
    
    PVector Pos0 = new PVector(2.5*padding, 1.5*padding);
    PVector Vel0 = new PVector(0, 0);
    int ID = 0;
    //añadir un monton de particulas iniciales
    for (int i = 0; i < _rows; i++){      
      for(int j = 0; j < _cols ; j++){   
        PVector pos = new PVector(Pos0.x+j*r_part*2, Pos0.y+i*r_part*2);
        
        addParticle(ID, pos, Vel0, 1, r_part);
        ID++;
      }
    }
  }

  void addParticle(int id, PVector initPos, PVector initVel, float mass, float radius) 
  { 
    _particles.add(new Particle(this, id, initPos, initVel, mass, radius));
  }
  
  void restart()
  {
  }
  
  int getNumParticles()
  {
    return _n;
  }
  
  ArrayList<Particle> getParticleArray()
  {
    return _particles;
  }

  void run() 
  {
    for (int i = _n - 1; i >= 0; i--) 
    {
      Particle p = _particles.get(i);
      p.update();
    }
  }
  
  void computeCollisions(ArrayList<PlaneSection> planes, boolean computeParticleCollision) 
  { 
    for(int i = 0; i < _n; i++)
    {
      Particle p = _particles.get(i);
      p.planeCollision(planes);
    }
  }
    
  void display() 
  {
    for (int i = _n - 1; i >= 0; i--) 
    {
      Particle p = _particles.get(i);      
      p.display();
    }    
  }
}
