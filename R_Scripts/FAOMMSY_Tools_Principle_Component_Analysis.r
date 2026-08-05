## Principal component analyses
#
# This R script allows you to reproduce the kind of PCA analysis discussed in the main text

# Start by preparing the R space
rm(list=ls())

## Libraries
# Data handling and table reshaping
library(tidyverse)
library(reshape2)
library(devtools)
# Plotting
library(ggplot2)
library(RColourBrewer)
library(ggbiplot)
library("plot3D")
library(plotly)
# PCA and Clustering
library(factoextra)
library (FactoMineR)
library(corrplot)
library(ape)

# Set up data for PCA – with Year as rows and columns as species
CatchData <-read.table("CatchData.csv", header=TRUE, sep = ",")

DataSum <- CatchData %>%
  group_by(Year, PCA_CLASSIF) %>%
  dplyr::summarise(TotalYield = sum(Yield))
SP_as_col <- dcast(DataSum, Year ~ PCA_CLASSIF, value.var = "TotalYieldGrp", fill = 0)

# PCA calculations - using spectral decomposition approach via the princomp approach
# Create string of column names to tell function which columns to use in the analysis
dimC <- dim(SP_as_col)
pc.f <- formula(paste("~", paste(names(SP_as_col)[2:dimC[2]], collapse = "+")))

# PCA calculations - using spectral decomposition approach via the princomp approach
pl.pca <- princomp(pc.f, cor=TRUE, data=SP_as_col)

# Print out PCA loadings
pl.pca$loadings

# Print PCA summary – showing variance explained
summary(pl.pca)

# If you would rather use singular value decomposition instead for the PCA then the command is
pl.pca <- prcomp(SP_as_col, scale = TRUE)

# Regardless of the method used plot the variance explained
fviz_eig(pl.pca)

## Create a plot of the PCA space – 2D
PoV <- pl.pca$sdev^2/sum(pl.pca$sdev^2) # Variance explained (so can put it on the axis labels)

# Sort labels to put on the plot
row.names(pl.pca$scores) <- SP_as_col$Year
pcx <- pl.pca$scores[,1]
pcy <- pl.pca$scores[,2]
pcz <- pl.pca$scores[,3]
pcxlab <- paste("PC1 (", round(PoV[1] * 100, 2), "%)")
pcylab <- paste("PC2 (", round(PoV[2] * 100, 2), "%)")
pczlab <- paste("PC3 (", round(PoV[3] * 100, 2), "%)")

# Plot the results
df <- data.frame(comp1=pl.pca$scores[,1], comp2=pl.pca$scores[,2])
ggplot(data = df, aes(x=comp1, y=comp2, group=1)) +
  geom_point(size=5, aes(colour=rownames(pl.pca$scores))) +
  geom_path(size = 0.2) +
  geom_text(label=rownames(pl.pca$scores)) + 
  theme(legend.position="none")

# An alternative way of making a plot of the 2D space is
fviz_pca_ind(pl.pca,
             col.ind = "contrib", # Colour by congtribution
             gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
             repel = TRUE,     # Avoid text overlapping
             #label=SP_as_col$Year
) + labs(title ="PCA", x = "PC1", y = "PC2")

# To put the vectors of the variables on to the biplot
fviz_pca_var(pl.pca,
             col.var = "contrib", # Colour by contributions to the PC
             gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
             repel = TRUE     # Avoid text overlapping
)

# Compute hierarchical clustering on principal components
res.pca <- PCA(SP_as_col, ncp = 3, graph = FALSE)
res.hcpc <- HCPC(res.pca, graph = FALSE)

# Plot the resulting dendrogram
fviz_dend(res.hcpc, 
          cex = 0.7,                     # Label size
          palette = "jco",               # Colour palette see ?ggpubr::ggpar
          rect = TRUE, rect_fill = TRUE, # Add rectangle around groups
          rect_border = "jco",           # Rectangle colour
          labels_track_height = 0.8      # Augment the room for labels
)

# Now replot the PCA space with those clusters marked
fviz_cluster(res.hcpc,
             repel = TRUE,            # Avoid label overlapping
             show.clust.cent = TRUE, # Show cluster centers
             palette = "jco",         # Colour palette see ?ggpubr::ggpar
             ggtheme = theme_minimal(),
             main = "Factor map"
)

## Create a plot of the PCA space – 3D
# Plot simply as points in 3D space
scatter3D(pcx, pcy, pcz, bty = "g", pch = 20, cex = 2, 
          col = gg.col(100), theta = 150, phi = 0, main = "PCA Scores", xlab = pcxlab,
          ylab =pcylab, zlab = pczlab)
text3D(pcx, pcy, pcz,  labels = rownames(pl.pca$scores), add = TRUE, colkey = FALSE, cex = 0.7)

# 3D plot with connected line showing path through time
scatter3D(pcx, pcy, pcz, bty = "g", type = "b", pch = 20, cex = 2, 
          col = gg.col(100), theta = 150, phi = 0, lwd = 4, main = "PCA Scores", xlab = pcxlab,
          ylab =pcylab, zlab = pczlab)
text3D(pcx, pcy, pcz,  labels = rownames(pl.pca$scores), add = TRUE, colkey = FALSE, cex = 0.7)

# Plot3D with plotly 
# Which allows interaction with the plot, you can spin it, zoom and hover over data points and see the associated data values)
manual_palette <- c("#551A8B", "#8968CD", "#AB82FF", "#FF8C00", "#CD6600", "#8B4500")
df3D <- data.frame(comp1=pl.pca$scores[,1],
                   comp2=pl.pca$scores[,2],
                   comp3=pl.pca$scores[,3])
fig <- plot_ly(df3D, x = ~comp1, y = ~comp2, z = ~comp3, colour = ~comp3,  mode = 'lines+markers',
               # Hover text:
               text = ~rownames(pl.pca$scores))
fig <- fig %>% add_markers()
fig <- fig %>% add_text(textposition = "top right")
fig <- fig %>% layout(scene = list(xaxis = list(title = pcxlab),
                                   yaxis = list(title = pcylab),
                                   zaxis = list(title = pczlab)),
                      annotations = list(
                        x = 1.13,
                        y = 1.05,
                        text = 'PC3 Score',
                        showarrow = FALSE
                      ))
fig  # Plot the final figure

## Correlation analysis
M <-cor(SP_as_col, method="pearson")   # For Pearson correlation
M <-cor(SP_as_col, method="spearman") # For Spearman correlation

# Plot resulting correlations
corrplot(M, type="upper", order="hclust", col=brewer.pal(n=8, name="RdYlBu"), tl.col="black", tl.cex=0.4) 
