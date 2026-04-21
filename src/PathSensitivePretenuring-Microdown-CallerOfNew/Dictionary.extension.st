Extension { #name : 'Dictionary' }

{ #category : '*PathSensitivePretenuring-Microdown-CallerOfNew' }
Dictionary >> _pretenured_167547469_at: key put: anObject [
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
					put: (Association _pretenured_167547469_key: key value: anObject) ]
		ifNotNil: [ assoc value: anObject ].
	^ anObject
]
