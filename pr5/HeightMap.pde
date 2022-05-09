public class HeightMap 
{
  private float _Cellsize;
  private int _n_rows;
  
  private PVector mapa[][];
  private float base;
  private PVector textura[][];
  private PVector esquina;
  
  ArrayList<Wave> waves;
  
  HeightMap (float tamCell, int n_rows){
    _Cellsize = tamCell;
    _n_rows = n_rows;
    base = 0;
    
    waves = new ArrayList<Wave>();
    
    mapa = new PVector[_n_rows][_n_rows];
    textura = new PVector[_n_rows][_n_rows];
    esquina = new PVector(-(_n_rows*_Cellsize)/2, -(_n_rows*_Cellsize)/2, 0);
    
    iniciaMapa();
  }
  
  void iniciaMapa(){
    for (int i = 0; i < _n_rows; i++){
      for (int j = 0; j < _n_rows; j++){
        mapa[j][i] = new PVector(esquina.x+j*_Cellsize, esquina.y+i*_Cellsize, base);
      }
    }
  }
  
  void display(){
    for (int i = 0; i < _n_rows; i++){
      for (int j = 0; j < _n_rows; j++){
        stroke(0);
        if (j < _n_rows-1)
          line(mapa[j][i].x, mapa[j][i].y, mapa[j][i].z, mapa[j+1][i].x, mapa[j+1][i].y, mapa[j+1][i].z); // hacia la derecha
        if (i < _n_rows-1)
          line(mapa[j][i].x, mapa[j][i].y, mapa[j][i].z, mapa[j][i+1].x, mapa[j][i+1].y, mapa[j][i+1].z); // hacia abajo
         if (j < _n_rows-1 && i < _n_rows-1)
          line(mapa[j][i].x, mapa[j][i].y, mapa[j][i].z, mapa[j+1][i].x, mapa[j+1][i+1].y, mapa[j+1][i+1].z); // hacia abajo a la derecha
      }
    }
  }
  
  void addWave(float a, float T, float L, PVector srcDir, int mode){
    waves.add(new Wave(a, T, L, srcDir, mode));
  }
  
  void update (){
    float time = millis()/1000f;
    
    for (int i = 0; i < _n_rows; i++){
      for (int j = 0; j < _n_rows; j++){
        // resetear posiciones
        mapa[j][i].z = base;
        
        for (int k = 0; k < waves.size(); k++){
          Wave w = waves.get(k);
          mapa[j][i] = w.evaluate(time, mapa[j][i]).copy();
          print("hola");
        }
      }
    }
  }
}
