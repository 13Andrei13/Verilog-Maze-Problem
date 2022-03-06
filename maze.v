`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Dunica David Gabriel 333AA
// 
// Create Date:    11:44:46 11/05/2021 
// Design Name: 
// Module Name:    maze 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module maze(
input 		          clk,
input [5:0]  starting_col, starting_row, 	// indicii punctului de start
input  			  maze_in, 			// ofera informa?ii despre punctul de coordonate [row, col]
output reg [5:0] row, col,	 		// selecteaza un rând si o coloana din labirint
output reg	 		  maze_oe,			// output enable (activeaza citirea din labirint la rândul ?i coloana date) - semnal sincron	
output reg			  maze_we, 			// write enable (activeaza scrierea în labirint la rândul ?i coloana date) - semnal sincron
output reg			  done = 0); 						// ie?irea din labirint a fost gasita; semnalul ramane activ 

integer dir = 0;      			  	// variabila ce retine directia de deplasare: 0-sus, 1-stanga, 2-jos, 3-dreapta
integer dir_check = 0;				// copie a directiei dir care se incrementeaza pentru a permite incercarea toturor celor 4 parti de acces ulterior 
reg[5:0] row_copy, col_copy; 		// copie a pozitiei anterioare
reg [5:0] state, next_state;

`define start					0		//starile automatului explicate in readme
`define try_around			1	
`define up_move				2
`define left_move				3
`define down_move				4
`define right_move 			5
`define check_empty			6		
`define move_and_check_end	7	
`define finish					8


always @(posedge clk) begin
	if(done == 0)
		state <= next_state;
end


always @(*) begin

maze_we=0;
maze_oe=0;
next_state = `start;

case(state)
	`start:begin									//stare de start in care imi setez valorile de row si col cu cele initiale si fac scrierea maze_we
		
		maze_we=1;
		row=starting_row;
		col=starting_col;
		next_state = `try_around;
		
	end
	
	`try_around:begin								//stare de incerca a casutelor alaturate 
		case(dir)
			0:begin
				next_state = `up_move;
			end
			1:begin
				next_state = `left_move;
			end
			2:begin
				next_state = `down_move;
			end
			3:begin
				next_state = `right_move;	
			end
		endcase
		dir = (dir + 1) % 4;			
	end
	
	`up_move:begin									//stare in care se incearca mutarea in sus
		
		maze_oe=1;
		dir_check=0;
		row_copy = row;
		col_copy = col;
		row=row-1;
		next_state = `check_empty;
		
	end
	
	`left_move:begin								//stare in care se incearca mutarea la stanga
		
		maze_oe=1;
		dir_check=1;
		row_copy = row;
		col_copy = col;
		col=col-1;
		next_state = `check_empty;
		
	end
	
	`down_move:begin								//stare in care se incearca mutarea in jos
		
		maze_oe=1;
		dir_check=2;
		row_copy = row;
		col_copy = col;
		row=row+1;
		next_state = `check_empty;
		
	end
	
	`right_move:begin								//stare in care se incearca mutarea in dreapta
	
		maze_oe = 1;
		dir_check = 3;
		row_copy = row;
		col_copy = col;
		col=col+1;
		next_state = `check_empty;
		
	end
	
	
	`check_empty:begin							//verific daca mutarea este disponibila (maze_in == 0) altfel se reintoarce la starea try_around
		if(maze_in == 0) begin
			next_state = `move_and_check_end;
			maze_we = 1;
		end else begin
			row = row_copy;
			col = col_copy;
			next_state = `try_around;
		end
	end

	`move_and_check_end:begin				 	//stare in care se modifica noua directie, se trece la urmatoarea stare de cautare in acea directie si de verificare daca s-a ajuns la finalul labiritului		
		dir = dir_check;
		if(col_copy == col && row_copy == row-1)begin		
			next_state = `left_move;
			end
		if(col_copy == col+1 && row_copy == row)begin		
			next_state = `up_move;
			end
		if(col_copy == col-1 && row_copy == row)begin		
			next_state = `down_move;
			end
		if(col_copy == col && row_copy == row+1 )begin		
			next_state = `right_move;
			end
		if(row==0 || row==63 || col==0 || col==63)
			next_state = `finish;
			
	end
	
	`finish: done = 1;							//stare de finish maze in care trebuie schimabta valoarea lui done in 1 pentru a opri loopul format de blocul always cu posedge clk (nu mai intra in if)


endcase
end


endmodule