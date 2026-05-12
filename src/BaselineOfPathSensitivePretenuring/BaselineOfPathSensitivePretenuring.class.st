Class {
	#name : 'BaselineOfPathSensitivePretenuring',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfPathSensitivePretenuring',
	#package : 'BaselineOfPathSensitivePretenuring'
}

{ #category : 'baselines' }
BaselineOfPathSensitivePretenuring >> baseline: spec [

	<baseline>
	spec for: #common do: [
			self declarePackages: spec.
			self declareExternalDependencies: spec.
			self declareDependencyLinks: spec.
			self declareGroups: spec ]
]

{ #category : 'baselines' }
BaselineOfPathSensitivePretenuring >> declareDependencyLinks: spec [

	spec package: 'PathSensitivePretenuring' with: [ spec requires: #( 'SendersChainTransformer' 'VeritasBenchSuite' 'PretenuringAdviceAlgorithm' ) ].

]

{ #category : 'baselines' }
BaselineOfPathSensitivePretenuring >> declareExternalDependencies: spec [

	spec baseline: 'SendersChainTransformer'    with: [ spec repository: 'github://jordanmontt/senders-chain-transformer:main' ].
	"Veritas"
	spec baseline: 'VeritasBenchSuite'          with: [ spec repository: 'github://jordanmontt/PharoVeritasBenchSuite:main' ].
	spec baseline: 'VeritasCormas'              with: [ spec repository: 'github://jordanmontt/PharoVeritasBenchSuite:main' ].
	spec baseline: 'VeritasDataFrame'           with: [ spec repository: 'github://jordanmontt/PharoVeritasBenchSuite:main' ].
	spec baseline: 'VeritasMicrodown'           with: [ spec repository: 'github://jordanmontt/PharoVeritasBenchSuite:main' ].
	spec baseline: 'VeritasMoose'               with: [ spec repository: 'github://jordanmontt/PharoVeritasBenchSuite:main' ]
]

{ #category : 'baselines' }
BaselineOfPathSensitivePretenuring >> declareGroups: spec [

	spec group: 'default' with: #( 'core' ).
	spec group: 'core'    with: #( 'PathSensitivePretenuring' )
]

{ #category : 'baselines' }
BaselineOfPathSensitivePretenuring >> declarePackages: spec [

	spec package: 'PathSensitivePretenuring'
]
