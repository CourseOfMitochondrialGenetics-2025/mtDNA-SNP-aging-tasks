rm(list=ls(all=TRUE))

library(ggplot2)

MUT = read.table('../Data/3results/VertebratePolymorphisms.MutSpecData.txt', header = TRUE)

taxa = read.table("../Data/1raw/TaxaFromKostya.Names.stat", sep = '\t',header = FALSE)
taxa = as.data.frame(taxa[grepl('Actinopteri',taxa$V1),])
names(taxa) = 'taxa'

taxa$Species = gsub(";(.*)",'',taxa$taxa);
taxa$Species = gsub(" ",'_',taxa$Species);
taxa$Family = gsub(";Actinopteri(.*)",'',taxa$taxa)
taxa$Family = gsub("(.*);",'',taxa$Family)
table(taxa$Family) ### some species with freq of families > 3
length(unique(taxa$Family)) ### 43 Families
taxa = taxa[,-1]


### merge Taxa with Temp and MutSpec

finaldf = merge(MUT, taxa, by = 'Species')
nrow(finaldf) # 110 sps with all inf
for (i in 1:nrow(finaldf))   {  finaldf$FamilyShort[i] = paste(unlist(strsplit(finaldf$Family[i],''))[c(1:3)],collapse = '')  } # make Short names
table(finaldf$Family)
length(unique(finaldf$Family))# 30 families

FamFreq = data.frame(table(finaldf$Family));
FrequentFamilies = FamFreq[FamFreq$Freq >= 3,]$Var1; length(FrequentFamilies) # delete families, that have less than 3 species!!!
FamFreq = FamFreq[FamFreq$Var1 %in% FrequentFamilies,]
names(FamFreq)=c('Family','NumberOfSpecies')

Fishes = finaldf[finaldf$Family %in% FrequentFamilies,]
Fishes$TsTv = (Fishes$T_C + Fishes$C_T + Fishes$G_A + Fishes$A_G) / (Fishes$T_A + Fishes$A_T + Fishes$G_C + Fishes$C_G + Fishes$G_T + Fishes$T_G + Fishes$C_A + Fishes$A_C)

### Calculate Ts/Tv and A<G/T<C

Fishes$A_G.T_C = (Fishes$T_C/Fishes$A_G)
Fishes = Fishes[Fishes$A_G.T_C > 0,]
Fishes = Fishes[Fishes$A_G.T_C < Inf,]
Fishes = Fishes[Fishes$TsTv < Inf,]

agg = aggregate(list(Fishes$TsTv,Fishes$A_G.T_C,Fishes$Temperature), by = list(Fishes$Family), FUN = median)
names(agg) = c('Family','TsTv','A_G.T_C','Temperature')
for (i in 1:nrow(agg))   {  agg$FamilyShort[i] = paste(unlist(strsplit(agg$Family[i],''))[c(1:3)],collapse = '')  }

cor.test(agg$A_G.T_C, agg$Temperature,method = 'spearman') ### positive and good p - value = 0.0227


ggplot(data = agg, aes(x = Temperature, y = A_G.T_C, label = FamilyShort, color = Family))+
  geom_point()+
  geom_smooth(method="lm", se=F, col = 'red')+
  theme_classic()+
  labs(x = 'Median annual water temperature, °C', y = 'Median A>G/T>C')+
  geom_text(aes(label=FamilyShort),hjust=-0.15, vjust=-0.5, show.legend = F)


#plots for Families
ggplot(data = Fishes, aes(x = Temperature, y = A_G.T_C, group = FamilyShort, fill = FamilyShort))+
  geom_boxplot(alpha=0.3)+
  theme_classic()+
  labs(x = 'Temperature, Â°C', y = 'A>G/T>C')
