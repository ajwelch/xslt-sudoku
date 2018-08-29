<xsl:stylesheet version="2.0"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:saxon="http://saxon.sf.net/"
xmlns:fn="sudoku"
exclude-result-prefixes="xs"
extension-element-prefixes="saxon fn">

<xsl:param name="board" select="(
7,0,0,	3,0,2,	0,5,0,
5,0,0,	0,0,0,	0,3,0,
0,6,4,	0,0,5,	0,0,0,

0,2,0,	8,0,4,	0,6,0,
1,0,0,	0,0,0,	0,0,4,
0,4,0,	7,0,1,	0,8,0,

0,0,0,	5,0,0,	2,7,0,
0,7,0,	0,0,0,	0,0,5,
0,9,0,	2,0,6,	0,0,3
)" as="xs:integer+"/>

<xsl:param name="verbose" select="false()" as="xs:boolean"/>

<xsl:variable name="oneToNine" select="(1,2,3,4,5,6,7,8,9)" as="xs:integer+"/>
<xsl:variable name="oneToEightyOne" select="(1 to 81)" as="xs:integer+"/>

<xsl:variable name="rowStarts"	select="(1, 10, 19,   28, 37, 46,  55, 64, 73)" as="xs:integer+"/>

<xsl:variable name="topLeftGroup"     select="(1, 2, 3,     10, 11, 12,  19, 20, 21)" as="xs:integer+"/>
<xsl:variable name="topGroup"         select="(4, 5, 6,     13, 14, 15,  22, 23, 24)" as="xs:integer+"/>
<xsl:variable name="topRightGroup"    select="(7, 8, 9,     16, 17, 18,  25, 26, 27)" as="xs:integer+"/>
<xsl:variable name="midLeftGroup"     select="(28, 29, 30,  37, 38, 39,  46, 47, 48)" as="xs:integer+"/>
<xsl:variable name="center"           select="(31, 32, 33,  40, 41, 42,  49, 50, 51)" as="xs:integer+"/>
<xsl:variable name="midRightGroup"    select="(34, 35, 36,  43, 44, 45,  52, 53, 54)" as="xs:integer+"/>
<xsl:variable name="bottomLeftGroup"  select="(55, 56, 57,  64, 65, 66,  73, 74, 75)" as="xs:integer+"/>
<xsl:variable name="bottomGroup"      select="(58, 59, 60,  67, 68, 69,  76, 77, 78)" as="xs:integer+"/>
<xsl:variable name="bottomRightGroup" select="(61, 62, 63,  70, 71, 72,  79, 80, 81)" as="xs:integer+"/>

<xsl:function name="fn:getRowStart" as="xs:integer+" saxon:memo-function="yes">
	<xsl:param name="index" as="xs:integer"/>
	<xsl:sequence select="xs:integer(floor(($index - 1) div 9) * 9) + 1"/>
</xsl:function>

<xsl:function name="fn:getRowNumber" as="xs:integer+" saxon:memo-function="yes">
	<xsl:param name="index" as="xs:integer"/>
	<xsl:sequence select="(($index - 1) idiv 9) + 1"/>
</xsl:function>

<xsl:function name="fn:getColNumber" as="xs:integer+" saxon:memo-function="yes">
	<xsl:param name="index" as="xs:integer"/>
	<xsl:sequence select="(($index - 1) mod 9) + 1"/>
</xsl:function>

<xsl:function name="fn:getRowIndexes" as="xs:integer+" saxon:memo-function="yes">
	<xsl:param name="index" as="xs:integer+"/>
	<xsl:sequence select="fn:getRowStart($index) to fn:getRowStart($index) + 8"/>
</xsl:function>

<xsl:function name="fn:getColIndexes" as="xs:integer+" saxon:memo-function="yes">
	<xsl:param name="index" as="xs:integer+"/>
	<xsl:variable name="gap" select="($index - 1) mod 9" as="xs:integer"/>
	<xsl:sequence select="for $x in $rowStarts return $x + $gap"/>
</xsl:function>

<xsl:function name="fn:getRow" as="xs:integer+">
	<xsl:param name="board" as="xs:integer+"/>
	<xsl:param name="index" as="xs:integer"/>
	<xsl:sequence select="subsequence($board, fn:getRowStart($index), 9)"/>
</xsl:function>

<xsl:function name="fn:getCol" as="xs:integer+">
	<xsl:param name="board" as="xs:integer+"/>
	<xsl:param name="index" as="xs:integer"/>
	<xsl:variable name="colIndexes" select="fn:getColIndexes($index)" as="xs:integer+"/>
	<xsl:sequence select="for $x in $colIndexes return $board[$x]"/>
</xsl:function>

<xsl:function name="fn:getGroupIndexes" as="xs:integer+" saxon:memo-function="yes">
	<xsl:param name="index" as="xs:integer+"/>
	<xsl:choose>
		<xsl:when test="$index = $topLeftGroup">
			<xsl:sequence select="$topLeftGroup"/>
		</xsl:when>
		<xsl:when test="$index = $topGroup">
			<xsl:sequence select="$topGroup"/>
		</xsl:when>
		<xsl:when test="$index = $topRightGroup">
			<xsl:sequence select="$topRightGroup"/>
		</xsl:when>
		<xsl:when test="$index = $midLeftGroup">
			<xsl:sequence select="$midLeftGroup"/>
		</xsl:when>
		<xsl:when test="$index = $center">
			<xsl:sequence select="$center"/>
		</xsl:when>
		<xsl:when test="$index = $midRightGroup">
			<xsl:sequence select="$midRightGroup"/>
		</xsl:when>
		<xsl:when test="$index = $bottomLeftGroup">
			<xsl:sequence select="$bottomLeftGroup"/>
		</xsl:when>
		<xsl:when test="$index = $bottomGroup">
			<xsl:sequence select="$bottomGroup"/>
		</xsl:when>
		<xsl:when test="$index = $bottomRightGroup">
			<xsl:sequence select="$bottomRightGroup"/>
		</xsl:when>
	</xsl:choose>
</xsl:function>

<xsl:function name="fn:getGroup" as="xs:integer+">
	<xsl:param name="board" as="xs:integer+"/>
	<xsl:param name="index" as="xs:integer+"/>
	<xsl:variable name="groupIndexes" select="fn:getGroupIndexes($index)" as="xs:integer+"/>
	<xsl:sequence select="for $x in $groupIndexes return $board[$x]"/>
</xsl:function>

<xsl:function name="fn:getOtherValuesInTriple" as="xs:integer+" saxon:memo-function="yes">
	<xsl:param name="num" as="xs:integer"/>
	<xsl:sequence select="(xs:integer(((($num -1) idiv 3) * 3) + 1) to xs:integer(((($num - 1) idiv 3) * 3) + 3))[. ne $num]"/>
</xsl:function>

<xsl:function name="fn:getRowFriends" as="xs:integer+">
	<xsl:param name="board" as="xs:integer+"/>
	<xsl:param name="index" as="xs:integer+"/>
	<xsl:sequence select="for $x in fn:getOtherValuesInTriple($index) return $board[$x]"/>
</xsl:function>

<xsl:function name="fn:getCellIndexesOfColFriends" as="xs:integer+" saxon:memo-function="yes">
	<xsl:param name="index" as="xs:integer"/>
	<xsl:sequence select="for $x in fn:getOtherValuesInTriple(fn:getRowNumber($index))
            return (($x * 9) - 8) + (($index - 1) mod 9)"/>
</xsl:function>

<xsl:function name="fn:getColFriends" as="xs:integer+">
	<xsl:param name="board" as="xs:integer+"/>
	<xsl:param name="index" as="xs:integer"/>
	<xsl:sequence select="for $x in fn:getCellIndexesOfColFriends($index) return $board[$x]"/>
</xsl:function>

<xsl:function name="fn:reducePossibleValues" as="xs:integer*">
	<xsl:param name="board" as="xs:integer+"/>
	<xsl:param name="index" as="xs:integer"/>
	<xsl:param name="possibleValues" as="xs:integer+"/>
	
	<xsl:variable name="rowFriends" select="fn:getRowFriends($board, $index)" as="xs:integer+"/>
	<xsl:variable name="colFriends" select="fn:getColFriends($board, $index)" as="xs:integer+"/>
	
	<xsl:variable name="otherRows" select="fn:getOtherValuesInTriple(fn:getRowNumber($index))" as="xs:integer+"/>
	<xsl:variable name="otherRow1" select="fn:getRow($board, 9 * $otherRows[1])" as="xs:integer+"/>
	<xsl:variable name="otherRow2" select="fn:getRow($board, 9 * $otherRows[2])" as="xs:integer+"/>
	
	<xsl:variable name="otherCol1" select="fn:getCol($board, fn:getOtherValuesInTriple($index)[1])" as="xs:integer+"/>
	<xsl:variable name="otherCol2" select="fn:getCol($board, fn:getOtherValuesInTriple($index)[2])" as="xs:integer+"/>
	
	<xsl:variable name="reducedValues" as="xs:integer*">
		<xsl:for-each select="$possibleValues">
			<xsl:if test=". = $otherCol1 and . = $otherCol2">
				<xsl:choose>
					<xsl:when test="not($colFriends = 0)">
						<xsl:sequence select="."/>
					</xsl:when>
					<xsl:when test="$colFriends != 0">
						<xsl:choose>
							<xsl:when test="$colFriends[1] eq 0">
								<xsl:if test=". = $otherRow1">
									<xsl:sequence select="."/>
								</xsl:if>
							</xsl:when>
							<xsl:when test="$colFriends[2] eq 0">
								<xsl:if test=". = $otherRow2">
									<xsl:sequence select="."/>
								</xsl:if>
							</xsl:when>
						</xsl:choose>
					</xsl:when>
				</xsl:choose>
			</xsl:if>
			<xsl:if test=". = $otherRow1 and . = $otherRow2">
				<xsl:choose>
					<xsl:when test="not($rowFriends = 0)">
						<xsl:sequence select="."/>
					</xsl:when>
					<xsl:when test="$rowFriends != 0">
						<xsl:choose>
							<xsl:when test="$rowFriends[1] eq 0">
								<xsl:if test=". = $otherCol1">
									<xsl:sequence select="."/>
								</xsl:if>
							</xsl:when>
							<xsl:when test="$rowFriends[2] eq 0">
								<xsl:if test=". = $otherCol2">
									<xsl:sequence select="."/>
								</xsl:if>
							</xsl:when>
						</xsl:choose>
					</xsl:when>
				</xsl:choose>
			</xsl:if>
		</xsl:for-each>
	</xsl:variable>
	
	<xsl:sequence select="if (count($reducedValues) eq 1) then $reducedValues else $possibleValues"/>
</xsl:function>


<xsl:function name="fn:removeNakedTuples" as="element()+">
	<xsl:param name="emptyCellsXML" as="element()+"/>
	<xsl:variable name="allowedValuesTable" as="element()+">
			<byRow>
				<xsl:for-each select="$rowStarts">
					<row>
						<xsl:for-each select="current() to current() + 8">
							<xsl:copy-of select="$emptyCellsXML[@index = current()]"/>
						</xsl:for-each>
					</row>
				</xsl:for-each>
			</byRow>
			<byCol>
				<xsl:for-each select="$oneToNine">
					<col>
						<xsl:for-each select="fn:getColIndexes(current())">
							<xsl:copy-of select="$emptyCellsXML[@index = current()]"/>
						</xsl:for-each>
					</col>
				</xsl:for-each>
			</byCol>
			<byBlock>
				<xsl:for-each select="(1, 4, 7, 28, 31, 34, 55, 58, 61)">
					<group>
						<xsl:for-each select="fn:getGroupIndexes(.)">
							<xsl:copy-of select="$emptyCellsXML[@index = current()]"/>
						</xsl:for-each>
					</group>
				</xsl:for-each>
			</byBlock>
	</xsl:variable>
	
	<xsl:variable name="newTable" as="element()+">
		<xsl:for-each select="$allowedValuesTable/row">
			<xsl:call-template name="nakedTuples"/>
		</xsl:for-each>
		<xsl:for-each select="$allowedValuesTable/col">
			<xsl:call-template name="nakedTuples"/>
		</xsl:for-each>
		<xsl:for-each select="$allowedValuesTable/group">
			<xsl:call-template name="nakedTuples"/>
		</xsl:for-each>
	</xsl:variable>
	
	<xsl:variable name="newDistinctTable" as="element()+">
		<xsl:for-each-group select="$newTable" group-by="@index">
			<xsl:copy-of select="current-group()[@possibleValues = min(current-group()/@possibleValues)][1]"/>
		</xsl:for-each-group>
	</xsl:variable>

	<xsl:sequence select="$newDistinctTable"/>
</xsl:function>


<xsl:template name="nakedTuples">
	<xsl:variable name="tuples" as="element()*">
		<xsl:for-each-group select="cell" group-by="@values">
			<xsl:if test="count(current-group()) > 1 and count(tokenize(current-grouping-key(), ' ')) = count(current-group())">
				<nakedTuple index="{current-group()/@index}" values="{current-grouping-key()}"/>
			</xsl:if>
		</xsl:for-each-group>
	</xsl:variable>

	<xsl:for-each select="cell">
		<xsl:variable name="tokens" select="for $x in tokenize(@values, ' ') return xs:integer($x)" as="xs:integer*"/>
		<xsl:variable name="tupleTokens" select="for $x in tokenize($tuples/@values, ' ') return xs:integer($x)" as="xs:integer*"/>
		<xsl:variable name="allowedValues" select="if (@index = tokenize($tuples/@index, ' ')) then $tokens
			else for $x in $tokens return $x[not(. = $tupleTokens)]" as="xs:integer*"/>
		<cell index="{@index}" tupleTokens="{$tupleTokens}" possibleValues="{count($allowedValues)}" values="{$allowedValues}"/>
	</xsl:for-each>
</xsl:template>


<xsl:function name="fn:getAllowedValues" as="xs:integer*">
	<xsl:param name="board" as="xs:integer+"/>
	<xsl:param name="index" as="xs:integer"/>
	
	<xsl:variable name="existingValues" select="(fn:getRow($board, $index), fn:getCol($board, $index), fn:getGroup($board, $index))" as="xs:integer*"/>
	<xsl:variable name="possibleValues" select="$oneToNine[not(. = $existingValues)]" as="xs:integer*"/>
	
	<xsl:choose>
		<xsl:when test="count($possibleValues) > 1">
			<xsl:sequence select="fn:reducePossibleValues($board, $index, $possibleValues)"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="$possibleValues"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>


<xsl:function name="fn:tryValues" as="xs:integer*">
	<xsl:param name="board" as="xs:integer+"/>
	<xsl:param name="emptyCells" as="xs:integer+"/>
	<xsl:param name="possibleValues" as="xs:integer+"/>
	
	<xsl:variable name="index" select="$emptyCells[1]" as="xs:integer"/>
	
	<xsl:variable name="newBoard" select="(subsequence($board, 1, $index - 1), $possibleValues[1], subsequence($board, $index + 1))" as="xs:integer+"/>
	
	<xsl:if test="$verbose">
		<xsl:message>
			<xsl:value-of select="concat('Trying ', $possibleValues[1], ' out of a possible ', string-join(for $i in $possibleValues return xs:string($i), ' '), ' at index ', $index)"/>
		</xsl:message>
	</xsl:if>
	
	<xsl:variable name="result" select="fn:populateValues($newBoard, subsequence($emptyCells, 2))" as="xs:integer*"/>
	
	<xsl:choose>
		<xsl:when test="not(empty($result))">
			<xsl:sequence select="$result"/>
		</xsl:when>
		<xsl:when test="count($possibleValues) eq 1">
			<xsl:sequence select="()"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="fn:tryValues($board, $emptyCells, subsequence($possibleValues, 2))"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>


<xsl:function name="fn:populateValues" as="xs:integer*">
	<xsl:param name="board" as="xs:integer+"/>
	<xsl:param name="emptyCells" as="xs:integer*"/>
	
	<xsl:choose>
		<xsl:when test="empty($emptyCells)">
			<xsl:message>Done!</xsl:message>
			<xsl:sequence select="$board"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:variable name="index" select="$emptyCells[1]" as="xs:integer"/>
			<xsl:variable name="possibleValues" select="fn:getAllowedValues($board, $index)" as="xs:integer*"/>
			<xsl:choose>
				<xsl:when test="count($possibleValues) eq 0">
					<xsl:if test="$verbose">
						<xsl:message>! Cannot go any further !</xsl:message>
					</xsl:if>
					<xsl:sequence select="()"/>
				</xsl:when>
				<xsl:when test="count($possibleValues) eq 1">
					<xsl:variable name="newBoard" select="(subsequence($board, 1, $index - 1), $possibleValues[1], subsequence($board, $index + 1))" as="xs:integer+"/>
					<xsl:if test="$verbose">
						<xsl:message>
							<xsl:value-of>Only one value <xsl:value-of select="$possibleValues[1]"/> for index <xsl:value-of select="$index"/></xsl:value-of>
						</xsl:message>
					</xsl:if>
					<xsl:sequence select="fn:populateValues($newBoard, subsequence($emptyCells, 2))"/>
				</xsl:when>
				<xsl:when test="count($possibleValues) > 1">
					<!-- Re-order the empty cells by least number of possible values first -->
					<xsl:variable name="emptyCellsReordered" select="fn:getEmptyCellsOrdered($board)" as="xs:integer+"/>
					<xsl:variable name="index" select="$emptyCellsReordered[1]" as="xs:integer"/>
					<xsl:variable name="possibleValues" select="fn:getAllowedValues($board, $index)" as="xs:integer*"/>
					<xsl:choose>
						<xsl:when test="count($possibleValues) eq 0">
							<xsl:if test="$verbose">
								<xsl:message>! Cannot go any further !</xsl:message>
							</xsl:if>
							<xsl:sequence select="()"/>
						</xsl:when>
						<xsl:when test="count($possibleValues) eq 1">
							<!-- The re-ordering has been successful and the first item only has one option -->
							<xsl:variable name="newBoard" select="(subsequence($board, 1, $index - 1), $possibleValues[1], subsequence($board, $index + 1))" as="xs:integer+"/>
							<xsl:sequence select="fn:populateValues($newBoard, subsequence($emptyCellsReordered, 2))"/>
						</xsl:when>
						<xsl:otherwise>
							<!-- The first item has multiple options still, so resort to brute force -->
							<xsl:sequence select="fn:tryValues($board, $emptyCellsReordered, $possibleValues)"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
			</xsl:choose>
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>


<xsl:function name="fn:populateSingleValueCells" as="xs:integer+">
	<xsl:param name="board" as="xs:integer+"/>
	<xsl:param name="emptyCellsXML" as="element()*"/>
	<xsl:for-each select="$oneToEightyOne">
		<xsl:variable name="pos" select="." as="xs:integer"/>
		<xsl:choose>
			<xsl:when test="$emptyCellsXML[@index = $pos]/@possibleValues = 1">
				<xsl:sequence select="$emptyCellsXML[@index = $pos]/@values"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="$board[$pos]"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:for-each>
</xsl:function>

<xsl:function name="fn:processEmptyCells" as="xs:integer+">
	<xsl:param name="board" as="xs:integer+"/>
	<xsl:variable name="emptyCells" select="for $x in (1 to 81) return $x[$board[$x] eq 0]" as="xs:integer*"/>
	<xsl:variable name="emptyCellsXML" as="element()*">
		<xsl:for-each select="$emptyCells">
			<xsl:variable name="possibleValues" select="fn:getAllowedValues($board, .)" as="xs:integer*"/>
			<cell index="{.}" possibleValues="{count($possibleValues)}" values="{$possibleValues}"/>
		</xsl:for-each>
	</xsl:variable>
	<xsl:choose>
		<xsl:when test="$emptyCellsXML/@possibleValues = 1">
			<xsl:variable name="newBoard" select="fn:populateSingleValueCells($board, $emptyCellsXML)" as="xs:integer+"/>
			<xsl:sequence select="fn:processEmptyCells($newBoard)"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:variable name="emptyCellsXML_afterRemovingNakedTuples" select="fn:removeNakedTuples($emptyCellsXML)" as="element()+"/>
			<xsl:variable name="newBoard" select="fn:populateSingleValueCells($board, $emptyCellsXML_afterRemovingNakedTuples)" as="xs:integer+"/>
			<xsl:sequence select="$newBoard"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>


<xsl:function name="fn:getEmptyCellsOrdered" as="xs:integer*">
	<xsl:param name="board" as="xs:integer+"/>
	<xsl:variable name="emptyCells" select="for $x in (1 to 81) return $x[$board[$x] eq 0]" as="xs:integer*"/>
	<xsl:variable name="emptyCellsOrdered" as="xs:integer*">
		<xsl:for-each select="$emptyCells">
			<xsl:sort select="count(fn:getAllowedValues($board, .))" data-type="number" order="ascending"/>
			<xsl:sequence select="."/>
		</xsl:for-each>
	</xsl:variable>
	<xsl:sequence select="$emptyCellsOrdered"/>
</xsl:function>


<xsl:function name="fn:solveSudoku" as="xs:integer+">
	<xsl:param name="startBoard" as="xs:integer+"/>
	<xsl:variable name="board" select="fn:processEmptyCells($startBoard)" as="xs:integer+"/>
	<xsl:variable name="endBoard" select="fn:populateValues($board, fn:getEmptyCellsOrdered($board))" as="xs:integer*"/>
	<xsl:choose>
		<xsl:when test="empty($endBoard)">
			<xsl:message>! Invalid board - The starting board is not correct</xsl:message>
			<xsl:sequence select="$startBoard"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="$endBoard"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>


<xsl:template match="/" name="main">
	<xsl:call-template name="drawBasicBoard">
		<xsl:with-param name="board" select="fn:solveSudoku($testBoard_AIEscargot)"/>
	</xsl:call-template>
</xsl:template>


<!-- Outputs the result as an HTML table -->
<xsl:template name="drawResult">
	<xsl:param name="board" as="xs:integer+"/>
	<html>
		<head>
			<title>Sudoku - XSLT</title>
			<style>
				table { border-collapse: collapse;
				border: 1px solid black; }
				td { padding: 10px; }
				.norm { border-left: 1px solid #CCC;border-top: 1px solid #CCC;}
				.csep { border-left: 1px solid black; }
				.rsep { border-top: 1px solid black; }
			</style>
		</head>
		<body>
			<table>
				<xsl:for-each select="1 to 9">
					<xsl:variable name="i" select="."/>
					<tr>
						<xsl:for-each select="1 to 9">
							<xsl:variable name="pos" select="(($i - 1) * 9) + ."/>
							<td class="{if (position() mod 3 = 1) then 'csep' else ('norm')} {if ($i mod 3 = 1) then 'rsep' else ('norm')}">
								<xsl:value-of select="$board[$pos]"/>
							</td>
						</xsl:for-each>
					</tr>
				</xsl:for-each>
			</table>
		</body>
	</html>
</xsl:template>


<!-- Outputs the result as text, for use from the command line -->
<xsl:template name="drawBasicBoard">
	<xsl:param name="board" as="xs:integer+"/>
	<xsl:text>&#xa;</xsl:text>
	<xsl:for-each select="1 to 9">
		<xsl:variable name="i" select="."/>
		<xsl:for-each select="1 to 9">
			<xsl:variable name="pos" select="(($i - 1) * 9) + ."/>
			<xsl:value-of select="$board[$pos]"/>
			<xsl:value-of select="if ($pos mod 3 = 0) then ',   ' else ', '"/>
		</xsl:for-each>
		<xsl:value-of select="if ($i mod 3 = 0) then '&#xa;&#xa;&#xa;' else '&#xa;'"/>
	</xsl:for-each>
</xsl:template>


<xsl:variable name="testBoard_Fiendish_060323" select="(
 5,3,0,  0,9,0,  0,0,6,
 0,0,0,  1,5,0,  0,0,3,
 0,0,2,  0,0,0,  8,0,0,

 0,0,0,  0,0,0,  0,8,0,
 1,7,0,  0,4,0,  0,2,9,
 0,9,0,  0,0,0,  0,0,0,

 0,0,6,  0,0,0,  3,0,0,
 4,0,0,  0,1,2,  0,0,0,
 3,0,0,  0,6,0,  0,5,4
)" as="xs:integer+"/>


<xsl:variable name="testBoard_Fiendish_060403" select="(
 5,0,0, 0,0,1, 0,0,2,
 0,6,0, 0,7,0, 0,0,0,
 0,0,0, 6,0,0, 8,0,0,

 0,0,3, 0,0,5, 0,0,8,
 0,9,0, 0,1,0, 0,2,0,
 2,0,0, 3,0,0, 7,0,0,

 0,0,1, 0,0,2, 0,0,0,
 0,0,0, 0,6,0, 0,9,0,
 8,0,0, 7,0,0, 0,0,5
)" as="xs:integer+"/>


<xsl:variable name="testBoard_AIEscargot" select="(
 1,0,0, 0,0,7, 0,9,0,
 0,3,0, 0,2,0, 0,0,8,
 0,0,9, 6,0,0, 5,0,0,

 0,0,5, 3,0,0, 9,0,0,
 0,1,0, 0,8,0, 0,0,2,
 6,0,0, 0,0,4, 0,0,0,

 3,0,0, 0,0,0, 0,1,0,
 0,4,0, 0,0,0, 0,0,7,
 0,0,7, 0,0,0, 3,0,0
)" as="xs:integer+"/>


<xsl:variable name="testBoard_OLD_WorldsHardest" select="(
 8,5,0, 0,0,2, 4,0,0,
 7,2,0, 0,0,0, 0,0,9,
 0,0,4, 0,0,0, 0,0,0,

 0,0,0, 1,0,7, 0,0,2,
 3,0,5, 0,0,0, 9,0,0,
 0,4,0, 0,0,0, 0,0,0,

 0,0,0, 0,8,0, 0,7,0,
 0,1,7, 0,0,0, 0,0,0,
 0,0,0, 0,3,6, 0,4,0
)" as="xs:integer+"/>


</xsl:stylesheet>