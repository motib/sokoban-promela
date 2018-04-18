/*
  Print a push
*/
inline print_push(fromR, fromC, toR, toC) {
  printf("Push from %d %d to %d %d, boxes in goals %d\n",
     fromR, fromC, toR, toC, in_goal)
}

/*
  Print a move
*/
inline print_move(fromR, fromC, toR, toC) {
  printf("Move from %d %d to %d %d\n",
     fromR, fromC, toR, toC)
}

/*
  Print a Sokoban board using the XSB notation
*/
inline print_board() {
  byte r, c;
  for (r : 0 .. ROWS-1) {
    for (c : 0 .. COLS-1) {    
      if
         /* There is a warehouse man at this position */
      :: r == manR && c == manC ->
           if
           :: board[r].col[c] == TILE -> printf("@")
           :: board[r].col[c] == GOAL -> printf("+")
           fi
      :: else ->
        if
           /* Print the board tile type */
        :: board[r].col[c] == NONE          -> printf(" ")
        :: board[r].col[c] == WALL          -> printf("#")
        :: board[r].col[c] == TILE          -> printf(" ")
        :: board[r].col[c] == (TILE | OCCU) -> printf("$")
        :: board[r].col[c] == GOAL          -> printf(".")
        :: board[r].col[c] == (GOAL | OCCU) -> printf("*")
        fi
      fi
    };
    printf("\n")
  };
  printf("Boxes = %d, in goals = %d\n", boxes, in_goal);
}
