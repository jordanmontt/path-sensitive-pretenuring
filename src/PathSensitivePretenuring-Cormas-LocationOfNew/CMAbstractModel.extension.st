Extension { #name : 'CMAbstractModel' }

{ #category : '*PathSensitivePretenuring-Cormas-LocationOfNew' }
CMAbstractModel >> newEntity: aClass [
	"Creates a new instance of aClass and collects it, immediately, at the level of theXXXs collection."

	| anEntity |
	anEntity := aClass basicNewTenured
		            cormasModel: self;
		            randomNumberGenerator: randomNumberGenerator;
		            initialize;
		            yourself.

	self collectEntity: anEntity.
	^ anEntity
]
