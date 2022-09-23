macroscript L_MaxCoordsysCreate category:"L" toolTip:"Create coordsys" buttonText:"Max Coordsys Create" (

	DOT_EPS = 0.9995

	function minimum a b = ( if a < b then a else b )

	function swapEdge a = (
		tmp = a[1]
		a[1] = a[2]
		a[2] = tmp
	)

	function coordsys1 edgesPoints = (
		pair = edgesPoints[1]
		dirY = normalize (pair[2] - pair[1])
		dirZ = [0,0,1]
		if abs (dot dirZ dirY) > DOT_EPS then
			dirZ = [0,1,0]
		
		dirX = normalize (cross dirY dirZ)
		dirZ = normalize (cross dirX dirY)
		newCoordsys = (matrix3 dirX dirY dirZ [0,0,0])
		toolMode.coordsys #working_pivot
		WorkingPivot.setTM newCoordsys
	)

	function coordsys2 edgesPoints = (
		pair1 = edgesPoints[1]
		pair2 = edgesPoints[2]
		
		d11 = distance pair1[1] pair2[1]
		d12 = distance pair1[1] pair2[2]
		d1m = minimum d11 d12
		
		d21 = distance pair1[2] pair2[1]
		d22 = distance pair1[2] pair2[2]
		d2m = minimum d21 d22
		
		if d2m < d1m then
		(
			swapEdge pair1
			if d22 < d21 then
				swapEdge pair2
		)
		else
		(
			if d12 < d11 then
				swapEdge pair2
		)
		
		dirX = normalize (pair1[2] - pair1[1])
		dirY = normalize (pair2[2] - pair2[1])
		
		if abs(dot dirX dirY) > DOT_EPS then
		(
			print "Incorrect basis! Can not create coordinate system."
		)
		else
		(
			dirZ = normalize (cross  dirX dirY)
			if (dot [0,0,1] dirZ) < 0 then
				dirZ = dirZ * -1.0
			
			newCoordsys = (matrix3 dirX dirY dirZ [0,0,0])
			toolMode.coordsys #working_pivot
			WorkingPivot.setTM newCoordsys
		)
	)

	function coordsys3 edgesPoints = (
		pair1 = edgesPoints[1]
		pair2 = edgesPoints[2]
		pair3 = edgesPoints[3]
		
		d11 = distance pair1[1] pair2[1]
		d12 = distance pair1[1] pair2[2]
		d1m = minimum d11 d12
		
		d21 = distance pair1[2] pair2[1]
		d22 = distance pair1[2] pair2[2]
		d2m = minimum d21 d22
		
		if d2m < d1m then
		(
			swapEdge pair1
			if d22 < d21 then
				swapEdge pair2
		)
		else
		(
			if d12 < d11 then
				swapEdge pair2
		)
		
		d31 = distance pair1[1] pair3[1]
		d32 = distance pair1[1] pair3[2]
		if d32 < d31 then
				swapEdge pair3
		
		dirX = normalize (pair1[2] - pair1[1])
		dirY = normalize (pair2[2] - pair2[1])
		dirZ = normalize (pair3[2] - pair3[1])
		
		if abs(dot  dirX dirY) > DOT_EPS or abs(dot  dirX dirZ) > DOT_EPS or abs(dot  dirY dirZ) > DOT_EPS then
		(
			print "Incorrect basis! Can not create coordinate system."
		)
		else
		(
			newCoordsys = (matrix3 dirX dirY dirZ [0,0,0])
			toolMode.coordsys #working_pivot
			WorkingPivot.setTM newCoordsys
		)
	)

	function makeCoordsys edgesPoints = (
		case of (
			(edgesPoints.count == 1): coordsys1 edgesPoints
			(edgesPoints.count == 2): coordsys2 edgesPoints
			(edgesPoints.count == 3): coordsys3 edgesPoints
		)
	)
	
	function main = (
		theObj = (selection as array)[1]--modPanel.getCurrentObject()
		if theObj == undefined then (
			print "Object not selected!"
		)
		else (
			edgesPoints = #()
			
			if classof(theObj) == Editable_Poly then(
				--get selected edges
				edgesSelection = (polyOp.getEdgeSelection theObj) as array
				if (edgesSelection.count < 1) or (edgesSelection.count > 3) then (
					print "Wrong selected edge count! Should be 1,2,or 3!"
					return()
				)
				else (
					--extract point pairs
					for i = 1 to edgesSelection.count do (
						theVerts = (polyOp.getVertsUsingEdge theObj edgesSelection[i]) as array
						Mat = theObj.transform
						edgePoints = #(((polyOp.getVert theObj theVerts[1]) ),  ((polyOp.getVert theObj theVerts[2]) ))
						append edgesPoints edgePoints
					)
				)
			)else if classof(theObj) == PolyMeshObject then(
				currentMod = modpanel.getCurrentObject()

				if classof(currentMod) != Edit_Poly then (
					print("Currently only Edit Poly modifier is supported")
					return ()
				)

				edgesSelection = (currentMod.GetSelection #Edge) as array

				print ("Count: ")
				print (edgesSelection.count )

				if (edgesSelection.count < 1) or (edgesSelection.count > 3) then (
					print "Wrong selected edge count! Should be 1,2,or 3!"
					return()
				)else(
					--extract point pairs
					for i = 1 to edgesSelection.count do (
						theVerts = #()
						theVerts[1] = currentMod.GetEdgeVertex edgesSelection[i] 1
						theVerts[2] = currentMod.GetEdgeVertex edgesSelection[i] 2
						
						Mat = theObj.transform
						edgePoints = #(((currentMod.GetVertex theVerts[1]) ),  ((currentMod.GetVertex theVerts[2]) ))
						
						append edgesPoints edgePoints
					)
				)
				
			)else if classof(theObj) == Editable_Mesh then(
				print "Mesh selected"
				edgesSelection = (getEdgeSelection theObj) as array
				if (edgesSelection.count < 1) or (edgesSelection.count > 3) then (
					print "Wrong selected edge count! Should be 1,2,or 3!"
					return()
				)
				else (
					--extract point pairs
					for i = 1 to edgesSelection.count do (
						theVerts = (meshop.getVertsUsingEdge theObj edgesSelection[i]) as array
						Mat = theObj.transform
						edgePoints = #(((meshop.getVert theObj theVerts[1]) ),  ((meshop.getVert theObj theVerts[2])))  --#(((meshop.getVert theObj theVerts[1]) * Mat),  ((meshop.getVert theObj theVerts[2]) * Mat))
						append edgesPoints edgePoints
					)
				)
				print edgesSelection
			)else if (classof(theObj) == splineShape) or (classof(theObj) == line) then(
				subSplines = numSplines theObj
				for i = 1 to subSplines do (
					segs=(getSegSelection theObj i)
					maxSegs = numSegments theObj i
					for j = 1 to segs.count do (
						pair = #()
						nextP = segs[j] + 1
						
						if isClosed theObj i then(
							if nextP == maxSegs + 1 then(
								nextP = 1
							)
						)
						append pair (getKnotPoint theObj i segs[j])
						append pair (getKnotPoint theObj i nextP)
						append edgesPoints pair
					)
				)
			)else(
				print (classof(theObj))
				print "Unknown selected!!!"
				return()
			)
			
			makeCoordsys edgesPoints
		)
	)
	main()
)