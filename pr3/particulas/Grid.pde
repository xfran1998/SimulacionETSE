class Grid 
{
  ArrayList<ArrayList<Particle>> _cells;
  
  int _nRows; 
  int _nCols; 
  int _numCells;
  float _cellSize;
  color[] _colors;
  
  Grid(int rows, int cols) 
  {
    _cells = new ArrayList<ArrayList<Particle>>();
    
    _nRows = rows;
    _nCols = cols;
    _numCells = _nRows*_nCols;
    _cellSize = width/_nRows;
    
    _colors = new color[_numCells];
    
    for (int i = 0; i < _numCells; i++) 
    {
      ArrayList<Particle> cell = new ArrayList<Particle>();
      _cells.add(cell);
      _colors[i] = color(int(random(0,256)), int(random(0,256)), int(random(0,256)), 150);
    }
  }

  int getCelda(PVector pos)
  {
    int celda = 0;
    int fila = int(pos.y / _cellSize);
    int columna = int(pos.x / _cellSize);
    
    celda = fila*_nCols + columna;
    
    if (celda < 0 || celda >= grid._cells.size())
    {
      return 0;
    }
    else
      return celda;
  }
  
  ArrayList<Particle> getVecindario(Particle p){
    int celda = getCelda(p._s);
    ArrayList<Particle> vecinos = new ArrayList<Particle>();
    IntList celdas_vecinas = new IntList();
    
    if (!(celda < _nCols)) celdas_vecinas.append(celda-_nCols);  
    if (!(celda >= (_nRows-1)*_nCols)) celdas_vecinas.append(celda+_nCols); 
    if (celda%_nCols != 0) celdas_vecinas.append(celda-1);
    if (celda%_nCols != _nCols-1) celdas_vecinas.append(celda+1);
    
    for (int i = 0; i < celdas_vecinas.size(); i++){
      int tam = _cells.get(celdas_vecinas.get(i)).size();
      for (int j = 0; j < tam; j++){
        vecinos.add(_cells.get(celdas_vecinas.get(i)).get(j));
      }
    }
    
    return vecinos;
  }
  
  void insert(Particle p, int celda){
    _cells.get(celda).add(p);
  }
  
  void restart()
  {
    for(int i = 0; i < grid._cells.size(); i++)
    {
      _cells.get(i).clear();
    }
  }
  
  void display()
  {
    strokeWeight(1);
    stroke(250);
    
    for(int i = 0; i < _nRows; i++)
    {
      line(0, i*_cellSize, width, i*_cellSize); // lineas horizontales
      line(i*_cellSize, 0, i*_cellSize, height); // lineas verticales
    }
  }
}