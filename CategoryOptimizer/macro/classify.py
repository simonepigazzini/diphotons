#!/usr/bin/env python
# 
# --------------------------------------------
# Standard python import
from optparse import OptionParser, make_option
import fnmatch, glob, os, sys, json, itertools

objs = []

## ------------------------------------------------------------------------------------------------------------------------------------------------------
def mkChain(files, name="vtxOptTree",aliases={}):
    ### if len(files) == 1:
    ###     from ROOT import TFile
    ###     f = TFile.Open(files[0])
    ###     objs.append(f)
    ###     t=f.Get(name)
    ###     objs.append(t)
    ###     return t
    from ROOT import TChain
    chain = TChain(name)
    for f in files:
        print "Adding file %s" % f
        chain.AddFile(f)
    setAliases(chain,aliases)
    return chain

def setAliases(tree,aliases):
    for name,vdef in aliases.iteritems():
        tree.SetAlias(name,vdef)

## ------------------------------------------------------------------------------------------------------------------------------------------------------
def getListOfFiles( baseDir, filePattern, expr="{baseDir}/{filePattern}"):
    if baseDir.startswith("/store"):
        return [ "root://eoscms/%s" % f for f in eostools.listFiles( expr.format( baseDir=baseDir, filePattern="" ) )
                 if os.path.basename(f) == filePattern or fnmatch.fnmatch(f,filePattern) ]
    else:
        return glob.glob(expr.format( baseDir=baseDir, filePattern=filePattern))

## ------------------------------------------------------------------------------------------------------------------------------------------------------
def getTMVASettings(cfgs,dest):
    for cfg in cfgs.split(","):
        cf = open(cfg)
        settings = json.load(cf)
        for k,v in settings.iteritems():
            setattr(dest,k,v)
        cf.close()

# Main routine
def main(o,args):

    # Import TMVA classes from ROOT
    from ROOT import TMVA, TFile, TCut 

    print o

    # Output file
    if o.restrict:
        o.label += "_%s" % o.restrict
    outputFile = TFile( o.outfile % { "label" : o.label }, 'RECREATE' )

    atype="Classification"
    if hasattr(o,"type"):
        atype=str(o.type)
    factory = TMVA.Factory( "TMVAClassification", outputFile, 
                            "!V:!Silent:!Color:!DrawProgressBar:Transformations=I:AnalysisType=%s" % atype )

    # Set verbosity
    factory.SetVerbose( o.verbose )
    
    TMVA.Config.Instance().GetIONames().fWeightFileDir = o.weightsdir

    # variables 
    if type(o.variables) == str:
        o.variables = [ v.lstrip().rstrip() for v in o.variables.split(":") if v != "" ]
    allvars = ""
    for v in o.variables:
        factory.AddVariable( str(v) )
        if allvars != "": allvars += ":"
        allvars += v.split(":=")[0].lstrip(" ").rstrip(" ")
    print "variables %s" % allvars

    print o.spectators
    for s in o.spectators:
        if not s in o.variables:
            factory.AddSpectator( str(s) )

    # categories and sub categories   
    categories = []
    subcategories = [] 
    if hasattr(o,"subcategories") and len(o.subcategories) > 0:
        subcategories = o.subcategories[0]  
        for sc in o.subcategories[1:]:
            subcategories = map( lambda x : ( TCut(x[0][0])*TCut(x[1][0]), "%s_%s" % (x[0][1],x[1][1]) ), itertools.product(subcategories,sc) )
        
    for cut,name,vrs in o.categories:
        myvars = allvars
        if vrs != "":
            for v in vrs.split(":"):
                myvars = myvars.replace(v,"").replace("::",":")
            myvars = myvars.rstrip(":")
            
        vrs = str(myvars)
        print vrs
        
        if len(subcategories) > 0:
            for subcut,subname in subcategories:
                if subname == "":
                    subname = subname.replace(" ","").replace(">","_gt_").replace("<","_lt_").replace("=","_eq_").replace("&","_and_")
                fullname = "%s_%s" % (name,subname)
                categories.append( ( TCut(cut) * TCut(subcut),str(fullname),vrs) )
        else:
            categories.append( (TCut(cut),str(name),vrs) )

    if o.restrict:
        categories = filter( lambda x: x[1] == o.restrict, categories )

    # load tree
    selection = TCut(o.selection)
    if len(categories) == 1:
        selection *= categories[0][0]
        allvars = categories[0][2]
        categories = []
        o.categories = []
        
    aliases = {}
    for a in o.aliases:
        name,vdef = [ str(t.lstrip(" ").rstrip(" ")) for t in a.split(":=",1) ]
        aliases[name] = vdef

    if len(o.categories) > 0:
        allcats="(%s)" % ")||(".join([ c[0] for c in o.categories])
        print allcats
        selection = selection*TCut(allcats)
    tmp = TFile.Open("/tmp/musella/tmp%s.root"%o.label,"recreate")
    for evclass,info in o.classes.iteritems():
        samples = info["samples"]
        for samp in samples:
            if len(samp) == 4:
                name,weight,cut,ttype = samp
                friend = None
            else:
                name,weight,cut,ttype,friend = samp
            tcut=TCut(cut)*selection
            fullTree = mkChain(getListOfFiles(o.indir,o.files), name, aliases)
            selTree = fullTree.CopyTree(tcut.GetTitle())
            if friend:
                if type(friend) == str:
                    friends = [friend]
                else:
                    friends = friend                
                for ifr,friend in enumerate(friends):
                    fname,tname = friend.split("::")
                    friend = mkChain(getListOfFiles(o.indir,fname),tname)
                    friend.AddFriend(fullTree)
                    selFriend = friend.CopyTree(tcut.GetTitle())
                    if len(friends) == 1:
                        frname = "fr"
                    else:
                        frname = "fr%d" % ifr
                    selTree.AddFriend(selFriend,frname)

            setAliases(selTree,aliases)
            factory.AddTree( selTree, str(evclass), float(weight), TCut(""), int(ttype) )
        # weights
        if "weight" in info:
            weight = info["weight"]
            factory.AddSpectator( str("%s_wei := %s" % (evclass,weight)) )
            factory.SetWeightExpression( str(weight), str(evclass) )
        else:
            factory.SetWeightExpression( "1.", str(evclass) )

    # "SplitMode=Random" means that the input events are randomly shuffled before
    # splitting them into training and test samples
    factory.PrepareTrainingAndTestTree( TCut(""),
                                        "SplitMode=Random:NormMode=NumEvents:!V" )
    

    # --------------------------------------------------------------------------------------------------
    defaultSettings = { "BDT" :  "!H:!V:!CreateMVAPdfs:BoostType=Grad:UseBaggedGrad"
                                 ":GradBaggingFraction=0.6:SeparationType=GiniIndex:nCuts=20:NNodesMax=5"
                                 ":Shrinkage=0.3:NTrees=1000",
                        "Cuts" : "!H:!V:FitMethod=MC:EffSel:SampleSize=200000:VarProp=FSmart"
                        }
    if "FisherD" in o.methods:
        mname =  "FisherD%s" % o.label
        fcats = factory.BookMethod( TMVA.Types.kCategory, mname )
        
        for cut,name,vars in categories:        
            print "booking sub-category classifier : %s %s %s" % ( cut, name, vars )
            fcats.AddMethod(cut,
                            vars,TMVA.Types.kFisher,"%s_%s" % (mname,name),
                            "!H:!V:Fisher:!CreateMVAPdfs:VarTransform=D"
                            )

    if "Fisher" in o.methods or "LD" in o.methods:
        mname =  str("Fisher%s" % o.label)
        fcats = factory.BookMethod( TMVA.Types.kCategory, mname )
        
        for cut,name,vars in categories:        
            print "booking sub-category classifier : %s %s %s" % ( cut, name, vars )
            fcats.AddMethod(TCut(cut),
                            vars,TMVA.Types.kFisher,"%s_%s" % (mname,name),
                            "!H:!V:Fisher:!CreateMVAPdfs"
                            )

    if "Likelihood" in o.methods:
        mname =  "Likelihood%s" % o.label
        fcats = factory.BookMethod( TMVA.Types.kCategory, mname )
        
        for cut,name,vars in categories:        
            print "booking sub-category classifier : %s %s %s" % ( cut, name, vars )
            fcats.AddMethod(cut,
                            vars,TMVA.Types.kLikelihood,"%s_%s" % (mname,name),
                            "!H:!V:!CreateMVAPdfs:!TransformOutput:PDFInterpol=KDE:KDEtype=Gauss:KDEiter=Adaptive:KDEFineFactor=0.3:KDEborder=None:NAvEvtPerBin=150"
                            )

    if "LikelihoodD" in o.methods:
        mname =  "LikelihoodD%s" % o.label
        fcats = factory.BookMethod( TMVA.Types.kCategory, mname )
        
        for cut,name,vars in categories:        
            print "booking sub-category classifier : %s %s %s" % ( cut, name, vars )
            fcats.AddMethod(cut,
                            vars,TMVA.Types.kLikelihood,"%s_%s" % (mname,name),
                            "!H:!V:!CreateMVAPdfs:!TransformOutput:VarTransform=D:PDFInterpol=KDE:KDEtype=Gauss:KDEiter=Adaptive:KDEFineFactor=0.3:KDEborder=None:NAvEvtPerBin=150"
                            )

    if "BDT" in o.methods:
        mname =  str("BDT%s" % o.label)
        settings = defaultSettings["BDT"]
        if hasattr(o,"settings") and "BDT" in o.settings:
            settings = str(o.settings["BDT"])
        if len(categories) == 0:
            cats = factory.BookMethod(TMVA.Types.kBDT,mname,settings)
        else:
            cats = factory.BookMethod( TMVA.Types.kCategory, mname)
            
            for cut,name,vars in categories:
                print "booking sub-category classifier : %s %s %s" % ( cut, name, vars )
                cats.AddMethod(cut,
                               vars,TMVA.Types.kBDT,"%s_%s" % (mname,name),settings)

    if "Cuts" in o.methods:
        mname =  str("Cuts%s" % o.label)
        settings = defaultSettings["Cuts"]
        if hasattr(o,"settings") and "Cuts" in o.settings:
            settings = str(o.settings["Cuts"])
        if len(categories) == 0:
            cats = factory.BookMethod(TMVA.Types.kCuts,mname,settings)
        else:
            cats = factory.BookMethod( TMVA.Types.kCategory, mname)
            
            for cut,name,vars in categories:
                print "booking sub-category classifier : %s %s %s" % ( cut, name, vars )
                cats.AddMethod(cut,
                               vars,TMVA.Types.kCuts,"%s_%s" % (mname,name),settings)
            
    # ---- Now you can tell the factory to train, test, and evaluate the MVAs.
    if o.optimize:
        print "Optimizing?"
        factory.OptimizeAllMethods()
        
    factory.TrainAllMethods()
    factory.TestAllMethods()
    factory.EvaluateAllMethods()    
    
    # Save the output.
    outputFile.Close()

## ------------------------------------------------------------------------------------------------------------------------------------------------------    
if __name__ == "__main__":
    parser = OptionParser(option_list=[
            make_option("-i", "--indir",
                        action="store", type="string", dest="indir",
                        default="./",
                        help="input directory", metavar="DIR"
                        ),
            make_option("-f", "--files",
                        action="store", type="string", dest="files",
                        default="vtxOptReduction.root",
                        help="pattern of files to be read", metavar="PATTERN"
                        ), 
            make_option("-t", "--treeName",
                        action="store", type="string", dest="treename",
                        default="vtxOptTree",
                        help="TTree name", metavar="TREENAME"
                        ),
            make_option("-o", "--outfile",
                        action="store", type="string", dest="outfile",
                        default="tmva%(label)s.root",
                        help="outputfile", metavar="FILE"
                        ),
            make_option("-l", "--label",
                        action="store", type="string", dest="label",
                        default="",
                        help="label", metavar="LABEL"
                        ),
            make_option("-w", "--weightsdir",
                        action="store", type="string", dest="weightsdir",
                        default="weights",
                        help="tmva weights dir", metavar="DIR"
                        ),
            make_option("-V", "--variables",
                        action="store", dest="variables", type="string",
                        default="",
                        help="list of variables"
                        ),
            make_option("-A", "--aliases",
                        action="store", dest="aliases", type="string",
                        default={},
                        help="list of variables"
                        ),
            make_option("-T", "--tmvaSettings",
                        action="store", dest="tmvaSettings", type="string",
                        default="pervtx.json",
                        help="settings for the TMVA training"
                        ),
            make_option("-v", "--verbose",
                        action="store_true", dest="verbose",
                        default=False,
                        ),
            make_option("-O", "--optimize",
                        action="store_true", dest="optimize",
                        default=False,
                        ),
            make_option("-p","--parallel",action="store_true",default=False,dest="parallel"),
            make_option("-r","--restrict",action="store",default=None,dest="restrict",type="string"),
            ])

    (options, args) = parser.parse_args()
    getTMVASettings(options.tmvaSettings, options)

    sys.argv.append("-b")
    main(options, args)
