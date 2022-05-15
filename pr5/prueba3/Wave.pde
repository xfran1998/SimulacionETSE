abstract class Wave 
{
  PVector _srcDir;
  float _L;
  float _T;
  float _A;
  float _C;
  float _W;
  float _K;
  float _phi;
  float _Q;
  ArrayList<PVector> onda;
  float _D;
  float _temp;
  ArrayList<Wave> extra;
  
  Boolean r1 = false, r2 = false;
  
  Wave (float a, float T, float L, PVector srcDir){
    _C = L/T;
    _A = a;
    _T = T;
    _W = 2 * PI/T;
    _L = L;
    _K = 2* PI / L;
    _srcDir = srcDir;
    _phi = T * 2 * PI;
    _Q = PI*a*_K; // Q_media segun el pdf de clase
    _temp = millis()/1000f;
    
    extra = new ArrayList<>();
  }
  
  abstract PVector evaluate(float t, PVector punto);
}

class DirectionalWave extends Wave {
  public DirectionalWave(float a, float T, float L, PVector srcDir){
    super(a, T, L, srcDir);
  }
  
  PVector evaluate(float t, PVector punto){
    PVector res = new PVector (punto.x, punto.y, punto.z);
    _D += t * _W/_K;
    
    _srcDir.normalize();
    res.y = _A * sin ((2 * PI / _L) * (PVector.dot(_srcDir, new PVector(punto.x, 0, punto.z))+ _W/_K * t));
    res.x = 0;
    res.z = 0;
    return res;
  }
}

class RadialWave extends Wave {
  public RadialWave(float a, float T, float L, PVector srcDir){
    super(a, T, L, srcDir);
  }
  
  PVector evaluate(float t, PVector punto){
    _D = (((t-_temp)+2) * _W/_K);
    
    PVector res = new PVector (punto.x, punto.y, punto.z);
      
    if (PVector.dist(punto, _srcDir) < _D && punto.z > 0){
      res.y = _A * sin((2*PI/_L) * (PVector.dist(_srcDir, new PVector(punto.x, 0, punto.z)) - _W/_K * (t-_temp+2)));
    }
    else
      res.y = 0;
    
    if (_D > PVector.dist(rendija1, _srcDir) && !r1){
      _mapa.addWave(_A/2, 1, 100, rendija1, 4);
      r1 = true;
    }
    
    if (_D > PVector.dist(rendija1, _srcDir) && !r2){
      _mapa.addWave(_A/2, 1, 100, rendija2, 4);
      r2 = true;
    }
    
    res.x = 0;
    res.z = 0;
    return res;
  }
}

class RendijaWave extends Wave {
  public RendijaWave(float a, float T, float L, PVector srcDir){
    super(a, T, L, srcDir);
  }
  
  PVector evaluate(float t, PVector punto){
    _D = (((t-_temp+1.5)) * _W/_K);
    
    PVector res = new PVector (punto.x, punto.y, punto.z);
      
    if (PVector.dist(punto, _srcDir) < _D && punto.z < 0){
      res.y = _A * sin((2*PI/_L) * (PVector.dist(_srcDir, new PVector(punto.x, 0, punto.z)) - _W/_K * (t-_temp+1.5)));
    }
    else
      res.y = 0;
    
    res.x = 0;
    res.z = 0;
    return res;
  }
}

class GerstnerWave extends Wave {
  public GerstnerWave(float a, float T, float L, PVector srcDir){
    super(a, T, L, srcDir);
    _srcDir.normalize();
  }
  
  PVector evaluate(float t, PVector punto){
    PVector res = new PVector (punto.x, punto.y, punto.z);
    
    res.x = -_Q * _A * _srcDir.x * cos((2 * PI / _L) * (PVector.dot(_srcDir, new PVector(punto.x, 0, punto.z))+ _W/_K * t));
    res.y = _A * sin ((2 * PI / _L) * (PVector.dot(_srcDir, new PVector(punto.x, 0, punto.z))+ _W/_K * t));
    res.z = -_Q * _A * _srcDir.z * cos((2 * PI / _L) * (PVector.dot(_srcDir, new PVector(punto.x, 0, punto.z))+ _W/_K * t));

    return res;
  }
}
