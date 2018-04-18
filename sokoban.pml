/*
            Sokoban Solver in Promela
                  Moti Ben-Ari
    http://www.weizmann.ac.il/sci-tea/benari/

    Copyright 2013 by Mordechai (Moti) Ben-Ari.

  This program is free software; you can redistribute it and/or
  modify it under the terms of the GNU General Public License
  as published by the Free Software Foundation; either version 2
  of the License, or (at your option) any later version.
  This program is distributed in the hope that it will be useful
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  See the GNU General Public License for more details.
  You should have received a copy of the GNU General Public License
  along with this program; if not, write to the Free Software
  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
  02111-1307, USA.
*/

/*
  Number of rows and columns on Sokoban board read from include file:
    #define ROWS  ...
    #define COLS  ...
*/
#include "sizes.pml"

/*
  Codes for wall, floor tile, goal floor tile
  OCCU = tile is occupied by a box
         A wall tile is considered to be occupied
*/
#define OCCU  8
#define WALL  12
#define TILE  2
#define GOAL  1
#define NONE  0

/*
  Two dimensional array for the Sokoban board
*/
typedef rows {
  byte col[COLS]
};
rows board[ROWS];

/*
  Counts of the total number of boxes and the number in a goal tile
*/
byte boxes;
byte in_goal;

/*
  Row and column of the warehouse man
*/
byte manR, manC;

/*
  Printing utilities in a separate file
*/
#include "print.pml"

/*
  Move box from (r1,c1) to (r2,c2)
  Adjust in_goal: vacating the current tile and moving to a new tile
  Terminate when in_goal == boxes
*/
inline push_box(r1, c1, r2, c2) {
  board[r1].col[c1] = (board[r1].col[c1] & (~OCCU));
  if
  :: board[r1].col[c1] == GOAL -> in_goal--
  :: else -> skip
  fi;
  if
  :: board[r2].col[c2] == GOAL -> in_goal++;
  :: else -> skip
  fi;
  board[r2].col[c2] = (board[r2].col[c2] | OCCU);
  print_push(r1, c1, r2, c2);
  assert (in_goal < boxes)
}

/*
  Move the man by +/-1 rows and 0 columns or 0 rows and +/-1 columns
  If the destination tile is occupied by a box, push the box
*/
inline move(dr, dc) {
  if
  :: dr != 0 ->
       if
       :: (board[manR+dr].col[manC] & OCCU) == OCCU ->    
            push_box(manR+dr, manC, manR+2*dr, manC)
       :: else -> skip
       fi;
  :: dc != 0 ->
       if
       :: (board[manR].col[manC+dc] & OCCU) == OCCU ->
            push_box(manR, manC+dc, manR, manC+2*dc)
       :: else -> skip
       fi;
  fi;
  print_move(manR, manC, manR+dr, manC+dc);
  manR = manR + dr;
  manC = manC + dc
}

/*
  Active process
  Include the file "puzzle.pml" with the Soboban puzzle to be solved
  The man can be moved up/down one row or left/right one column
  The man cannot be moved to a wall tile
  The destination tile must not be occupied by a box or
    it must be possible to move the box in the same direction
*/
active proctype Sokoban() {
  #include "puzzle.pml"
  print_board();

  do
  ::  (board[manR+1].col[manC] != WALL) &&
      (((board[manR+1].col[manC] & OCCU) != OCCU) ||
       ((board[manR+2].col[manC] & OCCU) != OCCU)
      ) -> d_step { move(1, 0) }
  ::  board[manR-1].col[manC] != WALL &&
      (((board[manR-1].col[manC] & OCCU) != OCCU) ||
       ((board[manR-2].col[manC] & OCCU) != OCCU)
      ) -> d_step { move(-1, 0) }
  ::  board[manR].col[manC+1] != WALL &&
      (((board[manR].col[manC+1] & OCCU) != OCCU) ||
       ((board[manR].col[manC+2] & OCCU) != OCCU)
      ) -> d_step { move(0, 1) }
  ::  board[manR].col[manC-1] != WALL &&
      (((board[manR].col[manC-1] & OCCU) != OCCU) ||
       ((board[manR].col[manC-2] & OCCU) != OCCU)
      ) -> d_step { move(0, -1) }
  od
}
