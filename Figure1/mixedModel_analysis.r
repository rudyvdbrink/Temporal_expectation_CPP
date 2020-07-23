setwd("C:/Users/kobe/Documents/Projecten/RecoveryRudy")
rm(list=ls())
Data <- read.table('data_both_cti.csv',header=T,sep=',')

#excluce catch trials
Data <- subset(Data,condition!=0)

#For the main analyses exclude trials where ppts respond before target onset (i.e., false alarms)
#seperately create a DF without misses but with false alarms (i.e. rt==0)
FalseAlarms <- subset(Data,rt != 0) #exclude misses
Data <- subset(Data,rt>=0)

#double check stuff
table(Data$subj_idx)
table(Data$condition,Data$difficulty,Data$cti)
table(Data$subj_idx,Data$condition,Data$difficulty,Data$cti)

#Effects of cue validity, CTI, and difficulty on RT and accuracy were tested with a repeated-measures ANOVA in JASP version 0.9.2 (JASP Team, 2018), 
#with cue validity (valid or invalid), CTI (short or long), and difficulty (easy or difficult) as within-participant factors
library(reshape)
ER <- with(Data,aggregate(correct,by=list(condition=condition,difficulty=difficulty,cti=cti,subj_idx=subj_idx),mean));ER <- cast(ER,subj_idx~cti+difficulty+condition)
ER <- ER*100;ER <- 100-ER
par(mfrow=c(1,2))
plot(colMeans(ER)[2:3],type='b',ylim=c(2,10),main='short CTI')
lines(colMeans(ER)[4:5],type='b',lty=2)
plot(colMeans(ER)[6:7],type='b',ylim=c(2,10),main="long CTI")
lines(colMeans(ER)[8:9],type='b',lty=2)

#Now do the same with a mixed model analysis
library(lme4);library(car);library(effects);library(multcomp)
Data$condition <- as.factor(Data$condition)
Data$difficulty <- as.factor(Data$difficulty)
Data$cti <- as.factor(Data$cti)
fit <- glmer(correct~condition*difficulty*cti+(1|subj_idx),data=Data,family=binomial,glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=500000)))
fit_a <- glmer(correct~condition*difficulty*cti+(condition|subj_idx),data=Data,family=binomial,glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=500000)))
fit_b <- glmer(correct~condition*difficulty*cti+(difficulty|subj_idx),data=Data,family=binomial,glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=500000)))
fit_c <- glmer(correct~condition*difficulty*cti+(cti|subj_idx),data=Data,family=binomial,glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=500000)))
anova(fit,fit_a) #n.s.
anova(fit,fit_b) #p=.003, BIC=6147
anova(fit,fit_c) #p<.001, BIC=6141
fit2 <- glmer(correct~condition*difficulty*cti+(difficulty+cti|subj_idx),data=Data,family=binomial,glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=500000)))
#singularity warning, so use the model with the lowest BIC instead
Anova(fit_c)

data.frame(effect('condition',fit_c))
data.frame(effect('difficulty',fit_c))
data.frame(effect('cti',fit_c))

#check validity effect in short cti
short <- subset(Data,cti==0)
fit_short_cti <- glmer(correct~condition*difficulty+(difficulty|subj_idx),data=short,family=binomial,glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=500000)))
Anova(fit_short_cti)

#post-hoc contrast
contrast.matrix <- rbind("validity in easy"= c(0, 1, 0, 0),
                         "validity in hard"= c(0, 1, 0, 1))
summary(glht(fit_short_cti, linfct=contrast.matrix), test=adjusted("none"))

#sanity check to make sure it's correct
# short_easy <- subset(short,difficulty==1)
# short_hard <- subset(short,difficulty==2)
# fit_short_easy <- glmer(correct~condition+(1|subj_idx),data=short_easy,family=binomial,glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=500000)))
# fit_short_hard <- glmer(correct~condition+(1|subj_idx),data=short_hard,family=binomial,glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=500000)))
# fit_short_easy
# fit_short_hard

#check validity effect in long cti
long <- subset(Data,cti==1)
fit_long_cti <- glmer(correct~condition*difficulty+(1|subj_idx),data=long,family=binomial,glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=500000)))
Anova(fit_long_cti)

#post-hoc contrast
contrast.matrix <- rbind("validity in easy"= c(0, 1, 0, 0),
                         "validity in hard"= c(0, 1, 0, 1))
summary(glht(fit_long_cti, linfct=contrast.matrix), test=adjusted("none"))

#sanity check to make sure it's correct
# long_easy <- subset(long,difficulty==1)
# long_hard <- subset(long,difficulty==2)
# fit_long_easy <- glmer(correct~condition+(1|subj_idx),data=long_easy,family=binomial,glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=500000)))
# fit_long_hard <- glmer(correct~condition+(1|subj_idx),data=long_hard,family=binomial,glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=500000)))
# fit_long_easy
# fit_long_hard




#Finally, look at the effects of false alarms (i.e., trials where rt<0)
#because the stimulus wasn't seen yet, don't include difficulty here, only validity and cti
FalseAlarms$condition <- as.factor(FalseAlarms$condition)
FalseAlarms$cti <- as.factor(FalseAlarms$cti)
fit <- glmer(correct~condition*cti+(1|subj_idx),data=FalseAlarms,family=binomial,glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=500000)))
fit_a <- glmer(correct~condition*cti+(condition|subj_idx),data=FalseAlarms,family=binomial,glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=500000)))
fit_b <- glmer(correct~condition*cti+(cti|subj_idx),data=FalseAlarms,family=binomial,glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=500000)))
anova(fit,fit_a) #n.s.
anova(fit,fit_b) #p<.003
#best model is fit_b
Anova(fit_b) #main effect of cti, and interaction with condition

plot(effect('cti',fit_b))  #0=short cti, 1=long cti
plot(effect('condition:cti',fit_b))

#Check the validity effect for each cti
contrast.matrix <- rbind("validity in cti 0"= c(0, 1, 0, 0),
                         "validity in cti 1"= c(0, 1, 0, 1))
summary(glht(fit_b, linfct=contrast.matrix), test=adjusted("none"))


#double check to make sure the coding's done correctly
# short <- subset(FalseAlarms,cti==0);long <- subset(FalseAlarms,cti==1)
# fit_short <- glmer(correct~condition+(1|subj_idx),data=short,family=binomial,glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=500000)))
# fit_long <- glmer(correct~condition+(1|subj_idx),data=long,family=binomial,glmerControl(optimizer="bobyqa",optCtrl=list(maxfun=500000)))
# fit_short
# fit_long