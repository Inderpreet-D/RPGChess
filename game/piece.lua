local Piece = {}

PieceHelper = require("utils.pieceHelper")
Bishop = require("pieces.bishop")
King = require("pieces.king")
Knight = require("pieces.knight")
Pawn = require("pieces.pawn")
Queen = require("pieces.queen")
Rook = require("pieces.rook")

Piece.available_sprite = Sprite.load("background/available.tga", 126, 126)
Piece.available_sprite:setAnimation(0)
Piece.available_sprite:setRotation(math.pi / 180)

Piece.selected_sprite = Sprite.load("background/selected.tga", 126, 126)
Piece.selected_sprite:setAnimation(0.5)
Piece.selected_sprite:setRotation(math.pi / 120)

Piece.font = love.graphics.newFont("assets/fonts/op.ttf", 20)

function Piece.newPiece(row, column, team)
  local piece = {}
  piece.moves = {}
  piece.attacks = {}
  
  piece.row = column
  piece.column = row
  
  piece.team = team
  piece.active = false
  piece.alive = true
  piece.moves_made = 0
  
  piece.forward_x = 1
  
  if piece.team == 2 then 
    piece.forward_x = -1
  end
  
  if piece.team == 1 then 
    piece.color = Board.player_one_color
  else 
    piece.color = Board.player_two_color
  end
  
  function piece:update(dt)
    if self.alive then
      self.x = Constants.BOARD_ORIGIN_X + ((self.row - 1) * (Constants.CELL_WIDTH + Constants.BORDER_SIZE)) + (Constants.CELL_WIDTH / 2)
      self.y = Constants.BOARD_ORIGIN_Y + ((self.column - 1) * (Constants.CELL_HEIGHT + Constants.BORDER_SIZE)) + (Constants.CELL_HEIGHT / 2)
      
      if self.health <= 0 then
        self.alive = false
      end
    else
      for k, piece in pairs(Board.pieces) do
        if self == piece then
          table.remove(Board.pieces, k)
        end
      end
    end
  end
  
  function piece:onClick(player)
    if player == self.team then
      self.active = not self.active
    end
    
    for k, p in pairs(Board.pieces) do 
      if p ~= self then
        p.active = false
        p.moves = {}
      end
    end
    
    if self.active then
      self:populateMoveSet()
    else
      self.moves = {}
    end
  end
  
  function piece:populateMoveSet()
    self:getMoves()
    self:getAttacks()
  end
  
  function piece:getMoveLine(x, y)
    local i = 1
    
    while true do
      local move = {}
      
      move.row = self.row + (i * (self.forward_x * y))
      move.column = self.column - (i * x)
      
      if PieceHelper.movePossible(move) then
        self.moves[#self.moves + 1] = move
        i = i + 1
      else 
        break
      end
    end
  end
  
  function piece:getAttackLine(x, y)
    local i = 1
    
    while true do
      local attack = {}
      
      attack.row = self.row + (i * (self.forward_x * y))
      attack.column = self.column - (i * x)
      
      if PieceHelper.attackPossible(self, attack) then
        self.attacks[#self.attacks + 1] = attack
        break
      else
        if PieceHelper.movePossible(attack) then
          i = i + 1
        else
          break
        end
      end
    end
  end
  
  function piece:onDeath()
    if (self.type == "King") then
      State.current = State.game_over
      local s = "\n"
      
      if (self.team == 1) then
        s = s .. "Blue Team Wins!"
      else
        s = s .. "Red Team Wins!"
      end
      
      Driver.end_string = Driver.end_string .. s
    end
  end
  
  setmetatable(piece, {__tostring = function(t) return string.format("R: %d, C: %d, T: %d, P: %s", t.column, t.row, t.team, t.type) end})
  
  return piece
end

function Piece.drawMoves()
  for k, piece in pairs(Board.pieces) do
    if piece.active then
      local r, g, b, a = love.graphics.getColor()
      love.graphics.setColor(piece.color[1], 255, piece.color[3], 255)
      
      for k2, move in pairs(piece.moves) do
        local x = Constants.BOARD_ORIGIN_X + ((move.row - 1) * (Constants.CELL_WIDTH + Constants.BORDER_SIZE))
        local y = Constants.BOARD_ORIGIN_Y + ((move.column - 1) * (Constants.CELL_HEIGHT + Constants.BORDER_SIZE))
        
        love.graphics.rectangle("fill", x, y, Constants.CELL_WIDTH, Constants.CELL_HEIGHT)
      end
      
      love.graphics.setColor(r, g, b, a)
    end
  end
end

function Piece.drawAttacks()
  for k, piece in pairs(Board.pieces) do
    if piece.active then
      local r, g, b, a = love.graphics.getColor()
      love.graphics.setColor(piece.color[1], 50, piece.color[3], 200)
      
      for k2, attack in pairs(piece.attacks) do
        local x = Constants.BOARD_ORIGIN_X + ((attack.row - 1) * (Constants.CELL_WIDTH + Constants.BORDER_SIZE))
        local y = Constants.BOARD_ORIGIN_Y + ((attack.column - 1) * (Constants.CELL_HEIGHT + Constants.BORDER_SIZE))
        
        love.graphics.rectangle("fill", x, y, Constants.CELL_WIDTH, Constants.CELL_HEIGHT)
      end
      
      love.graphics.setColor(r, g, b, a)
    end
  end
end

function Piece.drawBG()
  local r, g, b, a = love.graphics.getColor()
  
  for k, piece in pairs(Board.pieces) do  
    if piece.active then 
      love.graphics.setColor(0, 255, 0, 255)
      Sprite.draw(Piece.selected_sprite, piece.x, piece.y)
    elseif (Board.current_player == piece.team) then
      love.graphics.setColor(piece.color[1], 255, piece.color[3], 255)
      Sprite.draw(Piece.available_sprite, piece.x, piece.y)
    end
  end
  
  love.graphics.setColor(r, g, b, a)
end

function Piece.drawSprite()
  local r, g, b, a = love.graphics.getColor()
    
    for k, piece in pairs(Board.pieces) do
      love.graphics.setColor(piece.color[1], 127, piece.color[3], 255)
      Sprite.draw(piece.sprite, piece.x, piece.y)
    end
    
  love.graphics.setColor(r, g, b, a)
end

function Piece.drawHealth()
    local r, g, b, a = love.graphics.getColor()
    local font = love.graphics.getFont()
    love.graphics.setFont(Piece.font)
    
    for k, piece in pairs(Board.pieces) do
      local s = string.format("%.0f", (piece.health / piece.max_health) * 100)
    
      love.graphics.setColor(piece.color[1], piece.color[2], piece.color[3], 100)
      love.graphics.print(s, piece.x - (Constants.CELL_WIDTH / 2), piece.y - (Constants.CELL_HEIGHT / 2))
    end
    
  love.graphics.setColor(r, g, b, a)
  love.graphics.setFont(font)
end

return Piece