class HashTable 
{
  ArrayList<ArrayList<Particle>> _table;
  
  int _numCells;
  float _cellSize;
  color[] _colors;
  
  HashTable(int numCells, float cellSize) 
  {
    _table = new ArrayList<ArrayList<Particle>>();
    
    _numCells = numCells; 
    _cellSize = cellSize;

    _colors = new color[_numCells];
    
    for (int i = 0; i < _numCells; i++)
    {
      ArrayList<Particle> cell = new ArrayList<Particle>();
      _table.add(cell);
      _colors[i] = color(int(random(0,256)), int(random(0,256)), int(random(0,256)), 150);
    }
  }
  
  void insertar(Particle p, int celda)
  {
    _table.get(hash(p._s)).add(p);
  }
  
  ArrayList<Particle> getVecindario(Particle p){
    ArrayList<Particle> vecinos = new ArrayList<Particle>();
    IntList celdas_vecinas = new IntList();
    
    if (p._s.y > _cellSize) celdas_vecinas.append(hash(new PVector(p._s.x, p._s.y-_cellSize)));  
    if (p._s.y < DISPLAY_SIZE_Y-_cellSize) celdas_vecinas.append(hash(new PVector(p._s.x, p._s.y+_cellSize))); 
    if (p._s.x > _cellSize) celdas_vecinas.append(hash(new PVector(p._s.x-_cellSize, p._s.y))); 
    if (p._s.x < DISPLAY_SIZE_X-_cellSize) celdas_vecinas.append(hash(new PVector(p._s.x+_cellSize, p._s.y))); 
    
    for (int i = 0; i < celdas_vecinas.size(); i++){
      int tam = _table.get(celdas_vecinas.get(i)).size();
      for (int j = 0; j < tam; j++){
        vecinos.add(_table.get(celdas_vecinas.get(i)).get(j));
      }
    }
    
    return vecinos;
  }
  
  void restart()
  {
    for(int i = 0; i < _table.size(); i++){
      _table.get(i).clear();
    }
  }
  
  int hash (PVector pos)
  {
    int celda = int((3 * (pos.x/_cellSize) + 5 * (pos.y/_cellSize)) % _table.size());
    return celda;
  }
}