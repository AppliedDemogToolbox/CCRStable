##########
##HAMILTON-PERRY WITH COMPONENTS AND STABLE POPULATION INFORMATION PROJECTION CODE
##
##EDDIE HUNSINGER, AUGUST 2019 (UPDATED OCTOBER 2020)
##https://edyhsgr.github.io/eddieh/
##
##FORKED FOR APPLIED DEMOGRAPHY TOOLBOX SHARING, FROM GITHUB REPOSITORY AT https://github.com/edyhsgr/CCRStable
##RELATED SHINY APP AT https://shiny.demog.berkeley.edu/eddieh/CCRStable/
##
##IF YOU WOULD LIKE TO USE, SHARE OR REPRODUCE THIS CODE, PLEASE CITE THE SOURCE
##This work is licensed under a Creative Commons Attribution-ShareAlike 3.0 International License (more information: https://creativecommons.org/licenses/by-sa/3.0/igo/).
##
##EXAMPLE DATA IS LINKED, SO YOU SHOULD BE ABLE TO SIMPLY COPY ALL AND PASTE INTO R TO SEE IT WORK
##
##THERE IS NO WARRANTY FOR THIS CODE
##THIS CODE HAS NOT BEEN PEER-REVIEWED OR CAREFULLY TESTED - QUESTIONS AND COMMENTS ARE WELCOME, OF COURSE (edyhsgr@gmail.com)
##########

##########
##READING EXTERNAL DATA IN
##########

##DATA (CENSUS BUREAU VINTAGE 2018 POPULATION ESTIMATES BY DEMOGRAPHIC CHARACTERISTICS)
##https://www2.census.gov/programs-surveys/popest/datasets/2010-2018/counties/asrh/cc-est2018-alldata-06.csv 
##https://www2.census.gov/programs-surveys/popest/technical-documentation/file-layouts/2010-2018/
K<-data.frame(read.table(file="https://raw.githubusercontent.com/AppliedDemogToolbox/CCRStable/master/cc-est2018-alldata-06_Extract.csv",header=TRUE,sep=","))

##CENSUS ACS (via IPUMS) CA MIGRATION DATA (GENERIC)
Migration<-data.frame(read.table(file="https://raw.githubusercontent.com/AppliedDemogToolbox/CCRStable/master/AGenericMigrationProfile_CA_2013to2017ACS.csv",header=TRUE,sep=","))
Migration<-c(Migration$CA_F,Migration$CA_M)

##USMD CA SURVIVAL DATA (GENERIC)
lt<-read.table(file="https://raw.githubusercontent.com/AppliedDemogToolbox/CCRStable/master/lt_CA_USMD2010to2014.csv",header=TRUE,sep=",")
lxF<-lt$lx_Female/100000
lxM<-lt$lx_Male/100000
lxT<-lt$lx_Both/100000
lxF<-c(lxF[1],lxF[3:24])
lxM<-c(lxM[1],lxM[3:24])
lxT<-c(lxT[1],lxT[3:24])

##########
##SCRIPT INPUTS
##########

##DIMENSIONS
SIZE<-36
HALFSIZE<-SIZE/2
STEPS<-(2030-2015)/5
STEPSSTABLE<-STEPS+1000
CURRENTSTEP<-0
CURRENTSTEPSTABLE<-0
PROJECTIONYEAR<-STEPS*5+2015
FERTWIDTH<-35

##SELECTING RATIOS BASIS
##(Year "6" is 2013, 7 is 2014, 8 is 2015...)
FirstYear<-strtoi(6)
SecondYear<-strtoi(6)+5

##IMPOSED TFR OPTION (WITH AUTOCORRELATION OPTION)
ImposedTFR<-2.1
ImposedTFR_ar<-.00
ffab<-.4886
UseImposedTFR<-"NO"

##ADJUST BY MIGRATION OPTION
NetMigrationAdjustLevel<-0 #PERCENT OF POPULATION
GrossMigrationAdjustLevel<-100 #PERCENT OF NET MIGRATION
NetMigrationAdjustLevel<-NetMigrationAdjustLevel/100
GrossMigrationAdjustLevel<-((GrossMigrationAdjustLevel*-1)+100)/100

##IMPUTE MORTALITY OPTION
##"BA" IS THE BRASS RELATIONAL LOGIT MODEL ALPHA
BA_start<-.03
BA_end<-.12
BB<-1
ImputeMort<-"YES"

##SELECT BY SEX
SelectBySex<-"Total"

##SELECT AREA
Name<-paste("Alameda County")

##NUMBER FORMATTING
options(scipen=999)

##SELECTING FROM THE INPUT POPULATION TABLE (K) BASED ON INPUTS (DATA FOR JUMP-OFF, AND DATA FOR RATIOS)
TMinusOneAgeInit_F<-subset(K,CTYNAME==Name & YEAR==3 & AGEGRP>0)
TMinusOneAgeInit_F<-TMinusOneAgeInit_F$TOT_FEMALE
TMinusOneAge_F<-TMinusOneAgeInit_F

TMinusOneAgeInit_M<-subset(K,CTYNAME==Name & YEAR==3 & AGEGRP>0)
TMinusOneAgeInit_M<-TMinusOneAgeInit_M$TOT_MALE
TMinusOneAge_M<-TMinusOneAgeInit_M

TMinusOneAge<-TMinusOneAgeInit<-c(TMinusOneAge_F,TMinusOneAge_M)

TMinusOneAgeInitRatios_F<-subset(K,CTYNAME==Name & YEAR==FirstYear & AGEGRP>0)
TMinusOneAgeInitRatios_F<-TMinusOneAgeInitRatios_F$TOT_FEMALE
TMinusOneAgeRatios_F<-TMinusOneAgeInitRatios_F

TMinusOneAgeInitRatios_M<-subset(K,CTYNAME==Name & YEAR==FirstYear & AGEGRP>0)
TMinusOneAgeInitRatios_M<-TMinusOneAgeInitRatios_M$TOT_MALE
TMinusOneAgeRatios_M<-TMinusOneAgeInitRatios_M

TMinusOneAgeRatios<-TMinusOneAgeInitRatios<-c(TMinusOneAgeRatios_F,TMinusOneAgeRatios_M)

TMinusZeroAgeInit_F<-subset(K,CTYNAME==Name & YEAR==8 & AGEGRP>0)
TMinusZeroAgeInit_F<-TMinusZeroAgeInit_F$TOT_FEMALE
TMinusZeroAge_F<-TMinusZeroAgeInit_F

TMinusZeroAgeInit_M<-subset(K,CTYNAME==Name & YEAR==8 & AGEGRP>0)
TMinusZeroAgeInit_M<-TMinusZeroAgeInit_M$TOT_MALE
TMinusZeroAge_M<-TMinusZeroAgeInit_M

TMinusZeroAge<-TMinusZeroAgeInit<-c(TMinusZeroAge_F,TMinusZeroAge_M)

TMinusZeroAgeInitRatios_F<-subset(K,CTYNAME==Name & YEAR==SecondYear & AGEGRP>0)
TMinusZeroAgeInitRatios_F<-TMinusZeroAgeInitRatios_F$TOT_FEMALE
TMinusZeroAgeRatios_F<-TMinusZeroAgeInitRatios_F

TMinusZeroAgeInitRatios_M<-subset(K,CTYNAME==Name & YEAR==SecondYear & AGEGRP>0)
TMinusZeroAgeInitRatios_M<-TMinusZeroAgeInitRatios_M$TOT_MALE
TMinusZeroAgeRatios_M<-TMinusZeroAgeInitRatios_M

TMinusZeroAgeRatios<-TMinusZeroAgeInitRatios<-c(TMinusZeroAgeRatios_F,TMinusZeroAgeRatios_M)

##########
##CALCULATIONS
##########

##COHORT CHANGE RATIOS
Ratios<-array(0,length(TMinusOneAgeRatios))
for (i in 2:length(TMinusOneAgeRatios)) {Ratios[i]<-TMinusZeroAgeRatios[i]/TMinusOneAgeRatios[i-1]}
Ratios[1]<-(TMinusZeroAgeRatios[1]+TMinusZeroAgeRatios[HALFSIZE+1])/sum(TMinusOneAgeRatios[4:10])

##PLACING COHORT CHANGE RATIOS (FEMALE)
S_F<-array(0,c(HALFSIZE,HALFSIZE))
S_F<-rbind(0,cbind(diag(Ratios[2:(HALFSIZE)]),0))

##OPEN-ENDED AGE GROUP OPTION (FEMALE)
S_F[HALFSIZE,HALFSIZE-1]<-TMinusZeroAgeRatios[HALFSIZE]/(TMinusOneAgeRatios[HALFSIZE-1]+TMinusOneAgeRatios[HALFSIZE])
Ratios[HALFSIZE]<-S_F[HALFSIZE,HALFSIZE]<-S_F[HALFSIZE,HALFSIZE-1]

##BIRTHS AND MATRIX PORTION CONSTRUCTION (FEMALE)
B_F<-0*S_F
B_F[1,4:10]<-Ratios[1]*ffab
A_F<-B_F+S_F

##PLACING COHORT CHANGE RATIOS (MALE)
S_M<-array(0,c(HALFSIZE,HALFSIZE))
S_M<-rbind(0,cbind(diag(Ratios[20:SIZE]),0))

##OPEN-ENDED AGE GROUP OPTION (MALE)
S_M[HALFSIZE,HALFSIZE-1]<-TMinusZeroAgeRatios[SIZE]/(TMinusOneAgeRatios[SIZE-1]+TMinusOneAgeRatios[SIZE])
Ratios[SIZE]<-S_M[HALFSIZE,HALFSIZE]<-S_M[HALFSIZE,HALFSIZE-1]

##BIRTHS AND MATRIX PORTION CONSTRUCTION (MALE)
B_M<-0*S_M
B_M[1,4:10]<-Ratios[1]*(1-ffab)

##STRUCTURAL ZEROES
AEnd_Zero<-A_Zero<-array(0,c(HALFSIZE,HALFSIZE))

##MAKING FULL PROJECTION MATRIX (TWO-SEX)
Acolone<-cbind(A_F,A_Zero)
Acoltwo<-cbind(B_M,S_M)
A<-rbind(Acolone,Acoltwo)

##IMPLIED TFR CALCUATION
ImpliedTFR2010<-((TMinusOneAgeInit[1]+TMinusOneAgeInit[HALFSIZE+1])/5)/sum(TMinusZeroAgeInit[4:10])*FERTWIDTH
ImpliedTFR2015<-((TMinusZeroAgeInit[1]+TMinusZeroAgeInit[HALFSIZE+1])/5)/sum(TMinusZeroAgeInit[4:10])*FERTWIDTH

##########
##PROJECTION FUNCTION
##########

##MAX STEPS IN CASE USER (ESP ME) GETS CARRIED AWAY
if(STEPS<198){

##FUNCTION INPUTTING
CCRProject<-function(TMinusZeroAge,ImpliedTFR,BA_start,BA_end,CURRENTSTEP)
	{

##CALCULATE SURVIVAL ADJUSTMENT (Yx, lx, Lx, Sx)
	YxF<-YxM<-NULL
	for (i in 1:length(lxF)){YxF[i]<-.5*log(lxF[i]/(1-lxF[i]))}
	for (i in 1:length(lxM)){YxM[i]<-.5*log(lxM[i]/(1-lxM[i]))}
	
	lxFStart<-array(0,length(lxF))
	lxMStart<-array(0,length(lxM))
	for (i in 1:length(lxFStart)){lxFStart[i]<-1/(1+exp(-2*BA_start-2*BB*YxF[i]))}
	for (i in 1:length(lxMStart)){lxMStart[i]<-1/(1+exp(-2*BA_start-2*BB*YxM[i]))}
	
	LxFStart<-array(0,length(lxF))
	LxMStart<-array(0,length(lxM))
	##**THIS IS A LITTLE OFF FOR THE FIRST AGE GROUP**
	for (i in 1:length(LxFStart)){LxFStart[i]<-.5*(lxFStart[i]+lxFStart[i+1])}
	for (i in 1:length(LxMStart)){LxMStart[i]<-.5*(lxMStart[i]+lxMStart[i+1])}
	
	SxFStart<-array(0,length(lxF)-1)
	SxMStart<-array(0,length(lxM)-1)
	for (i in 1:length(SxFStart)-1){SxFStart[i]<-(LxFStart[i+1]/LxFStart[i])}
	for (i in 1:length(SxMStart)-1){SxMStart[i]<-(LxMStart[i+1]/LxMStart[i])}	

	##(OPEN-ENDED AGE GROUP OPTION (FEMALE))
	SxFStart[length(SxFStart)-1]<-LxFStart[length(SxFStart)]/(LxFStart[length(SxFStart)-1]+LxFStart[length(SxFStart)])
	SxFStart[length(SxFStart)]<-SxFStart[length(SxFStart)-1]
	
	##(OPEN-ENDED AGE GROUP OPTION (MALE))
	SxMStart[length(SxMStart)-1]<-LxMStart[length(SxMStart)]/(LxMStart[length(SxMStart)-1]+LxMStart[length(SxMStart)])
	SxMStart[length(SxMStart)]<-SxMStart[length(SxMStart)-1]

	##INITIAL e0
	e0FStart<-sum(LxFStart[1:22]*5)
	e0MStart<-sum(LxMStart[1:22]*5)

	lxFAdj<-array(0,length(lxF))
	lxMAdj<-array(0,length(lxM))

	##INTERPOLATING BRASS ALPHA BETWEEN FIRST AND LAST STEP
	if(CURRENTSTEP<=STEPS){
	for (i in 1:length(lxFAdj)){lxFAdj[i]<-1/(1+exp(-2*(BA_start*(1-CURRENTSTEP/STEPS)+BA_end*(CURRENTSTEP/STEPS))-2*BB*YxF[i]))}
	for (i in 1:length(lxMAdj)){lxMAdj[i]<-1/(1+exp(-2*(BA_start*(1-CURRENTSTEP/STEPS)+BA_end*(CURRENTSTEP/STEPS))-2*BB*YxM[i]))}
	}

	##ALLOWING FOR LONG-TERM (STABLE POPULATION) SIMULATION
	if(CURRENTSTEP>=STEPS){
	for (i in 1:length(lxFAdj)){lxFAdj[i]<-1/(1+exp(-2*BA_end-2*BB*YxF[i]))}
	for (i in 1:length(lxMAdj)){lxMAdj[i]<-1/(1+exp(-2*BA_end-2*BB*YxM[i]))}
	}

	##SURVIVAL ADJUSTMENTS (Lx, SX)
	LxFAdj<-array(0,length(lxF))
	LxMAdj<-array(0,length(lxM))
	##**THIS IS A LITTLE OFF FOR THE FIRST AGE GROUP**
	for (i in 1:length(LxFAdj)){LxFAdj[i]<-.5*(lxFAdj[i]+lxFAdj[i+1])}
	for (i in 1:length(LxMAdj)){LxMAdj[i]<-.5*(lxMAdj[i]+lxMAdj[i+1])}

	SxFAdj<-array(0,length(lxF)-1)
	SxMAdj<-array(0,length(lxM)-1)
	for (i in 1:length(SxFAdj)-1){SxFAdj[i]<-(LxFAdj[i+1]/LxFAdj[i])}
	for (i in 1:length(SxMAdj)-1){SxMAdj[i]<-(LxMAdj[i+1]/LxMAdj[i])}

	##(OPEN-ENDED AGE GROUP OPTION (FEMALE))
	SxFAdj[length(SxFAdj)-1]<-LxFAdj[length(SxFAdj)]/(LxFAdj[length(SxFAdj)-1]+LxFAdj[length(SxFAdj)])
	SxFAdj[length(SxFAdj)]<-SxFAdj[length(SxFAdj)-1]

	##(OPEN-ENDED AGE GROUP OPTION (MALE))
	SxMAdj[length(SxMAdj)-1]<-LxMAdj[length(SxMAdj)]/(LxMAdj[length(SxMAdj)-1]+LxMAdj[length(SxMAdj)])
	SxMAdj[length(SxMAdj)]<-SxMAdj[length(SxMAdj)-1]

	##ADJUSTED e0
	e0FAdj<-sum(LxFAdj[1:22]*5)
	e0MAdj<-sum(LxMAdj[1:22]*5)

	##ADJUST GROSS MIGRATION OPTION
        if(GrossMigrationAdjustLevel!=0)
        {
            RatiosGrossMigAdj<-Ratios
            for (i in 2:HALFSIZE) {RatiosGrossMigAdj[i]<-(Ratios[i]-1)*(1-GrossMigrationAdjustLevel)+1-(1-SxFStart[i])*GrossMigrationAdjustLevel}
            SGrossMigAdj_F<-array(0,c(HALFSIZE,HALFSIZE))
            SGrossMigAdj_F<-rbind(0,cbind(diag(RatiosGrossMigAdj[2:HALFSIZE]),0))
            ##OPEN-ENDED AGE GROUP (FEMALE)
            RatiosGrossMigAdj[HALFSIZE]<-(Ratios[HALFSIZE]-1)*(1-GrossMigrationAdjustLevel)+1-(1-SxFStart[HALFSIZE])*GrossMigrationAdjustLevel
            SGrossMigAdj_F[HALFSIZE,HALFSIZE]<-SGrossMigAdj_F[HALFSIZE,HALFSIZE-1]<-RatiosGrossMigAdj[HALFSIZE]
            S_F<-SGrossMigAdj_F
            A_F<-B_F+S_F
            
            for (i in (HALFSIZE+2):SIZE) {RatiosGrossMigAdj[i]<-(Ratios[i]-1)*(1-GrossMigrationAdjustLevel)+1-(1-SxMStart[i-HALFSIZE])*GrossMigrationAdjustLevel}
            SGrossMigAdj_M<-array(0,c(HALFSIZE,HALFSIZE))
            SGrossMigAdj_M<-rbind(0,cbind(diag(RatiosGrossMigAdj[(HALFSIZE+2):SIZE]),0))
            ##OPEN-ENDED AGE GROUP (MALE)
            RatiosGrossMigAdj[SIZE]<-(Ratios[SIZE]-1)*(1-GrossMigrationAdjustLevel)+1-(1-SxMStart[HALFSIZE])*GrossMigrationAdjustLevel
            SGrossMigAdj_M[HALFSIZE,HALFSIZE]<-SGrossMigAdj_M[HALFSIZE,HALFSIZE-1]<-RatiosGrossMigAdj[SIZE]
            S_M<-SGrossMigAdj_M
        }

	##CONSTRUCT PROJECTION MATRICES WITH SURVIVAL ADJUSTMENT
	SAdj_F<-array(0,c(HALFSIZE,HALFSIZE))
	SAdj_F<-rbind(0,cbind(diag(SxFAdj[2:(HALFSIZE)]-SxFStart[2:(HALFSIZE)]),0))
	SAdj_F<-SAdj_F+S_F
	AAdj_F<-B_F+SAdj_F

	SAdj_M<-array(0,c(HALFSIZE,HALFSIZE))
	SAdj_M<-rbind(0,cbind(diag(SxMAdj[2:(HALFSIZE)]-SxMStart[2:(HALFSIZE)]),0))
	SAdj_M<-SAdj_M+S_M

	AAdj_Zero<-A_Zero<-array(0,c(HALFSIZE,HALFSIZE))

	Acolone<-cbind(A_F,A_Zero)
	Acoltwo<-cbind(B_M,S_M)
	A<-rbind(Acolone,Acoltwo)

	AAdjcolone<-cbind(AAdj_F,AAdj_Zero)
	AAdjcoltwo<-cbind(B_M,SAdj_M)
	AAdj<-rbind(AAdjcolone,AAdjcoltwo)

	##PROJECTION IMPLEMENTATION (WITH FERTILITY AND MIGRATION ADJUSTMENTS)
	TMinusOneAgeNew<-data.frame(TMinusZeroAge) 
		if(CURRENTSTEP>0){
				TMinusZeroAge<-AAdj%*%TMinusZeroAge
		if(NetMigrationAdjustLevel!=0)
				{TMinusZeroAge<-NetMigrationAdjustLevel*5*sum(TMinusOneAgeNew)*Migration+TMinusZeroAge}
		if(UseImposedTFR=="YES") 
				{TMinusZeroAge[1]<-(ImpliedTFR*ImposedTFR_ar+ImposedTFR*(1-ImposedTFR_ar))*(sum(TMinusZeroAge[4:10])/FERTWIDTH)*5*ffab
				TMinusZeroAge[HALFSIZE+1]<-(ImpliedTFR*ImposedTFR_ar+ImposedTFR*(1-ImposedTFR_ar))*(sum(TMinusZeroAge[4:10])/FERTWIDTH)*5*(1-ffab)}
				}
        TMinusZeroAge_NDF<-TMinusZeroAge
	TMinusZeroAge<-data.frame(TMinusZeroAge)

	##CALCULATE iTFR
	ImpliedTFRNew<-((TMinusZeroAge_NDF[1]+TMinusZeroAge_NDF[HALFSIZE+1])/5)/sum(TMinusZeroAge_NDF[4:10])*FERTWIDTH

	return(c(TMinusZeroAge=TMinusZeroAge,TMinusOneAge=TMinusOneAgeNew,ImpliedTFRNew=ImpliedTFRNew,e0FStart=e0FStart,e0MStart=e0MStart,e0FAdj=e0FAdj,e0MAdj=e0MAdj,CURRENTSTEP=CURRENTSTEP+1))
	}
}

##APPLY PROJECTIONS
CCRNew<-CCRProject(TMinusZeroAge,ImpliedTFR2015,BA_start,BA_end,CURRENTSTEP)
while(CCRNew$CURRENTSTEP<STEPS+1) {CCRNew<-CCRProject(CCRNew$TMinusZeroAge,CCRNew$ImpliedTFRNew,BA_start,BA_end,CCRNew$CURRENTSTEP)}

##CALCULATE EFFECTIVE COHORT CHANGE RATIOS
CCRatios<-array(0,length(TMinusOneAge)+1)
for (i in 2:length(CCRatios)) {CCRatios[i]<-CCRNew$TMinusZeroAge[i]/CCRNew$TMinusOneAge[i-1]}
CCRatiosF<-CCRatios[2:HALFSIZE]
	##(OPEN-ENDED AGE GROUP OPTION (FEMALE))
	CCRatiosF[length(CCRatiosF)]<-CCRNew$TMinusZeroAge[HALFSIZE]/(CCRNew$TMinusOneAge[HALFSIZE-1]+CCRNew$TMinusOneAge[HALFSIZE])
CCRatiosM<-CCRatios[2+HALFSIZE:SIZE]
	##(OPEN-ENDED AGE GROUP OPTION (MALE))
	CCRatiosM[length(CCRatiosM)-2]<-CCRNew$TMinusZeroAge[SIZE]/(CCRNew$TMinusOneAge[SIZE-1]+CCRNew$TMinusOneAge[SIZE])

##iTFR
ImpliedTFRNew<-CCRNew$ImpliedTFRNew

##ESTIMATE STABLE POPULATION BY SIMULATION
TMinusZeroAge<-TMinusZeroAgeInit
CCRStable<-CCRProject(TMinusZeroAge,ImpliedTFR2015,BA_start,BA_end,0)
while(CCRStable$CURRENTSTEP<STEPSSTABLE+1) {CCRStable<-CCRProject(CCRStable$TMinusZeroAge,CCRStable$ImpliedTFRNew,BA_start,BA_end,CCRStable$CURRENTSTEP)}
ImpliedTFRStable<-((CCRStable$TMinusZeroAge[1]+CCRStable$TMinusZeroAge[HALFSIZE+1])/5)/sum(CCRStable$TMinusZeroAge[4:10])*FERTWIDTH

##########
##TABLING DATA
##########

##JUST ALL POPULATIONS USED IN GRAPHS
NewAge_F<-CCRNew$TMinusZeroAge[1:HALFSIZE]
StableAge_F<-CCRStable$TMinusZeroAge[1:HALFSIZE]
TMinusOneAgeInit_F<-TMinusOneAgeInit[1:HALFSIZE]
TMinusZeroAgeInit_F<-TMinusZeroAgeInit[1:HALFSIZE]

NewAge_M<-CCRNew$TMinusZeroAge[(HALFSIZE+1):SIZE]
StableAge_M<-CCRStable$TMinusZeroAge[(HALFSIZE+1):SIZE]
TMinusOneAgeInit_M<-TMinusOneAgeInit[(HALFSIZE+1):SIZE]
TMinusZeroAgeInit_M<-TMinusZeroAgeInit[(HALFSIZE+1):SIZE]

NewAge_T<-NewAge_F+NewAge_M
StableAge_T<-StableAge_F+StableAge_M
TMinusOneAgeInit_T<-TMinusOneAgeInit_F+TMinusOneAgeInit_M
TMinusZeroAgeInit_T<-TMinusZeroAgeInit_F+TMinusZeroAgeInit_M

NewAge<-array(c(NewAge_T,NewAge_F,NewAge_M),c(HALFSIZE,3))
StableAge<-array(c(StableAge_T,StableAge_F,StableAge_M),c(HALFSIZE,3))
TMinusOneAgeInit<-array(c(TMinusOneAgeInit_T,TMinusOneAgeInit_F,TMinusOneAgeInit_M),c(HALFSIZE,3))
TMinusZeroAgeInit<-array(c(TMinusZeroAgeInit_T,TMinusZeroAgeInit_F,TMinusZeroAgeInit_M),c(HALFSIZE,3))

##########
##GRAPHING DATA (SOME ~HACKY LABELING SO MAY [LIKELY] NOT RENDER WELL)
##########

##FIRST GRAPH - MAJOR SUMMARY
agegroups<-c("0-4", "5-9", "10-14", "15-19", "20-24", "25-29", "30-34", "35-39", "40-44", "45-49", "50-54", "55-59", "60-64", "65-69", "70-74", "75-79", "80-84", "85+")
if(SelectBySex=="Total") {plot(TMinusOneAgeInit[,1]/sum(TMinusOneAgeInit[,1]),type="l",col="orange",main=paste(text=c(Name,", ","Total"),collapse=""),ylim=c(0,.12),axes=FALSE,xlab="",ylab="Population (proportional)",lwd=4)}
if(SelectBySex=="Female") {plot(TMinusOneAgeInit[,2]/sum(TMinusOneAgeInit[,2]),type="l",col="orange",main=paste(text=c(Name,", ","Female"),collapse=""),ylim=c(0,.12),axes=FALSE,xlab="",ylab="Population (proportional)",lwd=4)}
if(SelectBySex=="Male") {plot(TMinusOneAgeInit[,3]/sum(TMinusOneAgeInit[,3]),type="l",col="orange",main=paste(text=c(Name,", ","Male"),collapse=""),ylim=c(0,.12),axes=FALSE,xlab="",ylab="Population (proportional)",lwd=4)}

if(SelectBySex=="Total") {lines(TMinusZeroAgeInit[,1]/sum(TMinusZeroAgeInit[,1]),col="blue",lwd=4)}
if(SelectBySex=="Female") {lines(TMinusZeroAgeInit[,2]/sum(TMinusZeroAgeInit[,2]),col="blue",lwd=4)}
if(SelectBySex=="Male") {lines(TMinusZeroAgeInit[,3]/sum(TMinusZeroAgeInit[,3]),col="blue",lwd=4)}

if(SelectBySex=="Total") {lines(NewAge[,1]/sum(NewAge[,1]),col="dark green",lty=1,lwd=4)}
if(SelectBySex=="Female") {lines(NewAge[,2]/sum(NewAge[,2]),col="dark green",lty=1,lwd=4)}
if(SelectBySex=="Male") {lines(NewAge[,3]/sum(NewAge[,3]),col="dark green",lty=1,lwd=4)}

if (min(StableAge)>=0) {
mtext(side=1,"Age groups",line=4,cex=1)
axis(side=1,at=1:HALFSIZE,las=2,labels=agegroups,cex.axis=0.9)
axis(side=2)
legend(10, .12, legend=c("2010 (estimate)","2015 (estimate)",paste(c(PROJECTIONYEAR),"(projection)"),"Stable"),
       col=c("orange","blue","dark green","black"), lty=c(1,1,1,3),lwd=c(4,4,4,1.5),cex=1.2)
}

if (min(StableAge)<0) {
mtext(side=1,"Age groups",line=4,cex=.75)
axis(side=1,at=1:HALFSIZE,las=2,labels=agegroups,cex.axis=0.9)
axis(side=2)
legend(11.5, .12, legend=c("2010 (estimate)","2015 (estimate)",paste(c(PROJECTIONYEAR),"(projection)")),
       col=c("orange","blue","dark green"), lty=c(1,1,1),lwd=c(4,4,4),cex=1.2)
}

mtext(side=1,c("Sum 2010:"),line=-24,adj=.125,col="orange")
if(SelectBySex=="Total") {mtext(side=1,c(sum(TMinusOneAgeInit[,1])),line=-24,adj=.3,col="orange")}
if(SelectBySex=="Female") {mtext(side=1,c(sum(TMinusOneAgeInit[,2])),line=-24,adj=.3,col="orange")}
if(SelectBySex=="Male") {mtext(side=1,c(sum(TMinusOneAgeInit[,3])),line=-24,adj=.3,col="orange")}

mtext(side=1,c("Sum 2015:"),line=-23,adj=.125,col="blue")
if(SelectBySex=="Total") {mtext(side=1,c(sum(TMinusZeroAgeInit[,1])),line=-23,adj=.3,col="blue")}
if(SelectBySex=="Female") {mtext(side=1,c(sum(TMinusZeroAgeInit[,2])),line=-23,adj=.3,col="blue")}
if(SelectBySex=="Male") {mtext(side=1,c(sum(TMinusZeroAgeInit[,3])),line=-23,adj=.3,col="blue")}

mtext(side=1,c("Sum "),line=-22,adj=.117,col="dark green")
mtext(side=1,c(PROJECTIONYEAR),line=-22,adj=.18,col="dark green")
mtext(side=1,c(":"),line=-22,adj=.24,col="dark green")
if(SelectBySex=="Total") {mtext(side=1,c(round(sum(NewAge[,1]))),line=-22,adj=.3,col="dark green")}
if(SelectBySex=="Female") {mtext(side=1,c(round(sum(NewAge[,2]))),line=-22,adj=.3,col="dark green")}
if(SelectBySex=="Male") {mtext(side=1,c(round(sum(NewAge[,3]))),line=-22,adj=.3,col="dark green")}

mtext(side=1,c("iTFR 2010:"),line=-7,adj=.13,col="orange")
mtext(side=1,c(round(ImpliedTFR2010,2)),line=-7,adj=.29,col="orange")

mtext(side=1,c("iTFR 2015:"),line=-6,adj=.13,col="blue")
mtext(side=1,c(round(ImpliedTFR2015,2)),line=-6,adj=.29,col="blue")

mtext(side=1,c("iTFR"),line=-5,adj=.12,col="dark green")
mtext(side=1,c(PROJECTIONYEAR),line=-5,adj=.185,col="dark green")
mtext(side=1,c(":"),line=-5,adj=.23,col="dark green")
mtext(side=1,c(round(ImpliedTFRNew,2)),line=-5,adj=.29,col="dark green")

if(SelectBySex=="Total") {LASTGROWTHRATE<-paste(text=c("R (2010 to 2015):  ", round(log(sum(TMinusZeroAgeInit[,1])/sum(TMinusOneAgeInit[,1]))/5*100,2)),collapse="")}
if(SelectBySex=="Male") {LASTGROWTHRATE<-paste(text=c("R (2010 to 2015):  ", round(log(sum(TMinusZeroAgeInit[,1])/sum(TMinusOneAgeInit[,1]))/5*100,2)),collapse="")}
if(SelectBySex=="Female") {LASTGROWTHRATE<-paste(text=c("R (2010 to 2015):  ", round(log(sum(TMinusZeroAgeInit[,1])/sum(TMinusOneAgeInit[,1]))/5*100,2)),collapse="")}
mtext(side=1,c(LASTGROWTHRATE),line=-11,adj=.15,col="blue")

if(SelectBySex=="Total") {GROWTHRATE<-paste(text=c("R (2015 to ",PROJECTIONYEAR,"):  ", round(log(sum(NewAge[,1])/sum(TMinusZeroAgeInit[,1]))/(STEPS*5)*100,2)),collapse="")}
if(SelectBySex=="Female") {GROWTHRATE<-paste(text=c("R (2015 to ",PROJECTIONYEAR,"):  ", round(log(sum(NewAge[,2])/sum(TMinusZeroAgeInit[,2]))/(STEPS*5)*100,2)),collapse="")}
if(SelectBySex=="Male") {GROWTHRATE<-paste(text=c("R (2015 to ",PROJECTIONYEAR,"):  ", round(log(sum(NewAge[,3])/sum(TMinusZeroAgeInit[,3]))/(STEPS*5)*100,2)),collapse="")}
mtext(side=1,c(GROWTHRATE),line=-10,adj=.15,col="dark green")

if (min(StableAge)>=0) {
if(SelectBySex=="Total") {STABLEGROWTHRATE<-paste(text=c("~r (2015 forward):  ", round(log(sum(StableAge[,1])/sum(TMinusZeroAgeInit[,1]))/(STEPSSTABLE*5)*100,2)),collapse="")}
if(SelectBySex=="Female") {STABLEGROWTHRATE<-paste(text=c("~r (2015 forward):  ", round(log(sum(StableAge[,2])/sum(TMinusZeroAgeInit[,2]))/(STEPSSTABLE*5)*100,2)),collapse="")}
if(SelectBySex=="Male") {STABLEGROWTHRATE<-paste(text=c("~r (2015 forward):  ", round(log(sum(StableAge[,3])/sum(TMinusZeroAgeInit[,3]))/(STEPSSTABLE*5)*100,2)),collapse="")}
mtext(side=1,c(STABLEGROWTHRATE),line=-9,adj=.15,col="black")

if(SelectBySex=="Total") {lines(StableAge[,1]/sum(StableAge[,1]),col="black",lty=3,lwd=1.5)}
if(SelectBySex=="Female") {lines(StableAge[,2]/sum(StableAge[,2]),col="black",lty=3,lwd=1.5)}
if(SelectBySex=="Male") {lines(StableAge[,3]/sum(StableAge[,3]),col="black",lty=3,lwd=1.5)}
}

if (min(StableAge)<0) {
if(SelectBySex=="Total") {STABLEGROWTHRATE<-paste(text=c("~r (2015 forward):  ..."),collapse="")}
if(SelectBySex=="Female") {STABLEGROWTHRATE<-paste(text=c("~r (2015 forward):  ..."),collapse="")}
if(SelectBySex=="Male") {STABLEGROWTHRATE<-paste(text=c("~r (2015 forward):  ..."),collapse="")}
mtext(side=1,c(STABLEGROWTHRATE),line=-9,adj=.15,col="black")
}

if (ImputeMort=="YES" & SelectBySex=="Total") {
mtext(side=1,c("Imputed starting e0, female: "),line=-3,adj=.157,col="black")
mtext(side=1,c(round(CCRNew$e0FStart,1)),line=-3,adj=.5,col="black")
mtext(side=1,c("Imputed starting e0, male: "),line=-2,adj=.155,col="black")
mtext(side=1,c(round(CCRNew$e0MStart,1)),line=-2,adj=.5,col="black")
}

if (ImputeMort=="YES" & SelectBySex=="Female") {
mtext(side=1,c("Imputed starting e0, female: "),line=-3,adj=.157,col="black")
mtext(side=1,c(round(CCRNew$e0FStart,1)),line=-3,adj=.5,col="black")
}

if (ImputeMort=="YES" & SelectBySex=="Male") {
mtext(side=1,c("Imputed starting e0, male: "),line=-3,adj=.155,col="black")
mtext(side=1,c(round(CCRNew$e0MStart,1)),line=-3,adj=.5,col="black")
}

Sys.sleep(5)

##SECOND GRAPH - COHORT CHANGE RATIOS WITH AND WITHOUT ADJUSTMENTS
agegroups2<-c("5-9", "10-14", "15-19", "20-24", "25-29", "30-34", "35-39", "40-44", "45-49", "50-54", "55-59", "60-64", "65-69", "70-74", "75-79", "80-84", "85+")
plot(Ratios[2:18],type="l",col="dodger blue",main=paste(text=c("Effective Cohort Change Ratios, ",PROJECTIONYEAR-5," to ",PROJECTIONYEAR),collapse=""),ylim=c(.25,1.75),axes=FALSE,xlab="",ylab="Ratio",lwd=4)
	##(OPEN-ENDED AGE GROUP OPTION)
	mtext(side=1,c("(Note: 85+ ratios are applied to full 80+ age groups)"),line=-25,adj=.5,col="black")
lines(Ratios[20:36],type="l",col="gold",lwd=4)
lines(CCRatiosF,type="l",col="dodger blue",lty=2,lwd=2)
lines(CCRatiosM,type="l",col="gold",lty=2,lwd=2)
mtext(side=1,"Age groups",line=4,cex=1)
axis(side=1,at=1:(HALFSIZE-1),labels=agegroups2,las=2,cex.axis=0.9)
axis(side=2)
legend(5,1.75, legend=c("Female","Male", "Female, with migration and mortality adjustments","Male, with migration and mortality adjustments"),
       col=c("dodger blue","gold","dodger blue","gold"), lty=c(1,1,2,2),lwd=c(4,4,2,2),cex=1)

if (ImputeMort=="YES") {
mtext(side=1,c("Imputed e0, female:"),line=-8,adj=.125,col="black")
mtext(side=1,c(round(CCRNew$e0FAdj,1)),line=-8,adj=.42,col="black")
mtext(side=1,c("Imputed e0, male:"),line=-7,adj=.122,col="black")
mtext(side=1,c(round(CCRNew$e0MAdj,1)),line=-7,adj=.42,col="black")
} 
