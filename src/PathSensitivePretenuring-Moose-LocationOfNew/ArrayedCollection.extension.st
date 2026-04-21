Extension { #name : 'ArrayedCollection' }

{ #category : '*PathSensitivePretenuring-Moose-LocationOfNew' }
ArrayedCollection class >> _pretenured_976194881_with: firstObject _pretenured_976194881_with: secondObject _pretenured_976194881_with: thirdObject _pretenured_976194881_with: fourthObject [
	"Answer a new instance of me, containing only the three arguments as
	elements."

	| newCollection |
	newCollection := self newTenured: 4.
	newCollection at: 1 put: firstObject.
	newCollection at: 2 put: secondObject.
	newCollection at: 3 put: thirdObject.
	newCollection at: 4 put: fourthObject.
	^ newCollection
]
