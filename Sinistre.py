#!/usr/bin/env python
# coding: utf-8

# # Partie I : Modèle Logit binaire

# Le partie I du projet consiste à réaliser un modèle de régression logistique à partir d'une table de données.
# La table de données contient des informations de sinistre  concernant des individus.
# Ici, le projet consiste à réaliser un modèle de régression logistique censé déterminer la survenue d'un sinistre  ou non sur une police d'assurance (ici la variable Expdays sur la durée d'exposition de contrat)

# Notre Table de données contient 100022 individus et 20 variables :
# - PolNum     :     Numéro de la police est une variable numerique 
# - CalYear    :     Année calendaire de souscription est une variable numerique constante
# - Gender     :     Genre du conducteur (Homme/Femme) est une variable qualitative
# - Type       :     Type de Vehicule une variable qualitative
# - Category   :     Categorie du vehiculeune variable qualitative
# - Occupation :     Profession une variable qualitative
# - Age        :     Age du conducteur est une variable quantitative
# - Group1     :     Groupe du vehicule est une variable quantitative
# - Bonus      :     Bonus-Malus est une variable quantitative
# - Poldur     :     Ancienneté du contrat est une variable quantitative
# - Value      :     Valeur du vehicule est une variable quantitative
# - Adind      :     Indicateur d'une garantie dommages est une variable categorielle binaire
# - Subgroup2  :     Sous-region d'habitation est une variable qualitative
# - Group2     :     Region d'habitation est une variable qualitative
# - Density    :     Densité de la population est une variable quantitative
# - Expdays    :     Exposition en jours est une variable quantitative
# - Nb1        :     Nombre de sinistres RC Materiels est une variable de comptage
# - Nb2        :     Nombre de sinistre RC corporels  est une variable de comptage
# - Surv1      :     Survenance de sinistres RC Materiels est une variable binaire
# - Surv2      :     Survenance de sinistres RC Corporels est une variable binaire
# 
#     

# In[3]:


import pandas as pd 
import matplotlib.pyplot as plt
import seaborn as sm
import scipy.stats as sc
import statsmodels.api as st
from statsmodels.formula.api import ols


# In[6]:


Sinistre = pd.read_excel('base.xlsx') # On essaye d'importer le dataset


# In[8]:



#On supprime les variables categorielles 
Sinistre_Quant = Sinistre.drop(['Adind','Id','PolNum','CalYear','Gender','Type','Category','Occupation','SubGroup2','Group2','Nb1','Nb2','Surv1','Surv2','Exppdays'],axis=1)


# In[9]:


Sinistre_Quant


# ## Analyse exploratoire Quantitative

# In[112]:


Sinistre_Quant.describe() # On effectue le tableau descriptif des variables quantitatives


# D'après les resultats de cet tableau on peut en tirer :\\
# - L'age des clients varie entre 18 et 75 ans .L'age moyen vaut 41,12 ans et au moins 50\% ont un age inferieur à 40 ans .\\
# -La durée moyenne du contrat est de 5 ans .La plus grande ancienneté du contrat vaut 15 ans . 

# ### La boite à Moustache des variables quantitatives

# In[109]:



plt.subplots(figsize=(15,6))
Sinistre_Quant.boxplot(column =['Age','Group1','Bonus','Poldur','Density'])
plt.xticks(rotation=90)


# ### Recodage des variables
# 
# On a décider de recoder les variables qualitatives et de définir des catégories de référence
# 
# -La variable Gender a eté codé en binaire et les femmes sont mis dans la categorie des reference.
# 
# -La variable Occupation prend 1 si l'individu est employé et 0 sinon
# 
# - La  variable Category prend 1 si la catégorie de voiture est Large
# 
# -La variable Type prend 1 si la voiture est de type A et 0 sinon
# 
# -La variable Exppdays  est considérée comme la variable offset pour la suite de la modélisation .

# ###  La Matrice de correlation des variables quantitatives

# In[113]:


plt.subplots(figsize =(12,8))
sm.heatmap(Sinistre_Quant.corr(),linewidth=0.75, annot=True)


# Les coefficients de corrélations sont inférieurs à 0.25,ce qui montre que les variables ne sont pas corrélées entre elles .
# 
# Il n'y aura donc pas un problème de colinéarité dans la partie de la modélisation 

# ### Test d'Anova à plusieurs facteurs

# In[8]:


Sinistre_Quant_lm = ols('Surv1 ~ Age+Group1+Bonus+Poldur+Value+Density+Exppdays',
                 data=Sinistre).fit()


# In[9]:


resultat = st.stats.anova_lm(Sinistre_Quant_lm, type = 1)
resultat


# ## Analyse Exploratoire Qualitative

# In[10]:


Sinistre_Quali = Sinistre.drop(Sinistre_Quant,axis =1)
Sinistre_Qualitative =Sinistre_Quali.drop(['Id','PolNum','CalYear','Adind','SubGroup2','Group2','Nb1','Nb2','Surv1','Surv2'],axis=1)
Sinistre_Qualitative


# ### Test Chi2 et tableau de contingence

# In[11]:


from scipy.stats import chi2_contingency
a = pd.crosstab(Sinistre_Quali['Nb2'],Sinistre_Quali['Surv2'])

chi2_contingency(a)


# ## Recodage des variables

# In[12]:


TrancheAge = pd.cut(Sinistre['Age'], 6)
Sinistre['TrancheAge'] = TrancheAge
#Sinistre[['TrancheAge','Surv1']].groupby(['TrancheAge'], as_index=False).sum().sort_values(by='TrancheAge', ascending=True)
Sinistre


# ### Encodage Variable Gender

# In[13]:


# integer encode
from sklearn.preprocessing import LabelEncoder
from sklearn.preprocessing import OneHotEncoder
label_encoder = LabelEncoder()
integer_encoded = label_encoder.fit_transform(Sinistre['Gender'])
print(integer_encoded)


# In[14]:


Sinistre['Gender'] =integer_encoded
Sinistre['Gender'] 


# ### Encodage Variable Occupation

# In[15]:


# integer encode
from sklearn.preprocessing import LabelEncoder
from sklearn.preprocessing import OneHotEncoder
label_encoder = LabelEncoder()
b = label_encoder.fit_transform(Sinistre['Occupation'])
print(integer_encoded)
Sinistre['Occupation'] = b
Sinistre['Occupation']


# In[16]:


Sinistre['Occupation'] = Sinistre['Occupation'].apply(lambda x: 1 if x == 0 else 0)
Sinistre['Occupation']
Sinistre
#Sinistre.drop(['Profession','Occupation','TrancheAge','Group1','SubGroup2','Group2','Nb1','Nb2','Surv2','Type',''],axis=1)


# ### Encodage Variable Category

# In[17]:


# integer encode
from sklearn.preprocessing import LabelEncoder
from sklearn.preprocessing import OneHotEncoder
label_encoder = LabelEncoder()
b = label_encoder.fit_transform(Sinistre['Category'])
print(integer_encoded)
Sinistre['Category'] = b
Sinistre['Category']


# In[18]:




Sinistre['Category'] = Sinistre['Category'].apply(lambda x: 1 if x == 0 else 0)
Sinistre['Category']
Sinistre


# ### Encodage Variable Type

# In[19]:


# integer encode
from sklearn.preprocessing import LabelEncoder
from sklearn.preprocessing import OneHotEncoder
label_encoder = LabelEncoder()
b = label_encoder.fit_transform(Sinistre['Type'])
print(integer_encoded)
Sinistre['Type'] = b
Sinistre['Type']


# In[20]:


Sinistre['Type'] = Sinistre['Type'].apply(lambda x: 1 if x == 0 else 0)
Sinistre['Type']
Sinistre


# ### Encodage variable Exppdays

# In[76]:


Sinistre['Exppdays'] =np.log(Sinistre['Exppdays'])
Sinistre


# In[22]:


Sinistre_Logit = Sinistre.drop(['Id','PolNum','CalYear','SubGroup2','Group2','Nb1','Nb2','Surv2','Gender','Value','Exppdays','Poldur','TrancheAge'],axis = 1)
Sinistre_Logit


# ## La Modèlisation du problème par la regression logistique
# 
# Le modèle logit ou régression logistique est un modèle de régression ou la variable dépendante est une variable binaire .Dans notre cas,notre variable  dépendante Surv1 indiquant la survenue ou  non de sinistres.
# 
# 

# In[23]:


X = Sinistre_Logit.drop(['Surv1'],axis=1)
Y = Sinistre_Logit['Surv1']


# Pour la validation de notre modèle ,on essaye de diviser notre échantillons en deux : Un ensemble d'entraînement 70\% de nos données pour évaluer notre modèle  et un ensemble de test 30\% pour la validation .

# In[24]:


from sklearn.model_selection import train_test_split
X_train, X_test, y_train, y_test = train_test_split(X, Y,test_size=0.3)


# In[25]:


print(X_train.shape) # Il s'agit de l'ensemble d'entrainement contenant 70014 individus 
print(y_train.shape)
print(X_test.shape) # Il s'agit de l'ensemble  de test contenant lui 30007 individus
print(y_test.shape)


# #### Quelles sont les caracteristiques des individus qui ont des sinistres  ?

# In[26]:


from sklearn.linear_model import LogisticRegression
clr = LogisticRegression()
result = clr.fit(X_train,y_train)
#y_pred = clr.predict(X_train)

coef =dict(zip(X, zip(clr.coef_[0])))
coef


# In[27]:


import numpy as np 
odds = [np.math.exp(x) for x in clr.coef_[0]] # La variable odds contient l'ensemble des rapports de cote de chaque variable explicative
coef = dict(zip(X, zip(clr.coef_[0], odds))) # Il s'agit d'un dictionnaire contenant les coefficients et rapoort de cote ensemble
coef
# Nous allons creer un DataFrame pour bien rentre visible
OddsRatio =pd.DataFrame.from_dict(coef, orient='index',columns=['Coefficient','Rapport de cote'])
OddsRatio


# On remarque que les coefficient des  variables Category,Bonus,Density sont positifs .
# Également ,les coefficients des variables Type ,Age sont négatifs . 
# 
# -Les assurés qui ont des voitures de catégorie large ont tendance à avoir de plus de sinistres que les autres individus de catégories de voiture différentes.
# 
# -La survenance du sinistre augmente avec le coefficient du bonus-malus, ce qui est normal car
# les assurés avec un bonus élevé son ceux qui ont tendance à faire plus d’accidents.
# 
# -On voit bien que la survenance de sinistre diminue avec l'âge des assurés.  
# -On peut dire que plus la densité est élevée ,plus la survenance du sinistre augmente.
# 

# In[28]:


from sklearn.metrics import confusion_matrix 
conf = confusion_matrix(y_test, clr.predict(X_test))
conf


# In[29]:


plt.figure(figsize=(12,10))

plt.suptitle("Confusion Matrix",fontsize=20)

plt.subplot(2,3,1)
plt.title("Logistic Regression Confusion Matrix")
sm.heatmap(conf,cbar=False,annot=True,cmap="Reds",fmt="d")


# Les coefficients sur la diagonale indique les éléments bien classés ici au total notre modèle a bien classé 26377 sur 30085 individus , les coefficients en dehors de ceux que le classifieur a mis dans la mauvaise classe.
# 
# Il n'a pas parvenu à bien classer 3630 individus s'ils sont sinistrés ou non .
# 

# In[115]:


score = clr.decision_function(X_test)
sc= pd.DataFrame(data=score,columns =['SCORE']).sort_values('SCORE')
sc.head()


# In[116]:


proba = clr.predict_proba(X_test)
pb = pd.DataFrame(data=proba,columns =['risqué avec probabilité','Non risqué avec probabilité']).sort_values('risqué avec probabilité')
pb.head()


# Par exemple,le 22051eme client présente la probabilité de sinistre  le plus faible(0.250643) c'est à dire qu'il est le moins risqué de commettre un sinistre .

# In[126]:


import pandas 
Score = clr.predict_proba(X_test)[:,1]
dfsc = pandas.DataFrame(Score, columns=['Probabilité de risque']).sort_values('Probabilité de risque')
dfsc['Sinistre'] = y_test.values
dfsc


# In[33]:


ax = dfsc['Score'].hist(bins=50, figsize=(6,3))
ax.set_title('Distribution des scores de classification de sinistre');


# In[34]:


ax = dfsc[dfsc['Sinistre'] == 0]['Score'].hist(bins=25, figsize=(8,4), label='Sinistre', alpha=0.5)
dfsc[dfsc['Sinistre'] == 1]['Score'].hist(bins=25, ax=ax, label='Pas de Sinistre', alpha=0.5)
ax.set_title("Distribution des scores pour les deux classes")
ax.plot([1, 1], [0, 100], 'g--', label="frontière ?")
ax.legend();


# In[77]:


proba = clr.predict_proba(X_test)[:, 1]
dfpr = pandas.DataFrame(proba, columns=['proba'])
dfpr['Sinistre'] = y_test.values
dfpr['Sinistre'] 

import matplotlib.pyplot as plt
fig, ax = plt.subplots(1, 2, figsize=(15,4))
dfpr[dfpr['Sinistre'] == 1]['proba'].hist(bins=25, label='Sinistre', alpha=0.5, ax=ax[0])
dfpr[dfpr['Sinistre'] == 0]['proba'].hist(bins=25, label='Pas de Sinistre', alpha=0.5, ax=ax[0])
ax[0].set_title('Distribution des probabilités des deux classes')
ax[0].legend();
dfpr[dfpr['Sinistre'] == 1]['proba'].hist(bins=25, label='Sinistre', alpha=0.5, ax=ax[1])
dfpr[dfpr['Sinistre'] == 0]['proba'].hist(bins=25, label='Pas de Sinistre', alpha=0.5, ax=ax[1])
ax[0].plot([0.5, 0.5], [0, 1000], 'g--', label="frontière ?")
ax[1].plot([0.5, 0.5], [0, 1000], 'g--', label="frontière ?")
ax[1].set_yscale('log')
ax[1].set_title('Distribution des probabilités des deux classes\néchelle logarithmique')
ax[1].legend();


# In[129]:


fig, ax = plt.subplots(1, 1, figsize=(8,8))
ax.plot([0, 1], [0, 1], 'k--')
# aucf = roc_auc_score(y_test == clr.classes_[0], probas[:, 0]) # première façon
aucf = auc(fpr0, tpr0) 
print( 'L aire sous la courbe est égale à ' ,+ aucf)# seconde façon
ax.plot(fpr0, tpr0)
ax.set_title('Courbe ROC - classifieur des survenue de sinistres')
ax.text(0.5, 0.3, "plus mauvais que\nle hasard dans\ncette zone")
ax.legend();


# La précision du modèle  qu’une observation soit mieux prédite qu’une prédiction purement aléatoire est présentée par
# l’aire sous la courbe ROC.
# 
# L’aire sous la courbe pour ce modèle est égale a 0.7346 est supérieure à 0.7, cela signifie que la survenance d’un sinistre a une probabilité de 73,46\%.

# ## Regression de Poisson

# In[81]:


Sinistre_Poisson = Sinistre.drop(['Id','PolNum','CalYear','SubGroup2','Group2','Surv1','Nb2','Surv2','TrancheAge','Gender','Value'],axis = 1)
Sinistre_Poisson


# In[82]:


U = Sinistre_Poisson.drop(['Nb1'],axis=1)
V = Sinistre_Poisson['Nb1']


# ### Les differents nombres dans la variable NB1

# In[83]:


import numpy as np
np.unique(V,return_counts=True)


# In[84]:


import statsmodels
U_Const = statsmodels.tools.add_constant(U)


# In[85]:


from statsmodels.discrete.discrete_model import Poisson
mpr = Poisson(V,U_Const)
res_mpr = mpr.fit()


# In[93]:


from statsmodels.genmod.generalized_linear_model import GLM
from statsmodels.genmod import families

mod = GLM(V, U_Const, family=families.Poisson())
res = mod.fit()
print(res.summary()) 


# ### La surdispersion

# In[95]:


#Surdispersion 

print(res.pearson_chi2/res.df_resid) 


# #### On voit bien que le rapport de la pearson chi2_dll /residual deviance est superieur à 1 ,d'ou l'existence de la surdispersion

# ### Frequence de nombre de Zero dans les données 

# In[89]:


ax,fig = plt.subplots(1,1,figsize=(8,4))
sm.distplot(V)
plt.show()


# In[ ]:


### Nombre de Zero dans le


# In[106]:


for i in range(0,7) :
    zero = sum(V == i)

    print(zero)


# ### Modèle Binomiale Negative

# In[97]:



from statsmodels.genmod.generalized_linear_model import GLM
from statsmodels.genmod import families
modele_NB = GLM(V, U_Const, family=families.NegativeBinomial())
res = modele_NB.fit()
print(res.summary()) 






# In[92]:


print(res.pearson_chi2/res.df_resid)


# ### Modele de poisson à Zero Inflation

# In[98]:


from statsmodels.discrete.count_model import ZeroInflatedPoisson
mzip = ZeroInflatedPoisson(V,U_Const,U_Const)
res_mzip = mzip.fit(maxiter=100)


print(res_mzip.summary())


# In[108]:


from statsmodels.discrete.count_model import ZeroInflatedNegativeBinomialP
mzip = ZeroInflatedNegativeBinomialP(V,U_Const,U_Const)
res_mzip = mzip.fit()


print(res_mzip.summary())

