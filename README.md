# xslt-sudoku
A Sudoku Solver in XSLT 2.0

This transform solves the popular Sudoku puzzle. It accepts the puzzle as 81 comma separated integers in the range 0 to 9, with zero representing empty.

It works by continuously reducing the number of possible values for each cell, and only when the possible values can't be reduced any further it starts backtracking.

The first phase attempts to populate as many cells of the board based on the start values. For each empty cell it works out the possible values using the "Naked Single", "Hidden Single" and "Naked Tuples" techniques in that order (see link below for more on the techniques). Cells where only one possible value exists are populated and then the second phase begins.

The second phase follows this process:

 - Find all empty cells and get all the possible values for each cell (using Naked Single and Hidden Single techniques)
 - Sort the cells by least possible values first
 - Populate the cells with only one possible value
 - If more there's more than one value, go through them one by one
 - Repeat

Although this version can solve nearly all boards in under a second, it's still a work in progress. If I get time I plan on:

 - Adding Naked Tuple discovery to the second phase
 - Adding Hidden Tuple discovery
 - Optimising the areas where sequences of integers are serialized to temporary trees and subsequently tokenized back into sequences.
 
(http://www.sadmansoftware.com/sudoku/solvingtechniques.php)
