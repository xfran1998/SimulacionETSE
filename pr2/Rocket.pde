public class Rocket 
{
  RocketType _type;

  Particle _casing;
  ArrayList<Particle> _particles;
  
  PVector _launchPoint;
  PVector _launchVel;  
  PVector _explosionPoint;
  
  color _color;
  boolean _hasExploded;

  Rocket(RocketType type, PVector pos, PVector vel, color c) 
  {
    _type = type;
    _particles = new ArrayList<Particle>();
    
    _launchPoint = pos.copy();
    _launchVel = vel.copy();
    _explosionPoint = new PVector(0.0, 0.0, 0.0);
    
    _color = c;
    _hasExploded = false;
    
    createCasing();
    _numParticles++;
  }
  
  void createCasing()
  {
    // Codigo para crear la carcasa
    _casing = new Particle(ParticleType.values()[0], _launchPoint, _launchVel, 10, 40, _color);
  }
  
  PVector createVelocityRand(float ang, float k, int m, int n){
    float vel = (cos(((2*asin(k))+(PI*m))/(2*n)))/(cos(((2*asin(k*cos(n*ang)))+(PI*m))/(2*n)));
    PVector v = new PVector(cos(ang), sin(ang));
    v.setMag(vel*50);
    return v;
  }
  
  void explosion() 
  {
    // Codigo para utilizar el vector de partículas, creando particulas en él con diferentes velocidades para recrear distintos tipos de palmeras
    PVector vel = new PVector();
    float k = random(0,1);
    int m = (int)random(1,4);
    int n = (int)random(5,8);
    
    for (float ang = 0; ang <= 2*PI; ang += (2*PI)/50)
    {
      if (_type == RocketType.values()[0]){
        vel = createVelocityRand(ang, k, m, n);
      } else {
        vel = new PVector((cos(ang)+sin(ang*10))*100, (sin(ang)+sin(ang*5))*100);
      }
      
      _particles.add(new Particle(ParticleType.values()[1], _explosionPoint, vel, 1, 30, _color));
      _numParticles++;  
    }
    
    
  }

  void run() 
  {
    // Codigo con la lógica de funcionamiento del cohete. En principio no hay que modificarlo.
    // Si la carcasa no ha explotado, se simula su ascenso.
    // Si la carcasa ha explotado, se genera su explosión y se simulan después las partículas creadas.
    // Cuando una partícula agota su tiempo de vida, es eliminada.
    
    if (!_casing.isDead())
      _casing.run();
    else if (_casing.isDead() && !_hasExploded)
    {
      _numParticles--;
      _hasExploded = true;

      _explosionPoint = _casing.getPosition().copy();
      explosion();
    }
    else
    {
      for (int i = _particles.size() - 1; i >= 0; i--) 
      {
        Particle p = _particles.get(i);
        p.run();
        
        if (p.isDead()) 
        {
          _numParticles--;
          _particles.remove(i);
        }
      }
    }
  }
}
