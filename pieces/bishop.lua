local Bishop = {}

function Bishop.newBishop(row, column, team)
  local bishop = Piece.newPiece(row, column, team)
  
  bishop.health = 100
  bishop.damage = 100
  bishop.sprite = Sprite.load("pieces/bishop.tga", 78, 126)
  bishop.type = "Bishop"
  
  function bishop:getMoves()
    for row = 1, Constants.NUM_ROWS do
      for col = 1, Constants.NUM_COLUMNS do
        local move = {}
        
        move.row = col
        move.column = row
        
        local x_len = math.abs(self.row - move.row)
        local y_len = math.abs(self.column - move.column)
        
        if (x_len == y_len) then
          if Board.getPieceAt(move.column, move.row) == nil then
            table.insert(self.moves, move)
          end
          table.insert(self.attacks, move)
        end
      end
    end
    self:filter()
  end
  
  return bishop
end

return Bishop