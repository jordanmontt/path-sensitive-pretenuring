Extension { #name : 'FMMetaModelBuilder' }

{ #category : '*PathSensitivePretenuring-Moose-LocationOfNew' }
FMMetaModelBuilder >> processClass: aClass ifPragmaAbsent: anErrorBlock [

	aClass isTrait
		ifTrue: [ self processTrait: aClass ifPragmaAbsent: anErrorBlock ]
		ifFalse: [
				aClass metamodelDefinitionPragma
					ifNil: anErrorBlock
					ifNotNil: [ :pragma |
							| fm3Class |
							fm3Class := FM3Class _pretenured_609011553_named:
								            (pragma argumentAt: 1).
							aClass hasComment ifTrue: [ fm3Class comment: aClass comment ].
							superclassDict at: fm3Class put: (pragma argumentAt: 2).
							fm3Class implementingClass: aClass.
							(pragma method pragmaAt: #abstract) ifNotNil: [
								fm3Class isAbstract: true ].
							self extractPackageFrom: pragma method for: fm3Class.
							classDict at: aClass put: fm3Class.
							(self methodsToProcessFrom: aClass) do: [ :each |
								self processCompiledMethod: each ].
							aClass localSlots
								select: #isFMRelationSlot
								thenDo: [ :each | self processSlot: each in: aClass ].
							traitsDict at: fm3Class put: aClass localGeneratedTraits.
							elements add: fm3Class ] ]
]

{ #category : '*PathSensitivePretenuring-Moose-LocationOfNew' }
FMMetaModelBuilder >> processCompiledMethod: aMethod [

	| method |
	method := aMethod.

	"If the method is a reflective method we need to ensure it is compiled and use its compiled method.
	A refelctive method is for exemple a method created via a metalink and that was never executed."
	(aMethod isKindOf: ReflectiveMethod) ifTrue: [
			method := aMethod
				          compileAndInstallCompiledMethod;
				          compiledMethod ].
	"self assert: method isCompiledMethod."

	"29 of October 2019: The MSEProperty:type:(opposite:) pragma is deprecated and should not be used anymore. But we still keep it for some time for backward compatibility."
	method pragmas
		detect: [ :each |
				#( #MSEProperty:type:opposite: #MSEProperty:type:
				   #FMProperty:type:opposite: #FMProperty:type: #FMProperty:type:defaultValue: )
					includes: each selector ]
		ifFound: [ :pragma |
				| prop |
				prop := FM3Property _pretenured_369319273_named:
					        (pragma argumentAt: 1) asString.
				method comment ifNotNil: [ :c | prop comment: c ].
				typeDict at: prop put: (pragma argumentAt: 2).
				mmClassDict at: prop put: method methodClass.
				pragma selector = #FMProperty:type:defaultValue: ifTrue: [
					prop defaultValue: (pragma argumentAt: 3) ].
				(pragma selector = #FMProperty:type: and: [
						 method pragmas anySatisfy: [ :p |
							 p selector = #withDefaultValueFromType ] ]) ifTrue: [
					prop hasDefaultValueFromType: true ].
				(pragma selector = #MSEProperty:type:opposite: or: [
					 pragma selector = #FMProperty:type:opposite: ]) ifTrue: [
					oppositeDict at: prop put: (pragma argumentAt: 3) ].
				self processInfosFrom: method for: prop.

				elements add: prop ]
]

{ #category : '*PathSensitivePretenuring-Moose-LocationOfNew' }
FMMetaModelBuilder >> processSlot: aSlot in: aClass [

	| prop |
	prop := FM3Property _pretenured_849575263_named: aSlot name.
	prop implementingSelector: aSlot name.
	prop isMultivalued: aSlot isToMany.

	typeDict at: prop put: aSlot targetClass.
	mmClassDict at: prop put: aClass.
	oppositeDict at: prop put: aSlot inverseName.

	aClass
		compiledMethodAt: aSlot name asSymbol
		ifPresent: [ :aMethod | self processInfosFrom: aMethod for: prop ].

	elements add: prop
]
