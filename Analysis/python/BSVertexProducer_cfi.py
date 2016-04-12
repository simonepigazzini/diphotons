import FWCore.ParameterSet.Config as cms

diphotonsBSVertexProducer = cms.EDProducer("diphotonsBSVertexProducer",
                                           bsTag = cms.InputTag('offlineBeamSpot')
                                   )
