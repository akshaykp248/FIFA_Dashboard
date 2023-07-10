#setwd("~/Spring 2022/SDM-2/SDM2 Project")
#setwd("/Users/akshaypandey/Downloads/May_3_files")
#Activating packages
library(data.table)
library(ggplot2)
library(tidyr)
library(cluster)
library(factoextra)
library(gridExtra)
library(dplyr)
library(shiny)
library(shinydashboard)
library(reshape2)

#install.packages('plotrix')
library(plotrix)

#Importing data set prepared for for Non-Goalkeeper and Goalkeeper in Phase 2

train_data_non_gk= fread('train_non_gk.csv')
train_data_gk = fread('train_gk.csv')

test_data_non_gk = fread('test_non_gk.csv')
test_data_gk = fread('test_gk.csv')

#Features that worked best for our Random Forest Model Along with the Release Clause outcome
rf_columns_non_gk = list('Age','Wage','Potential','Forward','Mid','Back','General','Release Clause')
rf_columns_gk = list('Age','Wage','Potential','General','GK','Release Clause')


#install.packages('randomForest')   
library(randomForest)

features<-(colnames(train_data_non_gk) %in% c(rf_columns_non_gk))
features_gk <-(colnames(train_data_gk) %in% c(rf_columns_gk))

#Designing RF model for Both the datasets
tr_data = subset(train_data_non_gk,,features)
rf_model <- randomForest(x <- tr_data[ , -c('Release Clause')], y <- tr_data$`Release Clause`, ntree = 5)

tr_data_gk = subset(train_data_gk,,features_gk)
rf_model_gk <- randomForest(x <- tr_data_gk[ , -c('Release Clause')], y <- tr_data_gk$`Release Clause`, ntree = 5)

#Implementing Logistic Regression

bin_data = fread('bin_data.csv')
#bin_features <- c('Age','Special','Potential','Wage','General')
#tr_bin_data = bin_data[,c('Age','Special','Potential','Wage','General')]

log_model = glm(formula =  Class~Age+Special+Potential+Wage+General,data = bin_data,family = binomial )

#summary(log_model)

# Shiny Server
server <- shinyServer(function(input,output){
    test <- reactiveValues(result = NULL)
    output$clustdata <- renderTable(data1[1:200,])
    
    output$summaryDset <- renderPrint({
        summary(train_data_non_gk[[input$informedDset]]) 
    })
    output$summaryDset_gk <- renderPrint({
      summary(train_data_gk[[input$informedDset_gk]]) 
    })
    output$summaryCat <- renderPrint({
        table(train_data_non_gk[[input$informedCat]])
    }) 
    output$summaryCat_gk <- renderPrint({
      table(train_data_gk[[input$informedCat_gk]])
    }) 
    #-----------------------Plot Data Display-----------------------------------------------------------
    output$scatter_plot_1 <- renderPlot({
      plot(bin_data$Potential, bin_data$Wage, main = "Wage Vs Potential",xlab = "Potential", ylab = "Wage (In Thousands)",pch = 19, frame = FALSE)
    })
    output$scatter_plot_2 <- renderPlot({
      plot(bin_data$Potential, bin_data$Age, main = "Age Vs Potential",xlab = "Potential", ylab = "Age (In Years)",pch = 19, frame = FALSE)
    })
    output$box_plot_1 <- renderPlot({
      ggplot(train_data_gk) + geom_bar(aes(x = factor(Nationality),fill = Nationality))+labs(title = 'Nation-Wise Non-Goalkeeper Data')
      })
    output$hist_plot_1 <- renderPlot({
        ggplot(bin_data) + geom_bar(aes(x = factor(Position),fill = Position))+labs(title = 'Position-Wise Data')
    })
    output$scatter_plot_3 <- renderPlot({
      plot(train_data_gk$Age, train_data_gk$General, main = "Age Vs General Score of Goalkeepers",xlab = "Age", ylab = "General Score",pch = 19, frame = FALSE)
    })
    output$scatter_plot_4 <- renderPlot({
      plot(train_data_non_gk$Age, train_data_non_gk$General, main = "Age Vs General Score of Non Goalkeepers",xlab = "Age", ylab = "General Score",pch = 19, frame = FALSE)
    })
    output$scatter_plot_5 <- renderPlot({
      plot(bin_data$Special, bin_data$Potential, main = "Special Vs Potential Score of Non-Goalkeepers",xlab = "Special", ylab = "Potential",pch = 19, frame = FALSE)
    })
    output$scatter_plot_6 <- renderPlot({
      plot(bin_data$Special, bin_data$Age, main = "Special Vs Age of all players",xlab = "Special", ylab = "Age",pch = 19, frame = FALSE)
    })
    #-----------------------Raw Data Display-----------------------------------------------------------
    output$rawdata <- renderTable(train_data_non_gk)
    output$rawdata_gk <- renderTable(train_data_gk)
    #-----------------------Prediction: Non-Goalkeeper-------------------------------------------------
    observeEvent(input$pred, {
      pred_data = data.frame(
        Wage =input$wage,
        Potential= input$potential,
        General=input$general,
        Age = input$age,
        Forward = input$forward,
        Mid = input$mid,
        Back = input$back
        )
      test$pred_result = round(predict(rf_model, pred_data))
    })
    output$result_prediction = renderText({paste(test$pred_result)})
    #-----------------------Prediction: Goalkeeper-----------------------------------------------------
    observeEvent(input$pred_gk, {
      pred_data_gk = data.frame(
        Wage =input$wage_gk,
        Age = input$age_gk,
        Potential= input$potential_gk,
        General=input$general_gk,
        GK= input$gk_gk)
      test$pred_result_gk = round(predict(rf_model_gk, pred_data_gk))
      
    })
    output$result_prediction_gk = renderText({paste(test$pred_result_gk)})
    #--------------------------Classification of Players----------------------------------------------------
    observeEvent(input$classify, {
      class_bin_data = data.frame(
        Age = input$age_bin,
        Wage =input$wage_bin,
        Potential= input$potential_bin,
        General=input$general_bin,
        Special = input$special_bin)
      ans = round(predict(log_model, class_bin_data))
      if(ans > 0){
        test$classification_result = 'Goalkeeper'
      }else{
        test$classification_result = 'Non Goalkeeper'
      }
    })
    output$result_classification = renderText({paste(test$classification_result)})
    
})















