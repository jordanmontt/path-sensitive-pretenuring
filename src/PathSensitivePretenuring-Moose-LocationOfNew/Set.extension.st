Extension { #name : 'Set' }

{ #category : '*PathSensitivePretenuring-Moose-LocationOfNew' }
Set >> grow [
	"Grow the elements array and reinsert the old elements"

	| oldElements |
	oldElements := array.
	array := Array newTenured:
		         (HashTableSizes atLeast: oldElements size * 2).
	tally := 0.
	oldElements do: [ :element |
		element ifNotNil: [ self noCheckAdd: element enclosedElement ] ]
]
