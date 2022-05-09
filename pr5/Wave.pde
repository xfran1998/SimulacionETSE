public class Wave 
{
  int _mode;
  PVector _srcDir;
  float _L;
  float _T;
  float _A;
  float _C;
  float _W;
  float _F;
  float _phi;
  
  Wave (float a, float T, float L, PVector srcDir, int mode){
    _mode = mode;
    _C = L/T;
    _A = a;
    _T = T;
    _W = 2 * PI/T;
    _L = L;
    _F = 2* PI / _L;
    _srcDir = srcDir;
    _phi = _T * 2 * PI;
  }
  
  PVector evaluate(float t, PVector punto){
    PVector res = new PVector (punto.x, punto.y, punto.z);
    
    switch (_mode)
    {
      case 1:
        _srcDir.normalize();
        res.z = _A * sin (punto.x + _phi * t);
        break;
    }
    
    return res;
  }
}
