setwd("/Users/huxiangyu/Documents/ZhengShi/Berkeley/Courses/PH240C/Assignment")
load("PH240C_HW1.RData")
source("http://bioconductor.org/biocLite.R")
biocLite("breastCancerMAINZ")
biocLite("hgu133a.db")
library("breastCancerMAINZ")
library(hgu133a.db)
library(RColorBrewer)
library(lattice)
library(ggplot2)
library(reshape2)
library(gplots)
library(grid)
## load the data
data(mainz)
# gene expression: 22,283 by 200 subjects
expression = exprs(mainz)
##########################
#### problem 2(a): #######
##########################
# random select 20 of 200 microarrays
subjects = 1:200
subjects_sample1 = sample(subjects, 20)

exprs_sample1 = expression[,subjects_sample1]
#### Graphic summaries ####
# boxplot: to check the symmetry of the distribution, and mainly compares the location and dispersion differences bewteen the 20 microarrays
colors = brewer.pal(9, "Set1")
names = sub("MAINZ_","",colnames(exprs_sample1))
colnames(exprs_sample1) = names
boxplot(exprs_sample1, col = colors, xaxt='n',
        main="Boxplots for 20 randomly selected microarrays",
        ylab="Gene expression")
axis(1,at = 1:20, labels = names, cex.axis=0.4, las = 2)
# The boxplot shows that the dispersions and location are similar for all selected 20 microarrays. Their medians are all around 7

# density plot: the density plot enables us to have an overview of the entire distribution of the data.
exprs_sample1_long = melt(exprs_sample1)
colnames(exprs_sample1_long) = c("Gene", "SubjectID", "Gene_Expression")
dp1 = ggplot(exprs_sample1_long, mapping = aes(fill = SubjectID, x = Gene_Expression)) + geom_density (alpha = 0.2)

dp1 + ggtitle("Density plots for 20 selected subjects")


#### numerical summaries #####
summary(exprs_sample1)

#####################
#### problem 2(b)####
#####################
myPalette = colorRampPalette(rev(brewer.pal(11, "Spectral")))
# Correlation heatmap
# the heatmap is helpful for visualizing the correlation
correlation = cor(exprs_sample1)
levelplot(correlation,col.regions=myPalette, 
          main=" Levelplot for 20 microarrays", scales=list(x=list(rot=90)))

# the lowest correlation is around 0.82, with the majority around 0.9, which is reasonable since we are calculating correlation bewteen the subjects. These people were all breast cancer patient, which it is not suprising that their gene expressions are highly correlated

# smoothed scatterplot
# The plot tells you what gene expressions two subjects have most in common, or density of the points. It can also tell us the correlation and functional form at the same time
# Hypothetically, we can draw such plot for each pair of two subjects(i.e. 190 pairs), but it is too much. So I decide to just check the pairs that have either the biggest correlation or the lowest correlation
max.cor = max(correlation[correlation!=1])
min.cor = min(correlation)

cor.df=as.data.frame(correlation)
max.index=which(correlation==max.cor, arr.ind=T)
min.index=which(correlation==min.cor, arr.ind=T)

max.pairname = rownames(max.index)
min.pairname = rownames(min.index)

smoothScatter(exprs_sample1[,max.pairname[1]],exprs_sample1[,max.pairname[2]],
              main="Smoothed Scatterplot for the pair that has the highest correlation",
              xlab=max.pairname[1],
              ylab=max.pairname[2])

smoothScatter(exprs_sample1[,min.pairname[1]],exprs_sample1[,min.pairname[2]],
              main="Smoothed Scatterplot for the pair that has the lowest correlation",
              xlab=min.pairname[1],
              ylab=min.pairname[2])

correlation
#########################
#### Problem 3 ##########
#########################

# sample a subset of 50 genes
genes = 1:nrow(exprs_sample1)
genes_sample1 = sample(genes,50)

exprs_sample2 = t(exprs_sample1[genes_sample1,])

# boxplot
boxplot(exprs_sample2, col = colors, xaxt='n',
        main="Boxplots for 50 randomly selected genes",
        ylab="Gene expression")
axis(1,at = 1:50, labels = colnames(exprs_sample2), cex.axis=0.4, las = 2)
# The boxplot shows that the dispersions and location are quite different for each of 50 genes

# density plot: the density plot enables us to have an overview of the entire distribution of the data.
exprs_sample2_long = melt(exprs_sample2)
colnames(exprs_sample2_long) = c("SubjectID","Gene", "Gene_Expression")
layer2 = geom_density (alpha = 0.2) 
legend.size = theme(legend.key.size = unit(.1, "cm"))
gg = ggplot(exprs_sample2_long, mapping = aes(fill = Gene, x = Gene_Expression)) 
dp2 = gg + layer2 + legend.size

dp2 + ggtitle("Density plots for 50 selected genes")

# Correlation heatmap
correlation2 = cor(exprs_sample2)
levelplot(correlation2,col.regions=myPalette, 
          main=" Levelplot for  50 genes", scales=list(x=list(rot=90)))

# Heatmap do display the joint distribution of the microarray and genes
png("heatmap.png", width = 1000, height = 700 )
heatmap.2(exprs_sample2, main ="Heatmap for gene expression",
          col = myPalette, xlab = "Genes", ylab="SubjectID", keysize=1, cex.main = 0.5,
          margins = c(7,7))
dev.off()
#########################
#### Problem 4 ##########
#########################
gene203290_at = expression["203290_at",]

# the density plot shows us that there are two groups
plot(density(gene203290_at), xlab="gene expression for gene203290_at",
     ylab="probability", main="Density plot for gene 203290_at across 200 subjects")

# the histogram gives us a more detailed look on the gene expression level to find the threshold for the separation.
hist(gene203290_at,breaks=seq(2,14,by=0.5), 
     xlab="gene expression for gene203290_at",
     main="Density plot for gene 203290_at across 200 subjects")

# from the histogram, we find that gene expression at 8 is a very clear threshold
subject_ind1 = which(gene203290_at>8)
subject_ind2 = which(gene203290_at<=8)

subject_names = colnames(expression)

# the names on the first peak (with higher gene expression)
subject_name1 = subject_names[subject_ind1]
# the names on the first peak (with higher gene expression)
subject_name2 = subject_names[subject_ind2]
# Now, we are able to locate the actual subject name(ID) for each cluster

#########################
#### Problem 5 ##########
#########################
# from the package
feature = fData(mainz)
colnames(feature)
gene.feature = feature[feature$probe == "203290_at",c("Gene.symbol","Nucleotide.Title",
                                                      "Gene.title" , "Chromosome.location",
                                                      "Chromosome.annotation")]


# Now matching the notaiton using hgu133a.db
# 1. Map between Manufacturer Identifiers and Gene Symbols
x <- hgu133aSYMBOL
mapped_probes <- mappedkeys(x)
# Convert to a list
MI.to.GeneSym <- as.list(x[mapped_probes])
# Acquire the Gene symbol for gene 203290_at
MI.to.GeneSym[["203290_at"]]
# Check if it is the same as the one in mainz
MI.to.GeneSym[["203290_at"]] == gene.feature$Gene.symbol

# 2. Map Manufacturer IDs to Chromosomal Location
x2 <- hgu133aCHRLOC
# Get the probe identifiers that are mapped to chromosome locations
mapped_probes2 <- mappedkeys(x2)
# Convert to a list
MI.to.ChrLoc <- as.list(x2[mapped_probes2])
# Acquire the Chromosome Location for gene 203290_at
MI.to.ChrLoc[["203290_at"]]
# Check if it is the same as the one in mainz
MI.to.ChrLoc[["203290_at"]] == gene.feature$Chromosome.location

# 3. description: 
x3 <- hgu133aGENENAME
# Get the probe identifiers that are mapped to a gene name
mapped_probes3 <- mappedkeys(x3)
# Convert to a list
MI.to.name <- as.list(x3[mapped_probes3])
# Acquire gene name for gene 203290_at
MI.to.name[["203290_at"]]
# Compare it with the one in mainz
gene.feature$Nucleotide.Title
MI.to.name[["203290_at"]] == gene.feature$Gene.title
# There are recorded in different format, but they are the same



save.image("PH240C_HW1.RData")
