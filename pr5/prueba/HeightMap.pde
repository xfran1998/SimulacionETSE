public class HeightMap 
{
  private float _Cellsize;
  private int _n_rows;
  
  private Particle mapa[][];
  private Particle mapa2[][];
  private PVector initValues[][];
  private float base;
  private PVector textura[][];
  private PVector esquina;
  ArrayList<DampedSpring> _springsSurface;
  
  ArrayList<Wave> waves;
  
  HeightMap (float tamCell, int n_rows){
    _Cellsize = tamCell;
    _n_rows = n_rows;
    base = 200;
    
    waves = new ArrayList<Wave>();
    _springsSurface = new ArrayList();
    
    mapa = new Particle[_n_rows][_n_rows];
    mapa2 = new Particle[_n_rows][_n_rows];
    initValues = new PVector[_n_rows][_n_rows];
    textura = new PVector[_n_rows][_n_rows];
    esquina = new PVector(-(_n_rows*_Cellsize)/2, -(_n_rows*_Cellsize)/2, 0);
    
    iniciaMapa();
  }
  
  void iniciaMapa(){
    for (int i = 0; i < _n_rows; i++){
      for (int j = 0; j < _n_rows; j++){
        Boolean clamped = false;
        if ((int)_n_rows/2 == i && j != 10 && j != _n_rows-10)
          clamped = true;
          
        mapa[j][i] = new Particle(new PVector(esquina.x+j*_Cellsize, base, esquina.y+i*_Cellsize), new PVector(), 0.1, clamped);
        mapa2[j][i] = new Particle(new PVector(esquina.x+j*_Cellsize, base, esquina.y+i*_Cellsize), new PVector(), 0.1, clamped);
        initValues[j][i] = new PVector(esquina.x+j*_Cellsize, base, esquina.y+i*_Cellsize);
        textura[j][i] = new PVector(j*img.width/(float)_n_rows, base, i*img.height/(float)_n_rows);
      }
    }
    
    for (int i = 0; i < _n_rows; i++){
      for (int j = 0; j < _n_rows; j++){
        if (j < _n_rows-1)
          _springsSurface.add(new DampedSpring(mapa[j][i], mapa[j+1][i], 150.0, 15.0, false, 500, 18));
        if (i < _n_rows-1)
          _springsSurface.add(new DampedSpring(mapa[j][i], mapa[j][i+1], 150.0, 15.0, false, 500, 18));
          
        _springsSurface.add(new DampedSpring(mapa[j][i], mapa2[j][i], 150.0, 5.0, false, 500, 18));
      }
    }
    
    for (int i = 0; i < _n_rows-1; i++){
      for (int j = 0; j < _n_rows; j++){
        if (j != 0)
          _springsSurface.add(new DampedSpring(mapa[j][i], mapa[j-1][i+1], 150.0, 15.0, false, 500, 18));
        if (j != _n_rows-1)
          _springsSurface.add(new DampedSpring(mapa[j][i], mapa[j+1][i+1], 150.0, 15.0, false, 500, 18));
      }
    }
  }
  
  void generarOnda(){
    mapa[(int)_n_rows/2][_n_rows-1]._s.y = base+20000;
  }
  
  
  void display(){
    for (int i = 0; i < _n_rows; i++){
      for (int j = 0; j < _n_rows; j++){
        stroke(0);
        if (j < _n_rows-1)
          line(mapa[j][i]._s.x, mapa[j][i]._s.y, mapa[j][i]._s.z, mapa[j+1][i]._s.x, mapa[j+1][i]._s.y, mapa[j+1][i]._s.z); // hacia la derecha
        if (i < _n_rows-1)
          line(mapa[j][i]._s.x, mapa[j][i]._s.y, mapa[j][i]._s.z, mapa[j][i+1]._s.x, mapa[j][i+1]._s.y, mapa[j][i+1]._s.z); // hacia abajo
         if (j < _n_rows-1 && i < _n_rows-1)
          line(mapa[j][i]._s.x, mapa[j][i]._s.y, mapa[j][i]._s.z, mapa[j+1][i]._s.x, mapa[j+1][i+1]._s.y, mapa[j+1][i+1]._s.z); // hacia abajo a la derecha
      }
    }
  }
  
  void displayTextured(){
    noStroke();
    for (int i = 0; i < _n_rows-1; i++) {
      beginShape(QUAD_STRIP);
      texture(img);
      for (int j = 0; j < _n_rows; j++) {
        vertex(mapa[j][i]._s.x, mapa[j][i]._s.y, mapa[j][i]._s.z, textura[j][i].x, textura[j][i].z);
        vertex(mapa[j][i+1]._s.x, mapa[j][i+1]._s.y, mapa[j][i+1]._s.z, textura[j][i+1].x, textura[j][i].z);
      }
      endShape();
    }
  }
  
  void addWave(float a, float T, float L, PVector srcDir, int mode){
    if (mode == 1)
      waves.add(new DirectionalWave(a, T, L, srcDir));
    if (mode == 2)
      waves.add(new RadialWave(a, T, L, srcDir));
    if (mode == 3)
      waves.add(new GerstnerWave(a, T, L, srcDir));
  }
  
  void update (){
    float time = millis()/1000f;
    
    int i, j;

    for (i = 0; i < _n_rows; i++)
      for (j = 0; j < _n_rows; j++)
        if (mapa[i][j] != null)
          mapa[i][j].update(SIM_STEP);

    for (DampedSpring s : _springsSurface) 
    {
      s.update(SIM_STEP);
      s.applyForces();
    }
  }
  
  void reset(){
    waves.clear();
  }
}
