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
  attr_accessor :movement

  def initialize(movement)
    @movement = movement
  end

  def moves(gameboard)
  end

  def slide_moves(gameboard)
    movement[:slide].map do |slide|
      slide.take_while { |x,y| gameboard[x][y].nil? }
    end.flatten(1)
  end
end

describe Piece do
  context 'a basic piece' do
    let(:movement) do
      {
        slide: [
          [[1,1], [2,2], [3,3], [4,4]],
          [[-1,1], [-2,2], [-3,3], [-4,4]],
        ]
      }
    end
    let(:piece) { Piece.new(movement) }
    let(:all_moves) { movement[:slide].flatten(1) }
    it 'can slide anywhere on an empty board' do
      gb = Gameboard.new
      moves = piece.slide_moves(gb)
      expect(moves).to eq(all_moves)
    end
    it "can't slide where blocked" do
      # With a piece on (1,1) of our gameboard,
      # all sliding moves to that square and beyond
      # are blocked.
      gb = Gameboard.new
      gb[1][1] = 1
      moves = piece.slide_moves(gb)
      expect(moves).to eq(all_moves - [[1,1], [2,2], [3,3], [4,4]])
    end
  end
end
