Extension { #name : 'Rectangle' }

{ #category : '*PathSensitivePretenuring-Moose-LocationOfNew' }
Rectangle class >> _pretenured_339809099_origin: originPoint corner: cornerPoint [
	"Answer an instance of me whose corners (top left and bottom right) are
	determined by the arguments."

	^ self basicNewTenured setPoint: originPoint point: cornerPoint
]

{ #category : '*PathSensitivePretenuring-Moose-LocationOfNew' }
Rectangle class >> _pretenured_649422434_origin: originPoint corner: cornerPoint [
	"Answer an instance of me whose corners (top left and bottom right) are
	determined by the arguments."

	^ self basicNewTenured setPoint: originPoint point: cornerPoint
]

{ #category : '*PathSensitivePretenuring-Moose-LocationOfNew' }
Rectangle class >> _pretenured_745661664_origin: originPoint extent: extentPoint [
	"Answer an instance of me whose top left corner is originPoint and width by height is extentPoint. Note that extentPoint should be non negative since it represents the size of the rectangle"

	^ self basicNewTenured
		  setPoint: originPoint
		  point: originPoint x + (extentPoint x max: 0)
			  @ (originPoint y + (extentPoint y max: 0))
]

{ #category : '*PathSensitivePretenuring-Moose-LocationOfNew' }
Rectangle >> corners [
	"Return an array of corner points in the order of a quadrilateral spec for WarpBlt."

	^ Array
		  _pretenured_976194881_with: self topLeft
		  with: self bottomLeft
		  with: self bottomRight
		  with: self topRight
]

{ #category : '*PathSensitivePretenuring-Moose-LocationOfNew' }
Rectangle >> intersect: aRectangle ifNone: aBlock [
	"Answer a Rectangle that is the area in which the receiver overlaps with
	aRectangle.
	If there's no overlap, evaluate the block instead
	"

	| aPoint left right top bottom |
	(self intersects: aRectangle) ifFalse: [ ^ aBlock value ].
	aPoint := aRectangle origin.
	left := aPoint x max: origin x.
	top := aPoint y max: origin y.
	aPoint := aRectangle corner.
	right := aPoint x min: corner x.
	bottom := aPoint y min: corner y.
	^ Rectangle
		  _pretenured_339809099_origin: left @ top
		  corner: right @ bottom
]

{ #category : '*PathSensitivePretenuring-Moose-LocationOfNew' }
Rectangle >> translateBy: factor [
	"Answer a Rectangle translated by factor, a Point or a scalar."

	^ Rectangle
		  _pretenured_649422434_origin: origin + factor
		  corner: corner + factor
]
