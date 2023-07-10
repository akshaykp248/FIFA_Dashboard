#install.packages('sass')
#install.packages("bslib")
library(bslib)
library(sass)
library(shiny)
library(shinydashboard)
library(dashboardthemes)


# User Interface

ui <- shinyUI(
    dashboardPage(
        dashboardHeader(title ="FIFA Analytics Dashboard",titleWidth = "350px"),
        dashboardSidebar(
            sidebarMenu(
                style = "position: fixed; overflow: visible;",
                menuItem("Non Goalkeepers Data",tabName = "raw",icon=icon("table")),
                menuItem("Goalkeepers Data",tabName = "raw_gk",icon=icon("table")),
                menuItem("Data - Summary",tabName = "summary",icon=icon("lock-open",lib="font-awesome")),
                menuItem("EDA - Plots",tabName = "plots",icon=icon("table")),
                menuItem("Prediction Data",tabName = "finaldata",icon=icon("table"))
                #menuItem("Classification Data",tabName = "final_class_data",icon=icon("table"))
            )),
        dashboardBody(
          shinyDashboardThemes(
            #Changeable theme
            theme = "blue_gradient"
          ),
            
            tabItems(
                #TAB for EDA Plots
                tabItem(tabName = "plots",h1("Exploratory Analysis - Plots"),
                
                fluidRow(
                  box(plotOutput("hist_plot_1"), width=12)
                  ),
                fluidRow(
                  #box(plotOutput("box_plot_1"), width = NULL,
                      #style = "overflow-x: scroll")
                  box(plotOutput("scatter_plot_5")),
                  box(plotOutput("scatter_plot_6"))
                ),
                fluidRow(
                  box(plotOutput("scatter_plot_1")),
                  box(plotOutput("scatter_plot_2"))
                  
                ),
                fluidRow(
                    box(plotOutput("scatter_plot_3")),
                    box(plotOutput("scatter_plot_4"))
                )
                
                ),
                
                #TAB for Raw data of Non-Goalkeepers
                tabItem(tabName = "raw",h1("Non-Goalkeeper Data"),
                        fluidRow(
                          box(title = "Player Data", 
                              status = "primary", 
                              solidHeader = TRUE,
                            width = NULL,
                            style = "overflow-x: scroll",
                            tableOutput("rawdata"))
                          )),
                #TAB for Raw data for Goalkeepers
                tabItem(tabName = "raw_gk",h1("Goalkeeper Data"),
                        fluidRow(
                          box(title = "Player Data", 
                              status = "primary", 
                              solidHeader = TRUE,
                              width = NULL,
                              style = "overflow-x: scroll",
                              tableOutput("rawdata_gk"))
                        )),
                
                #TAB for Descriptive Statistics
                tabItem(tabName = "summary",h1("Understanding The Data"),
                        fluidRow(
                            box(title = "Non-Goalkeeper Attribute", 
                                status = "primary", 
                                solidHeader = TRUE,
                                width = 6,
                                selectInput("informedDset", label="Select Category",
                                            choices = list('Age','Potential','Wage','Special','Height','Weight','Joined','Contract Valid Until','Forward','Mid','Back','General'), selected = "Age")
                                ),
                            box(title = "Goalkeeper Attribute", 
                                status = "primary", 
                                solidHeader = TRUE,
                                width = 6,
                                selectInput("informedDset_gk", label="Select Category",
                                            choices = list('Age','Potential','Wage','Special','Height','Weight','Joined','Contract Valid Until','General'), selected = "Age")
                            )
                            ),
                        fluidRow(
                            box(
                                title = "Non-Goalkeeper Attribute Statistics", 
                                status = "warning", 
                                solidHeader = TRUE,
                                width = 6,
                                height = 142,
                                verbatimTextOutput("summaryDset")),
                            box(
                              title = "Goalkeeper Attribute Statistics", 
                              status = "warning", 
                              solidHeader = TRUE,
                              width = 6,
                              height = 142,
                              verbatimTextOutput("summaryDset_gk"))
                        ),
                        fluidRow(  
                            box(title = "Non-Goalkeeper Attribute NC", 
                                status = "primary", 
                                solidHeader = TRUE,
                                width = 6,
                                selectInput("informedCat", label="Select Categorical Variable",
                                            choices = list('Nationality','Club','Preferred Foot','Work Rate'), selected = "Preferred Foot")
                            ),
                            box(title = "Goalkeeper Attribute NC", 
                                status = "primary", 
                                solidHeader = TRUE,
                                width = 6,
                                selectInput("informedCat_gk", label="Select Categorical Variable",
                                            choices = list('Nationality','Club','Preferred Foot','Work Rate'), selected = "Preferred Foot")
                            )
                        ),
                        fluidRow(      
                            box(
                                title = "Attribute Statistics NC", 
                                status = "warning", 
                                solidHeader = TRUE,
                                width = 6,
                                #height = 160,
                                verbatimTextOutput("summaryCat")),
                            box(
                              title = "Attribute Statistics NC", 
                              status = "warning", 
                              solidHeader = TRUE,
                              width = 6,
                              #height = 160,
                              verbatimTextOutput("summaryCat_gk"))
                        )
                        ),
                #TAB for Prediction
                tabItem(tabName = "finaldata",h1("Predict Release Clause"),
                        fluidRow(
                          box(title = "Enter Non-Goalkeeper Player Data", 
                              status = "primary", 
                              solidHeader = TRUE,
                              width = 6,
                              sliderInput( 'age', 'Age', min = 0, max = 50, value = 0),
                              div(),
                              sliderInput( 'potential', 'Potential', min = 0, max = 100, value = 0),
                              div(),
                              sliderInput( 'forward', 'Forward', min = 0, max = 100, value = 0),
                              div(),
                              sliderInput( 'mid', 'Mid', min = 0, max = 100, value = 0),
                              div(),
                              sliderInput( 'back', 'Back', min = 0, max = 100, value = 0),
                              div(),
                              sliderInput( 'general', 'General Score', min = 0, max = 100, value = 0),
                              div(),
                              numericInput( 'wage', 'Wage (in Thousands)', 0),
                              actionButton('pred','Predict', icon = icon('calculator')),
                              div(h5('Release Clause of the Player:')),
                              verbatimTextOutput("result_prediction", placeholder = TRUE)
                              ),
                          box(title = "Enter Goalkeeper Player Data", 
                              status = "warning", 
                              solidHeader = TRUE,
                              width = 6,
                              sliderInput( 'age_gk', 'Age', min = 0, max = 50, value = 0),
                              div(),
                              sliderInput( 'potential_gk', 'Potential', min = 0, max = 100, value = 0),
                              div(),
                              sliderInput( 'gk_gk', 'GK Score', min = 0, max = 100, value = 0),
                              div(),
                              sliderInput( 'general_gk', 'General Score', min = 0, max = 100, value = 0),
                              div(),
                              numericInput( 'wage_gk', 'Wage (in Thousands)', 0),
                              actionButton('pred_gk','Predict', icon = icon('calculator')),
                              div(h5('Release Clause of the Player:')),
                              verbatimTextOutput("result_prediction_gk", placeholder = TRUE)
                          )
                          
                          )),
            
            #TAB for Classification
            tabItem(tabName = "final_class_data",h1("Classification of Players"),
                    fluidRow(
                      #Age+Special+Potential+Wage+General
                      box(title = "Enter Non-Goalkeeper Player Data", 
                          status = "primary", 
                          solidHeader = TRUE,
                          width = 6,
                          sliderInput( 'age_bin', 'Age', min = 0, max = 50, value = 0),
                          div(),
                          sliderInput( 'potential_bin', 'Potential', min = 0, max = 100, value = 0),
                          div(),
                          sliderInput( 'general_bin', 'General Score', min = 0, max = 100, value = 0),
                          div(),
                          numericInput( 'wage_bin', 'Wage (in Thousands)', 0),
                          div(),
                          numericInput( 'special_bin', 'Special Score', 0),
                          actionButton('classify','Classify', icon = icon('calculator')),
                          div(h5('Class of the Player:')),
                          verbatimTextOutput("result_classification", placeholder = TRUE)
                      )
                      
                    )
            )
            
            ))))
