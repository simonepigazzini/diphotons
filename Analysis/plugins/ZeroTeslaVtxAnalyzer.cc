#include <vector>
#include <map>

#include "TTree.h"
#include "TRandom.h"

#include "FWCore/Framework/interface/Frameworkfwd.h"
#include "FWCore/Framework/interface/Event.h"
#include "FWCore/Framework/interface/EventSetup.h"
#include "FWCore/Framework/interface/EDAnalyzer.h"
#include "FWCore/Framework/interface/MakerMacros.h"
#include "FWCore/Framework/interface/ConsumesCollector.h"
#include "FWCore/ParameterSet/interface/ParameterSet.h"
#include "FWCore/Utilities/interface/InputTag.h"
#include "FWCore/ServiceRegistry/interface/Service.h"
#include "CommonTools/UtilAlgos/interface/TFileService.h"
#include "DataFormats/Common/interface/View.h"
#include "DataFormats/Common/interface/Handle.h"
#include "DataFormats/VertexReco/interface/Vertex.h"

#include "flashgg/DataFormats/interface/DiPhotonCandidate.h"

using namespace std;
using namespace edm;

namespace diphotons
{
    class ZeroTeslaVtxAnalyzer : public EDAnalyzer {
    public:
        //---constructor from parameter set
        ZeroTeslaVtxAnalyzer(const ParameterSet&);
        //---destructor
        ~ZeroTeslaVtxAnalyzer(){};
        
    protected:
        //---process an event
        virtual void analyze(const Event&, const EventSetup&) override;

    private:
        TTree* tree_;
        int   nvtx=0;        
        float m=0;
        float m_beamspot=0;
        float m_genvtx=0;
        float pt=0;
        float l_pt=0;
        float sl_pt=0;
        float l_eta=0;
        float sl_eta=0;
        float l_sieie=0;
        float sl_sieie=0;
        float l_sipip=0;
        float sl_sipip=0;
        float l_trkIso=0;
        float sl_trkIso=0;
        float l_phoIso=0;
        float sl_phoIso=0;
        int l_eleVeto=0;
        int sl_eleVeto=0;
        float genZ=0;
        int   mvaVtx=0;
        float eeVtxZ=0;
        vector<int> original_idx;
        vector<float> recoZ;
        vector<int>   nTracks;
        vector<float> logsumpt2;
        vector<float> ptBal;
        vector<float> ptAsym;
        vector<float> pullConv;
        vector<float> nConv;
        vector<float> mva;

        Service<TFileService> fs_;
        EDGetTokenT<View<flashgg::DiPhotonCandidate> > diphoToken_;
        EDGetTokenT<View<reco::Vertex> > vertexToken_;
        EDGetTokenT<View<reco::Vertex> > dummyVertexToken_;
        float mass_point;
    };

    ZeroTeslaVtxAnalyzer::ZeroTeslaVtxAnalyzer(const ParameterSet& config):
        diphoToken_(consumes<View<flashgg::DiPhotonCandidate> >(config.getParameter<InputTag>("src"))),
        vertexToken_(consumes<View<reco::Vertex> >(config.getParameter<InputTag>("vtxs"))),
        dummyVertexToken_(consumes<View<reco::Vertex> >(config.getParameter<InputTag>("dummyVtx"))),
        mass_point(config.getParameter<double>("massPoint"))
    {
        tree_ = fs_->make<TTree>("vtxs_tree", "vtxs");
        tree_->Branch("mass_point", &mass_point, "mass_point/F");
        tree_->Branch("nvtx", &nvtx, "nvtx/I");
        tree_->Branch("m", &m, "m/F");
        tree_->Branch("m_genvtx", &m_genvtx, "m_genvtx/F");
        tree_->Branch("m_beamspot", &m_beamspot, "m_beamspot/F");
        tree_->Branch("pt", &pt, "pt/F");
        tree_->Branch("l_pt", &l_pt, "l_pt/F");
        tree_->Branch("sl_pt", &sl_pt, "sl_pt/F");                
        tree_->Branch("l_eta", &l_eta, "l_eta/F");
        tree_->Branch("sl_eta", &sl_eta, "sl_eta/F");
        tree_->Branch("l_sieie", &l_sieie, "l_sieie/F");
        tree_->Branch("sl_sieie", &sl_sieie, "sl_sieie/F");
        tree_->Branch("l_sipip", &l_sipip, "l_sipip/F");
        tree_->Branch("sl_sipip", &sl_sipip, "sl_sipip/F");
        tree_->Branch("l_trkIso", &l_trkIso, "l_trkIso/F");
        tree_->Branch("sl_trkIso", &sl_trkIso, "sl_trkIso/F");
        tree_->Branch("l_phoIso", &l_phoIso, "l_phoIso/F");
        tree_->Branch("sl_phoIso", &sl_phoIso, "sl_phoIso/F");
        tree_->Branch("l_eleVeto", &l_eleVeto, "l_eleVeto/I");
        tree_->Branch("sl_eleVeto", &sl_eleVeto, "sl_eleVeto/I");
        tree_->Branch("genZ", &genZ, "genZ/F");
        tree_->Branch("mvaVtx", &mvaVtx, "mvaVtx/I");
        tree_->Branch("eeVtxZ", &eeVtxZ, "eeVtxZ/F");
        tree_->Branch("original_idx", "std::vector<int>", &original_idx);
        tree_->Branch("recoZ", "std::vector<float>", &recoZ);
        tree_->Branch("nTracks", "std::vector<int>", &nTracks);
        tree_->Branch("logsumpt2", "std::vector<float>", &logsumpt2);
        tree_->Branch("ptBal", "std::vector<float>", &ptBal);
        tree_->Branch("ptAsym", "std::vector<float>", &ptAsym);
        tree_->Branch("pullConv", "std::vector<float>", &pullConv);
        tree_->Branch("nConv", "std::vector<float>", &nConv);
        tree_->Branch("mva", "std::vector<float>", &mva);
    }

    void ZeroTeslaVtxAnalyzer::analyze(const Event& event, const EventSetup& setup)
    {
        original_idx.clear();
        recoZ.clear();        
        nTracks.clear();
        logsumpt2.clear();
        ptBal.clear();
        ptAsym.clear();
        pullConv.clear();
        nConv.clear();
        mva.clear();
        
        Handle<View<flashgg::DiPhotonCandidate> > diphoHandle;
        event.getByToken(diphoToken_, diphoHandle);
        Handle<View<reco::Vertex> > vertexHandle;
        event.getByToken(vertexToken_, vertexHandle);
        Handle<View<reco::Vertex> > dummyVertexHandle;
        event.getByToken(dummyVertexToken_, dummyVertexHandle);

        if(diphoHandle->size() != 0)
        {
            flashgg::DiPhotonCandidate cand0 = diphoHandle->at(0);
            m = cand0.mass();
            pt = cand0.pt();
            genZ = cand0.genPV().z();
            mvaVtx = cand0.vertexIndex();
            l_pt = cand0.leadingPhoton()->pt();
            sl_pt = cand0.subLeadingPhoton()->pt();
            l_eta = cand0.leadingPhoton()->eta();
            sl_eta = cand0.subLeadingPhoton()->eta();
            l_sieie = cand0.leadingPhoton()->full5x5_sigmaIetaIeta();
            sl_sieie = cand0.subLeadingPhoton()->full5x5_sigmaIetaIeta();
            l_sipip = cand0.leadingPhoton()->sipip();
            sl_sipip = cand0.subLeadingPhoton()->sipip();
            l_trkIso = cand0.leadingView()->pfChNum03WrtChosenVtx();
            sl_trkIso = cand0.subLeadingView()->pfChNum03WrtChosenVtx();
            l_phoIso = cand0.leadingPhoton()->egPhotonIso();
            sl_phoIso = cand0.subLeadingPhoton()->egPhotonIso();
            l_eleVeto = cand0.leadingPhoton()->matchedGsfTrackInnerMissingHits() >= 0 ?
                cand0.leadingPhoton()->matchedGsfTrackInnerMissingHits() : 10;
            sl_eleVeto = cand0.subLeadingPhoton()->matchedGsfTrackInnerMissingHits() >= 0 ?
                cand0.subLeadingPhoton()->matchedGsfTrackInnerMissingHits() : 10;

            float lZ = cand0.leadingPhoton()->getMatchedEleVtx().z();
            float slZ = cand0.subLeadingPhoton()->getMatchedEleVtx().z();
            eeVtxZ = fabs(lZ-slZ)<0.1 ? (lZ+slZ)/2 : -999;

            float minDz=1e6;
            edm::Ptr<reco::Vertex> genVtx;
            for(auto& vtx : vertexHandle->ptrs())
            {
                float thisDz = fabs(vtx->z() - genZ);
                if(thisDz < minDz)
                {
                    minDz = thisDz;
                    genVtx = vtx;
                }
            }
            m_genvtx = flashgg::DiPhotonCandidate(cand0.leadingView()->originalPhoton(),
                                                  cand0.subLeadingView()->originalPhoton(),
                                                  genVtx).mass();
            m_beamspot = flashgg::DiPhotonCandidate(cand0.leadingView()->originalPhoton(),
                                                    cand0.subLeadingView()->originalPhoton(),
                                                    dummyVertexHandle->ptrs()[0]).mass();

            //---energy corrections
            float l_smear=1, sl_smear=1;            
            if(fabs(cand0.leadingPhoton()->eta()) < 1)
                l_smear = sqrt(gRandom->Gaus(1, 0.00862));
            else if(fabs(cand0.leadingPhoton()->eta()) < 1.5)
                l_smear = sqrt(gRandom->Gaus(1, 0.01364));
            else if(fabs(cand0.leadingPhoton()->eta()) < 2)
                l_smear = sqrt(gRandom->Gaus(1, 0.02205));
            else
                l_smear = sqrt(gRandom->Gaus(1, 0.02397));

            if(fabs(cand0.subLeadingPhoton()->eta()) < 1)
                sl_smear = sqrt(gRandom->Gaus(1, 0.00862));
            else if(fabs(cand0.subLeadingPhoton()->eta()) < 1.5)
                sl_smear = sqrt(gRandom->Gaus(1, 0.01364));
            else if(fabs(cand0.subLeadingPhoton()->eta()) < 2)
                sl_smear = sqrt(gRandom->Gaus(1, 0.02205));
            else
                sl_smear = sqrt(gRandom->Gaus(1, 0.02397));

            m = m*l_smear*sl_smear;
            m_genvtx = m_genvtx*l_smear*sl_smear;
            m_beamspot = m_beamspot*l_smear*sl_smear;
            
            auto vtxs = cand0.getVtxs();
            nvtx = cand0.nVtxInfoSize();
            for(int iVtx=0; iVtx<nvtx; ++iVtx)
            {
                original_idx.push_back(cand0.mvaSortedIndex(iVtx));
                recoZ.push_back(vtxs[iVtx]->z());
                nTracks.push_back(cand0.nTracks(iVtx));
                logsumpt2.push_back(cand0.logSumPt2(iVtx));
                ptBal.push_back(cand0.ptBal(iVtx));
                ptAsym.push_back(cand0.ptAsym(iVtx));
                pullConv.push_back(cand0.pullConv(iVtx));
                nConv.push_back(cand0.nConv(iVtx));
                mva.push_back(cand0.mva(iVtx));
            }
            tree_->Fill();
        }
    }
}

typedef diphotons::ZeroTeslaVtxAnalyzer diphotonsZeroTeslaVtxAnalyzer;
DEFINE_FWK_MODULE( diphotonsZeroTeslaVtxAnalyzer );


