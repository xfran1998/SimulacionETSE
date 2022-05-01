class Grid 
{
  ArrayList<ArrayList<Particle>> _cells;
  ArrayList<ArrayList<color>> _colors;
  
  int _nRows; 
  int _nCols; 
  int _numCells;
  float _cellSize;
  
  Grid(int rows, int cols) 
  {
    _cells = new ArrayList<ArrayList<Particle>>();
    _colors = new ArrayList<color>();
    
    _nRows = rows;
    _nCols = cols;
    _numCells = _nRows*_nCols;
    _cellSize = width/_nRows;
    
    for (int i = 0; i < _numCells; i++) 
    {
      ArrayList<Particle> cell = new ArrayList<Particle>();
      
      _cells.add(cell);
      _colors.add(new color(int(random(0,256)), int(random(0,256)), int(random(0,256)), 150));
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

  ArrayList<PVector> getCeldasColindantes(int celda)
  {
    int fila = int(celda / _nCols);
    int columna = celda % _nCols;

    ArrayList<PVector> celdasColindantes = new ArrayList<PVector>();

    // celda superior
    if (fila > 0)
    {
      celdasColindantes.add(new PVector(columna, fila-1));
    }
    // celda inferior
    if (fila < _nRows-1)
    {
      celdasColindantes.add(new PVector(columna, fila+1));
    }
    // celda izquierda
    if (columna > 0)
    {
      celdasColindantes.add(new PVector(columna-1, fila));
    }
    // celda derecha
    if (columna < _nCols-1)
    {
      celdasColindantes.add(new PVector(columna+1, fila));
    }
    // celda superior izquierda
    if (fila > 0 && columna > 0)
    {
      celdasColindantes.add(new PVector(columna-1, fila-1));
    }
    // celda superior derecha
    if (fila > 0 && columna < _nCols-1)
    {
      celdasColindantes.add(new PVector(columna+1, fila-1));
    }
    // celda inferior izquierda
    if (fila < _nRows-1 && columna > 0)
    {
      celdasColindantes.add(new PVector(columna-1, fila+1));
    }
    // celda inferior derecha
    if (fila < _nRows-1 && columna < _nCols-1)
    {
      celdasColindantes.add(new PVector(columna+1, fila+1));
    }
  
    return celdasColindantes; // TODO: Pendiente de revision
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

  // Gets the particles of the same cell as the particle p given and the colindant cells
  // PARAMS:
  // p: particle to get the cell of
  // 
  // RETURNS:
  // ArrayList<Particle> with the particles of the same cell as p and colindant cells
  void getParticleColliders(Particle p)
  {
    int cell = getCelda(p.pos);

  }
}
