require 'spec_helper'

class Gameboard
  attr_accessor :board

  def initialize
    @board = 8.times.map { 8.times.map { nil } }
  end

  def [](*keys)
    board.send :[], *keys
  end
end

class Piece
  attr_accessor :movement, :position

  def initialize(movement)
    @movement = movement
    @position = nil
  end

  def moves(gameboard)
  end

  def t(x, y)
    # translate a piece's coordinate system to the gameboard's coordinate system
    return [position[0] + x, position[1] + y]
  end

  def slide_moves(gameboard)
    fail 'No possible moves without a position' unless position
    movement[:slide].map do |slide|
      slide
        .map { |x,y| t(x,y) }
        .reject { |x,y| x < 0 || y < 0 || x > 7 || y > 7 }  # out of bounds
        .take_while { |x,y| gameboard[x][y].nil? }  # blocked
    end.flatten(1)
  end
end

describe Piece do
  context 'a piece that can slide diagonally' do
    let(:movement) do
      {
        slide: [
          [[1, 1], [2, 2], [3, 3], [4, 4], [5, 5], [6, 6], [7, 7]],  # up and right
          [[-1, 1], [-2, 2], [-3, 3], [-4, 4], [-5, 5], [-6, 6], [-7,7]],  # up and left
        ]
      }
    end
    let(:piece) { Piece.new(movement) }
    it "raises an error unless a position is given" do
      gb = Gameboard.new
      expect { piece.slide_moves(gb) }.to raise_error('No possible moves without a position')
    end
    it 'can slide anywhere on an empty board' do
      gb = Gameboard.new
      piece.position = [2, 2]
      moves = piece.slide_moves(gb)
      # four squares up and right, plus two squares up and left
      available_moves =  [[3, 3], [4, 4], [5, 5], [6, 6], [7, 7], [1, 3], [0, 4]]
      expect(moves).to eq(available_moves)
    end
    it "can't slide where blocked" do
      # With this piece on (2, 2) of the gameboard, and another piece 
      # on (3, 3), all sliding moves up and to the right are blocked.
      gb = Gameboard.new
      gb[3][3] = 1
      piece.position = [2, 2]
      moves = piece.slide_moves(gb)
      # just up and left
      available_moves =  [[1, 3], [0, 4]]
      expect(moves).to eq(available_moves)
    end
  end
end
