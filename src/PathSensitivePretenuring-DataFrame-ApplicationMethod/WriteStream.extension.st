Extension { #name : 'WriteStream' }

{ #category : '*PathSensitivePretenuring-DataFrame-ApplicationMethod' }
WriteStream >> _pretenured_669254415_contents [

	readLimit := readLimit max: position.
	^ collection _pretenured_669254415_copyFrom: 1 to: position
]
