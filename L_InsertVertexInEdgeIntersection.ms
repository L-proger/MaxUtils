theObj = modPanel.getCurrentObject()
if theObj == undefined then
(
	print "Object not selected!"
)
else
(
	--get selected edges
	edgesSelection = (polyOp.getEdgeSelection theObj) as array
	if edgesSelection.count != 2 then
	(
		print "Wrong selected edge count! Should be 2"
	)
	else
	(
		edgesPoints = #()
		edgesVertices = #()
		
		--extract point pairs
		for i = 1 to edgesSelection.count do
		(
			theVerts = (polyOp.getVertsUsingEdge theObj edgesSelection[i]) as array
			append edgesVertices theVerts
			ef = (polyOp.getEdgeFaces theObj edgesSelection[i]) as array
			fv = polyOp.getFaceVerts theObj ef[1]
			
			id = -1
			--find v1 in face
			for j = 1 to fv.count do
			(
				if theVerts[1] == fv[j] then
				(
					id = j
				)
			)
			
			if id == -1 then
			(
				print "FAILED to detect vertex order!"
			)
			nextId =id + 1
			if nextId > fv.count then
			(
				 nextId = 1
			)
			
			--check to flip edge
			if fv[nextId] != theVerts[2] then
			(
				vtmp = theVerts[1]
				theVerts[1] = theVerts[2]
				theVerts[2] = vtmp
				print "FLIP EDGE"
			)
			
			
			
			edgePoints = #(polyOp.getVert theObj theVerts[1], polyOp.getVert theObj theVerts[2])
			append edgesPoints edgePoints
		)
		
		print edgesVertices
		
		SMALL_NUM = 0.00001
1
		S1 = edgesPoints[1]
		S2 = edgesPoints[2]
		1
		u = S1[2] - S1[1];
		v = S2[2] - S2[1];
		w = S1[1] - S2[1];
		a = dot u u         -- always >= 0
		b = dot u v
		c = dot v v         -- always >= 0
		d = dot u w
		
		Discrim = 10
		
		e_ = dot v w
		Discrim = (a*c) - (b*b)        -- always >= 0
		sc = Discrim
		sN = Discrim
		sD = Discrim
		tc = Discrim
		tN = Discrim
		tD = Discrim
		
	
		
		-- compute the line parameters of the two closest points
		if (Discrim < SMALL_NUM)  then ( -- the lines are almost parallel
			sN = 0.0         -- force using point P0 on segment S1
			sD = 1.0         -- to prevent possible division by 0.0 later
			tN = e_
			tD = c
			
		)
		else (                 -- get the closest points on the infinite lines
			sN = (b*e_ - c*d)
			tN = (a*e_ - b*d)
			
			if (sN < 0.0) then(        -- sc < 0 => the s=0 edge is visible
				
				sN = 0.0
				tN = e_
				tD = c
			)
			else (
				if (sN > sD) then (  -- sc > 1  => the s=1 edge is visible
					sN = sD
					tN = e_ + b
					tD = c
				)
			)
		)
	
	
		
		
		
		if (tN < 0.0) then (            -- tc < 0 => the t=0 edge is visible
			tN = 0.0
			-- recompute sc for this edge
			if (-d < 0.0) then(
				sN = 0.0
				
			)
			else (
				if (-d > a) then
				(
					sN = sD
				)
				else (
					sN = -d
					sD = a
				)
			)
		)
		else if (tN > tD) then (      -- tc > 1  => the t=1 edge is visible
			tN = tD
			-- recompute sc for this edge
			if ((-d + b) < 0.0) then
			(
				sN = 0
			)
			else (
				if ((-d + b) > a) then
				(
					sN = sD
				)
				else (
					sN = (-d +  b)
					
					sD = a
				)
			)
		)
	
		if ((abs sN) < SMALL_NUM) then
			sc = 0.0
		else
			sc = sN / sD
		
		
		if ((abs tN) < SMALL_NUM) then
			tc = 0.0
		else
			tc = tN / tD
		
		
		P1 = S1[1] + u * sc
		P2 = S2[1] + v * tc
		
		K1 = (distance S1[1] P1) / (distance S1[1] S1[2])
		K2 = (distance S2[1] P2) / (distance S2[1] S2[2])
		
		print K1
		print K2
		
		theObj.divideEdge edgesSelection[1] K1 select:on
		theObj.divideEdge edgesSelection[2] K2 select:on
	)
)