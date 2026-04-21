Extension { #name : 'Dictionary' }

{ #category : '*PathSensitivePretenuring-Microdown-ApplicationMethod' }
Dictionary >> _pretenured_566281400_at: key put: anObject [
	"Set the value at key to be anObject.  If key is not found, create a
	new entry for key and set is value to anObject. Answer anObject."

	"(Dictionary new at: #color put: #blue; yourself) >>> (Dictionary new add: #color->#blue; yourself)"

	"(Dictionary new at: #color put: #blue; at: #color put: #red; yourself) >>> (Dictionary new add: #color->#red; yourself)"

	| index assoc |
	index := self findElementOrNil: key.
	assoc := array at: index.
	assoc
		ifNil: [
				self
					atNewIndex: index
					put: (Association _pretenured_566281400_key: key value: anObject) ]
		ifNotNil: [ assoc value: anObject ].
	^ anObject
]

{ #category : '*PathSensitivePretenuring-Microdown-ApplicationMethod' }
Dictionary >> _pretenured_986937019_at: key put: anObject [
	"Set the value at key to be anObject.  If key is not found, create a
	new entry for key and set is value to anObject. Answer anObject."

	"(Dictionary new at: #color put: #blue; yourself) >>> (Dictionary new add: #color->#blue; yourself)"

	"(Dictionary new at: #color put: #blue; at: #color put: #red; yourself) >>> (Dictionary new add: #color->#red; yourself)"

	| index assoc |
	index := self findElementOrNil: key.
	assoc := array at: index.
	assoc
		ifNil: [
				self
					atNewIndex: index
					put: (Association _pretenured_986937019_key: key value: anObject) ]
		ifNotNil: [ assoc value: anObject ].
	^ anObject
]
