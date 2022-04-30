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
    _table.get(celda).add(p);
  }
  
  void restart()
  {
    for(int i = 0; i < _table.size(); i++){
      _table.get(i).clear();
    }
  }
  
  int hash (PVector pos)
  {
    int celda = int((3 * pos.x + 5 * pos.y) % _table.size());
    return celda;
  } //<>// //<>//
}
