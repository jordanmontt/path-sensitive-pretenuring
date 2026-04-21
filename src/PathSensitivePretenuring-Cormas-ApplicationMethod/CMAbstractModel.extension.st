Extension { #name : 'CMAbstractModel' }

{ #category : '*PathSensitivePretenuring-Cormas-ApplicationMethod' }
CMAbstractModel class >> availableProbes [

	| colorString color |
	^ (Pragma allNamed: #probeNamed:color: in: self) collect: [ :pragma |
			  colorString := pragma arguments second.

			  color := [ CMColor perform: colorString asSymbol ] onErrorDo: [
				           Color _pretenured_186316203_fromHexString: colorString ].

			  CMProbe new
				  name: pragma arguments first;
				  color: color;
				  method: pragma method;
				  yourself ]
]
