# This code implements the main model reported in the manuscript, where drift rate depends on validity and difficulty, and non-decision time depends on validity
#
#Condition; 0=cath, 1=valid, 2=invalid; Validity effect is the crucial question (H1=non-decision time)
#Difficulty = 0=cath, 1=easy vs 2=difficult; Difficulty effect is just sanity check (H1, drift rate)
#
import os
import numpy as np         # for basic matrix operations
import hddm #run with hddm 0.6.1

model_dir = os.getcwd()

#Load the data
df = hddm.load_csv("data.csv")

#drop catch trials
df = df.query('difficulty>0')

#change labels to aid interpretation
df.difficulty[df.difficulty==1] = "easy"
df.difficulty[df.difficulty==2] = "hard"

#Use accuracy coding
df['response'] = df['correct']

#set error to NaN; hddm 0.6.1 still fits the proportions
df.rt[df["rt"]==0] = 999 #otherwise query excludes NaNs

#set anticipations to zero
df = df.query('rt>.1')
df.rt[df["rt"]==999] = np.NaN #otherwise query excludes NaNs

#hierarchical fit
samples = 100000
m = hddm.HDDM(df, depends_on={'v':{'difficulty','condition'},'t': 'condition'},p_outlier=.05)
m.find_starting_values()
m.sample(samples, burn=samples/10, thin=2, dbname=os.path.join(model_dir, 'main_fit1'), db='pickle')
m.save(os.path.join(model_dir, 'main_fit1'))

toPlot = False
if toPlot:
    import kabuki
    import pandas as pd
    import seaborn as sns
    nr_subjects = 21
    from kabuki.analyze import gelman_rubin
    import matplotlib.pyplot as plt
    models = [] #assuming 3 instances of the model above have been run
    models.append(hddm.load('main_fit1'))
    models.append(hddm.load('main_fit2'))
    models.append(hddm.load('main_fit3'))
    gelman_rubin(models)
    m = kabuki.utils.concat_models(models)

    m.dic
    results = m.gen_stats()
    results.to_csv(os.path.join(model_dir,'main_fit.csv'))
    results = results['mean']

    #grab and save the trace
    vhardvalid,vhardinval, veasyval, veasyinval, tvalid, tinval = m.nodes_db.node[['v(1.hard)','v(2.hard)','v(1.easy)','v(2.easy)','t(1)','t(2)']]
    np.savetxt("vhardvalid.csv", vhardvalid.trace(), delimiter=",")
    np.savetxt("vhardinvalid.csv", vhardinval.trace(), delimiter=",")
    np.savetxt("veasyvalid.csv", veasyval.trace(), delimiter=",")
    np.savetxt("veasyinvalid.csv", veasyinval.trace(), delimiter=",")
    np.savetxt("tvalid.csv", tvalid.trace(), delimiter=",")
    np.savetxt("tinvalid.csv", tinval.trace(), delimiter=",")

    #
    hddm.analyze.plot_posterior_nodes([vhardvalid,vhardinval,veasyval,veasyinval])
    hddm.analyze.plot_posterior_nodes([tvalid,tinval])

    #
    m.plot_posteriors()

    #Add simulations to the data frame
    ppc_data = hddm.utils.post_pred_gen(m,append_data=True)
    ppc_compare = hddm.utils.post_pred_stats(df, ppc_data)
    print ppc_compare

    #Create sim acc
    simacc = pd.DataFrame(index=range(nr_subjects), columns=['easy_val','easy_inval','hard_val','hard_inval','valid','inval'])
    tempsim = ppc_data.groupby(['subj_idx','condition','difficulty']).mean()
    tempsim = tempsim['response_sampled']
    tempsim = tempsim.unstack(['condition','difficulty'])
    simacc['easy_val'] = tempsim[1].easy;simacc['easy_inval'] = tempsim[2].easy;
    simacc['hard_val'] = tempsim[1].hard;simacc['hard_inval'] = tempsim[2].hard;
    simacc['valid'] = tempsim[1].mean(1);simacc['inval'] = tempsim[2].mean(1)

    #Compare model and empirical accuracy
    acc = pd.DataFrame(index=range(nr_subjects), columns=['easy_val','easy_inval','hard_val','hard_inval','valid','inval'])
    for i in range(nr_subjects):
        tempdf = df.query('subj_idx == %s' %i) #
        #Compare accuracies
        realacc1 = tempdf.groupby(['condition']).mean().response
        realacc2 = tempdf.groupby(['difficulty','condition']).mean().response

        acc.easy_val[i] = realacc2.easy[1];acc.easy_inval[i] = realacc2.easy[2];
        acc.hard_val[i] = realacc2.hard[1];acc.hard_inval[i] = realacc2.hard[2];
        acc.valid[i] = realacc1[1];acc.inval[i] = realacc1[2]

    accL = acc.unstack().reset_index();accL.columns = ['condition','subj','acc'];accL['type'] = 'data'
    simaccL = simacc.unstack().reset_index();simaccL.columns = ['condition','subj','acc'];simaccL['type'] = 'simuls'
    mergeacc = pd.concat([accL,simaccL]) #merge, easier for plotting
    sns.pointplot(x="condition",y="acc",hue='type',data=mergeacc)

    sns.distplot(ppc_data.rt_sampled,label='fit',hist=False,kde=True,kde_kws = {'shade': True, 'linewidth': 3}, hist_kws={'edgecolor':'black'})
    sns.distplot(df.rt,label='data',hist=False,kde=True,kde_kws = {'shade': True, 'linewidth': 3}, hist_kws={'edgecolor':'black'})
    plt.xlim(0,1.25)

  
