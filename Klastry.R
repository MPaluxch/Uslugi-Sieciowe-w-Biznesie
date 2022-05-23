library(tidyverse); library(cluster)
library(DT); library(factoextra)
library(gridExtra); library(ggcorrplot)
library(ggplot2)

setwd("C:/Users/macie/Desktop/ToDoList/USB_Raport")
getwd()

dane <- read.csv2("KNIME_Sales_Data.csv", sep= ",")
dane <- dane[,-1]
dane$Total.Price <- as.numeric(dane$Total.Price)

## Klastrowanie

dane2 <- as.data.frame(aggregate(dane$Total.Price, list(Item = dane$Product), sum))

dane2 <- cbind(dane2, aggregate(dane$Quantity.Ordered, list(Item = dane$Product), sum))
dane2 <- dane2[,-c(3)]
colnames(dane2) <- c("Item","Total.Price","Quantity.Ordered") 

dane2

summary(dane2)

sapply(dane2, function(x) sd(x) / mean(x) * 100)

dane2a <- select(dane2, Total.Price, Quantity.Ordered)

dane2a

## standaryzacja zmiennych
danestand <- as.data.frame(scale(dane2a, center = T, scale = T))
head(danestand, 10)
summary(danestand)

danestand <- danestand[,c(2,1)]
danestand

kmeans(danestand, centers = 4, nstart = 25)

## Wykresy od K=2 do K=5
plot_list <- list()
for (i in 2:6){
  plot_list[[i]] <- (fviz_cluster(kmeans(danestand, centers = i, nstart = 25), danestand, geom="point", 
                                  main=paste0("Metoda k-œrednich K=", i), ggtheme=theme_minimal()))
}
grid.arrange(plot_list[[2]],plot_list[[3]],plot_list[[4]],plot_list[[5]],plot_list[[6]])
plot(danestand$Quantity.Ordered, danestand$TotalPrice)

dane2

ggplot(dane2, aes(Quantity.Ordered, Total.Price, color=Quantity.Ordered)) + geom_point(size=3) + 
       theme_minimal() + labs(title = "Scatter Plot") 

plot(dane2$Quantity.Ordered,dane2$Total.Price)
plot(danestand$Quantity.Ordered, danestand$Total.Price)

## Metoda Elbow
fviz_nbclust(danestand, kmeans, method="wss") +
  theme_minimal() +
  ggtitle("Metoda Elbow")

## Metoda Silhoutte
fviz_nbclust(danestand, kmeans, method = 'silhouette') +
  theme_minimal() +
  ggtitle("Metoda Silhoutte")


## Tworzenie modeli
model <- kmeans(danestand, centers = 3, nstart = 25)
model

## Show plot
fviz_cluster(model, danestand, geom="point", 
             main=paste0("Metoda k-œrednich dla K = ", 3), ggtheme=theme_minimal())

## Wnioski:
## Z powyzszej grafiki mozna wywynioskowac ze:
## Do klastra 1 naleza przedmioty o duzej ilosci zamowien lacznie, ale tez generujace maly zarobek
## Do klastra 2 naleza przedmioty o malej ilosci zamowien lacznie ale generujace bardzo duzy zarobek
## Do klastra 3 naleza przemioty o stosunkowo niewielkiej ilosci zamowien, i generujaca stosunkowo niski zarobek

clusters <- mutate(dane2, cluster = model$cluster)
clusters





