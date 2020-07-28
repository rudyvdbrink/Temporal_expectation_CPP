rm(list=ls())
Data <- read.table('trial_level_data.csv',header=T,sep=',')

#Columns in data indicate:
#1: trl_idx (trial index within participants)
#2: RT (response time; miss trial RT is set to zero, for false alarms this is negative because the response was prior to the stimulus)
#3: response (1 or 0, indicating if a response was given or not)
#4: subj_idx (participant index, starting at zero)
#5: condition (0=catch, 1=valid, 2=invalid)
#6: difficulty (0=catch, 1=easy, 2=difficult)
#7: stim (0=catch, 1=stim present);
#8: correct (1=correct, 0=incorrect)
#9: cti: (0=short interval, 1=long interval)


## stats for misses ##

#excluce catch trials
Data <- subset(Data,condition!=0)

#For the main analyses exclude trials where ppts respond before target onset (i.e., false alarms)
#seperately create a DF without misses but with false alarms (i.e. rt==0)
FalseAlarms <- subset(Data,rt != 0) #exclude misses
Data <- subset(Data,rt>=0)

#double check if everything is there
table(Data$subj_idx)
table(Data$condition,Data$difficulty,Data$cti)
table(Data$subj_idx,Data$condition,Data$difficulty,Data$cti)

#reshape and make a plot
library(reshape)
ER <- with(Data,aggregate(correct,by=list(condition=condition,difficulty=difficulty,cti=cti,subj_idx=subj_idx),mean));ER <- cast(ER,subj_idx~cti+difficulty+condition)
ER <- ER*100;ER <- 100-ER
par(mfrow=c(1,2))
plot(colMeans(ER)[2:3],type='b',ylim=c(2,10),main='short CTI')
lines(colMeans(ER)[4:5],type='b',lty=2)
plot(colMeans(ER)[6:7],type='b',ylim=c(2,10),main="long CTI")
lines(colMeans(ER)[8:9],type='b',lty=2)

#Now run mixed model analysis
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


## stats for false alarms ##

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

