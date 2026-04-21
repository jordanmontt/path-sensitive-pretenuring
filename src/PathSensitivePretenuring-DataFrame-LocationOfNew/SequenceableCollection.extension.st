Extension { #name : 'SequenceableCollection' }

{ #category : '*PathSensitivePretenuring-DataFrame-LocationOfNew' }
SequenceableCollection >> copyFrom: start to: stop [
	"Answer a copy of a subset of the receiver, starting from element at
	index start until element at index stop."

	| newSize |
	newSize := stop - start + 1.
	^ (self species newTenured: newSize)
		  replaceFrom: 1
		  to: newSize
		  with: self
		  startingAt: start
]
