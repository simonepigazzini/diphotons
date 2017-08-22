#!/bin/python

import ROOT

ROOT.gSystem.Load("libdiphotonsUtils")

f = ROOT.TFile.Open("full_analysis_spring17v1_sync_v1/bias_study_toys_from_mc_unbinned_pow4_EBEB.root")

w = f.Get("wtemplates")

xvar = w.var("mgg")
dset = w.data("toy_EBEB_0").reduce("mgg > 300 && mgg < 5500")

xvar.Print()
dset.Print()

pname = "dijet_EBEB"
linc = ROOT.RooRealVar("%s_lin" % pname, "%s_lin" % pname, 1., -100.0, 100.0)
logc = ROOT.RooRealVar("%s_log" % pname, "%s_log" % pname, 1., -100.0, 100.0)
linc.setVal(5.)
logc.setVal(-1.)
                        
## print "Using custom pdf RooPowLogPdf"
pdf = ROOT.RooPowLogPdf( pname, pname, xvar, linc, logc)
# else:
#     ## print "Using RooGenericPdf"
#     roolist = ROOT.RooArgList( xvar, linc, logc)
#     pdf = ROOT.RooGenericPdf( pname, pname, "TMath::Max(1e-50,pow(@0,@1+@2*log(@0)))", roolist )

gnll = pdf.createNLL(dset, ROOT.RooFit.Extended())
