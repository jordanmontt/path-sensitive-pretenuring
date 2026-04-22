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
	"Core"
	spec package: 'PathSensitivePretenuring' with: [ spec requires: #( 'SendersChainTransformer' 'VeritasBenchSuite' 'PretenuringAdviceAlgorithm' ) ].
	"Cormas"
	spec package: 'PathSensitivePretenuring-Cormas-ApplicationMethod' with: [ spec requires: #( 'VeritasCormas' 'PretenuringAdviceAlgorithm' ) ].
	spec package: 'PathSensitivePretenuring-Cormas-LocationOfNew'     with: [ spec requires: #( 'VeritasCormas' 'PretenuringAdviceAlgorithm' ) ].
	spec package: 'PathSensitivePretenuring-Cormas-CallerOfNew'       with: [ spec requires: #( 'VeritasCormas' 'PretenuringAdviceAlgorithm' ) ].
	"DataFrame"
	spec package: 'PathSensitivePretenuring-DataFrame-ApplicationMethod' with: [ spec requires: #( 'VeritasDataFrame' 'PretenuringAdviceAlgorithm' ) ].
	spec package: 'PathSensitivePretenuring-DataFrame-LocationOfNew'     with: [ spec requires: #( 'VeritasDataFrame' 'PretenuringAdviceAlgorithm' ) ].
	spec package: 'PathSensitivePretenuring-DataFrame-CallerOfNew'       with: [ spec requires: #( 'VeritasDataFrame' 'PretenuringAdviceAlgorithm' ) ].
	"Microdown"
	spec package: 'PathSensitivePretenuring-Microdown-ApplicationMethod' with: [ spec requires: #( 'VeritasMicrodown' 'PretenuringAdviceAlgorithm' ) ].
	spec package: 'PathSensitivePretenuring-Microdown-LocationOfNew'     with: [ spec requires: #( 'VeritasMicrodown' 'PretenuringAdviceAlgorithm' ) ].
	spec package: 'PathSensitivePretenuring-Microdown-CallerOfNew'       with: [ spec requires: #( 'VeritasMicrodown' 'PretenuringAdviceAlgorithm' ) ].
	"Moose"
	spec package: 'PathSensitivePretenuring-Moose-ApplicationMethod' with: [ spec requires: #( 'VeritasMoose' 'PretenuringAdviceAlgorithm' ) ].
	spec package: 'PathSensitivePretenuring-Moose-LocationOfNew'     with: [ spec requires: #( 'VeritasMoose' 'PretenuringAdviceAlgorithm' ) ].
	spec package: 'PathSensitivePretenuring-Moose-CallerOfNew'       with: [ spec requires: #( 'VeritasMoose' 'PretenuringAdviceAlgorithm' ) ]
]

{ #category : 'baselines' }
BaselineOfPathSensitivePretenuring >> declareExternalDependencies: spec [

	spec baseline: 'SendersChainTransformer'    with: [ spec repository: 'github://jordanmontt/senders-chain-transformer:main' ].
	spec baseline: 'PretenuringAdviceAlgorithm' with: [ spec repository: 'github://jordanmontt/Pretenuring-Advice-Algorithm:main' ].
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
	spec group: 'core'    with: #( 'PathSensitivePretenuring' ).
	"Cormas"
	spec group: 'cormas-applicationMethod' with: #( 'core' 'PathSensitivePretenuring-Cormas-ApplicationMethod' ).
	spec group: 'cormas-locationOfNew'     with: #( 'core' 'PathSensitivePretenuring-Cormas-LocationOfNew' ).
	spec group: 'cormas-callerOfNew'       with: #( 'core' 'PathSensitivePretenuring-Cormas-CallerOfNew' ).
	"DataFrame"
	spec group: 'dataFrame-applicationMethod' with: #( 'core' 'PathSensitivePretenuring-DataFrame-ApplicationMethod' ).
	spec group: 'dataFrame-locationOfNew'     with: #( 'core' 'PathSensitivePretenuring-DataFrame-LocationOfNew' ).
	spec group: 'dataFrame-callerOfNew'       with: #( 'core' 'PathSensitivePretenuring-DataFrame-CallerOfNew' ).
	"Microdown"
	spec group: 'microdown-applicationMethod' with: #( 'core' 'PathSensitivePretenuring-Microdown-ApplicationMethod' ).
	spec group: 'microdown-locationOfNew'     with: #( 'core' 'PathSensitivePretenuring-Microdown-LocationOfNew' ).
	spec group: 'microdown-callerOfNew'       with: #( 'core' 'PathSensitivePretenuring-Microdown-CallerOfNew' ).
	"Moose"
	spec group: 'moose-applicationMethod' with: #( 'core' 'PathSensitivePretenuring-Moose-ApplicationMethod' ).
	spec group: 'moose-locationOfNew'     with: #( 'core' 'PathSensitivePretenuring-Moose-LocationOfNew' ).
	spec group: 'moose-callerOfNew'       with: #( 'core' 'PathSensitivePretenuring-Moose-CallerOfNew' )
]

{ #category : 'baselines' }
BaselineOfPathSensitivePretenuring >> declarePackages: spec [

	spec package: 'PathSensitivePretenuring'.
	"Cormas"
	spec package: 'PathSensitivePretenuring-Cormas-ApplicationMethod'.
	spec package: 'PathSensitivePretenuring-Cormas-LocationOfNew'.
	spec package: 'PathSensitivePretenuring-Cormas-CallerOfNew'.
	"DataFrame"
	spec package: 'PathSensitivePretenuring-DataFrame-ApplicationMethod'.
	spec package: 'PathSensitivePretenuring-DataFrame-LocationOfNew'.
	spec package: 'PathSensitivePretenuring-DataFrame-CallerOfNew'.
	"Microdown"
	spec package: 'PathSensitivePretenuring-Microdown-ApplicationMethod'.
	spec package: 'PathSensitivePretenuring-Microdown-LocationOfNew'.
	spec package: 'PathSensitivePretenuring-Microdown-CallerOfNew'.
	"Moose"
	spec package: 'PathSensitivePretenuring-Moose-ApplicationMethod'.
	spec package: 'PathSensitivePretenuring-Moose-LocationOfNew'.
	spec package: 'PathSensitivePretenuring-Moose-CallerOfNew'
]
