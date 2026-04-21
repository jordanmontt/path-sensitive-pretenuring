Extension { #name : 'FMSlotMultivalueLink' }

{ #category : '*PathSensitivePretenuring-Moose-ApplicationMethod' }
FMSlotMultivalueLink >> uncheckUnsafeAdd: element [
	"Calls the implementation in OrderedCollection."

	super _pretenured_869662_addLast: element
]
