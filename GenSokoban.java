/*
                       GenSokoban
  Generate a Promela program from XSB format

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

import java.io.*;
public class GenSokoban {
	static private PrintWriter writer;
  static private BufferedReader reader;

  public static void Usage() {
    System.out.println(
      "Usage: GenSokoban fileName (without extension)\n" +
      "  Converts filename.txt in XSB format to filename-puzzle.pml\n" +
      "  and filename-sizes.pml for Promela Sokoban solver");
    System.exit(1);
  }

	public static void main(String[] args) {
    /* Input buffer string */
    String s;
    /* Row and column counters */
    int row = 0, col;
    /*  Maxcol for printing longest column length */
    int maxcols = 0;
    /* Number of boxes and number of boxes in goal tiles */
    int boxes = 0, in_goal = 0;

	  if (args.length < 1) Usage();

	  try {
      /* Open files */
      reader = new BufferedReader(new FileReader(args[0]+".txt"));
 			writer = new PrintWriter(new FileWriter(args[0]+"-puzzle.pml"));

      /* Read and process rows; terminate with null or blank line*/
      do {
        s = reader.readLine();
        if (s == null || s == "") break;
        col = 0;
        /* Write Promela assignment statement for each character */
        while (col < s.length()) {
          writer.print("  board[" + row + "].col[" + col + "] = ");
          switch (s.charAt(col)) {
            case ' ': writer.print("TILE"); break;
            case '@': writer.print("TILE"); break;
            case '$': writer.print("TILE | OCCU");
                      boxes++; break;
            case '#': writer.print("WALL"); break;
            case '.': writer.print("GOAL"); break;
            case '+': writer.print("GOAL"); break;
            case '*': writer.print("GOAL | OCCU");
                      boxes++; in_goal++; break;
            default: System.err.println("Bad input: " + s);
          }
          writer.println(";");

          /* Assign row and column of warehouse man */
          if ((s.charAt(col) == '@') || (s.charAt(col) == '+'))
            writer.println("  manR = " + row + ";\n  manC = " + col + ";");

          col++;
        }

        if (col > maxcols) maxcols = col;
        row++;
      } while (true);

      /* Assign number of boxes and number in goal tiles */
      writer.println("  boxes = " + boxes + ";");
      writer.println("  in_goal = " + in_goal + ";");
      reader.close();
      writer.close();

      /* Write file with row and column sizes and print out */
 			writer = new PrintWriter(new FileWriter(args[0]+"-sizes.pml"));
      writer.println("#define ROWS " + row + "\n#define COLS " + maxcols);
      System.out.println("Rows = " + row + ", cols = " + maxcols);
      writer.close();
    }
    catch (IOException e) {
      System.out.println("IO error"); 
    }
  }
}
