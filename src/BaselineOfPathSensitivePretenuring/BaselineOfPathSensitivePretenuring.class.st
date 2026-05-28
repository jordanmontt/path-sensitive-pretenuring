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

	spec package: 'PathSensitivePretenuring-BagOfStacks' with: [
		spec requires: #( 'SendersChainTransformer' ) ].

	spec package: 'PathSensitivePretenuring-BagOfStacks-Tests' with: [
		spec requires: #( 'PathSensitivePretenuring-BagOfStacks' ) ].

	spec package: 'PathSensitivePretenuring' with: [
		spec requires: #( 'PathSensitivePretenuring-BagOfStacks' 'SendersChainTransformer' 'VeritasBenchSuite' ) ].

	spec package: 'PathSensitivePretenuring-Legacy' with: [
		spec requires: #( 'SendersChainTransformer' ) ].

	spec package: 'PathSensitivePretenuring-Legacy-Tests' with: [
		spec requires: #( 'PathSensitivePretenuring-Legacy' ) ]
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
	spec group: 'core'    with: #( 'PathSensitivePretenuring' 'PathSensitivePretenuring-BagOfStacks' ).
	spec group: 'tests'   with: #( 'core' 'PathSensitivePretenuring-BagOfStacks-Tests' ).
	spec group: 'Legacy'  with: #( 'PathSensitivePretenuring-Legacy' ).
	spec group: 'Legacy-Tests' with: #( 'PathSensitivePretenuring-Legacy' 'PathSensitivePretenuring-Legacy-Tests' )
]

{ #category : 'baselines' }
BaselineOfPathSensitivePretenuring >> declarePackages: spec [

	spec package: 'PathSensitivePretenuring-BagOfStacks'.
	spec package: 'PathSensitivePretenuring-BagOfStacks-Tests'.
	spec package: 'PathSensitivePretenuring'.
	spec package: 'PathSensitivePretenuring-Legacy'.
	spec package: 'PathSensitivePretenuring-Legacy-Tests'
]
