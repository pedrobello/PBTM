#-----------------Tested Functions - MAc OS and Windows
#
#' A function that calculates the required time and rate to a desired fraction in cumulative curves
#'
#' This function allows you to calculate the time to a desired cumulative fraction and respective germination rate. Use this function on raw data to avoid loss of points closer to the desired cumulative fraction.
#' @param Data time course and cumulative dataset. Several treatments can be used at once as long as it respects the template and column names provided. A column with time in hours (CumTime) + a column with cumulative fractions (CumFract) are required with at least one additional column for relevant treatment (e.g., germination temperature or water potential)
#' @param Fraction from 0 to 1 used to calculate the time required for that level to be obtained in the cumulative time course. Standard value is 0.5 (50 percent), to calculate the time to 50 percent germination (T50) and respective germination rate (GR50). Fraction level can be entered and be used for calculation and change column name.
#' @param Treat1,Treat2,Treat3,Treat4,Treat5 are the names of the treatment columns to separate the dataset. The time course cumulative curves will be grouped for each distinct treatment that should be informed here. These column names do not need to be informed in case the provided template file is used to organize the data.
#' @keywords Tx, GRx, germination speed, germination rate
#' @importFrom dplyr group_by_at
#' @importFrom dplyr tally
#' @importFrom magrittr %>%
#' @export
#' @examples
#' CalcSpeed(MyData)
CalcSpeed <- function(Data, Fraction, Treat1, Treat2, Treat3, Treat4, Treat5)
{
  #Define the informed treatments (columns) to be grouped when calling the function or set standard to all columns besides CumFract and CumTime.
  if (missing(Treat5)) { #Treat5 not informed
    if (missing(Treat4)) { #Treat4 not informed
      if (missing(Treat3)) { #Treat3 not informed
        if (missing(Treat2)) { #Treat2 not informed
          if (missing(Treat1)) { #Treat1 not informed
            TreatColNames <- c("Treat.ID","Treat.desc","Treat.aging.time","Treat.priming.wp","Treat.priming.temp","Treat.priming.duration","Germ.wp","Germ.temp", "Germ.promoter.dosage", "Germ.inhibitor.dosage")
          } else {TreatColNames <- c(Treat1)}
        } else {TreatColNames <- c(Treat1,Treat2)}
      } else {TreatColNames <- c(Treat1,Treat2,Treat3)}
    } else {TreatColNames <- c(Treat1,Treat2,Treat3,Treat4)}
  } else {TreatColNames <- c(Treat1,Treat2,Treat3,Treat4,Treat5)}

  #Define the informed fraction for time and rate calculation. Standard is 0.5 -> 50 percent. Also populates new column name base in the fraction used.
  if (missing(Fraction)) { #Fraction not informed
    Frac <- 0.5
    FracSpeedLbl <- "T50"
    FracRateLbl <- "GR50"
  } else {
    Frac <- Fraction
    FracSpeedLbl <- paste("T",(Frac*100), sep = "")
    FracRateLbl <- paste("GR",(Frac*100), sep = "")
  }

  # Calculate the time to the fraction selected using linear interpolation (approx function) after it calculates the inverse of time to generate the rate.
  Treatments <- Data %>% group_by_at(TreatColNames) %>%
    dplyr::mutate(Tx = approx(CumFract,CumTime, xout=Frac, ties="ordered")$y,
                  GRx = 1/approx(CumFract,CumTime, xout=Frac, ties="ordered")$y)

  TreatColNames <- c(TreatColNames, "Tx", "GRx")

  # Separate all treatments without germination time courses
  Treatments <- Treatments %>% group_by_at(TreatColNames) %>% tally()

  #Replaces the column name with the used fraction instead.
  names(Treatments)[names(Treatments) == "Tx"] <- FracSpeedLbl
  names(Treatments)[names(Treatments) == "GRx"] <- FracRateLbl

  return(Treatments)
}


#' A Function to plot rate vs desired treatment.
#'
#' This function plots rates against the desired treatment.
#' @param Data should inform the table that resulted from the CalcSpeed function. It should have the summarized treatments and respective GR values.
#' @param x should indicate the treatment column name for the x axis (e.g., "Germ.temp", "Germ.wp" or others).
#' @param y should indicate the rate column name for the y axis if different than GR50 (e.g., "GR90", "GR10", etc).
#' @keywords plot rates Temperature
#' @import ggplot2
#' @export
#' @examples PlotRateVsTreat(MyCalcSpeedData,"Germ.temp")
#' PlotRateVsTreat(MyCalcSpeedData,"Germ.temp")
PlotRateVsTreat <- function (Data, x, y)
{
  Treatments <- Data
  if (missing(x)) { #x/treatment not informed
    print("Informed treatment for x axis.")
  } else {
    Treat <- x
  }
  if (missing(y)) { #y/rate not informed
    rate <- "GR50"
  } else {
    rate <- y
  }
  pGR <- ggplot(data=Treatments, aes_string(x=Treat, y=rate, color=Treat)) + geom_point(shape=19, size=2) +
    expand_limits(x = 0, y = 0) + theme_scatter_plot
  pGR
}


#' A Function to plot the cumulative raw data selected.
#'
#' This function plots the raw data previously selected. It will plot raw cumulative curves over time.
#' @param Data with time course data for one or more treatments.
#' @param Treat1,Treat2 are the desired treatment factors to be informed as column names. The first informed treatment will be separated as color and the second as shape.
#' @keywords plot raw data
#' @import ggplot2
#' @export
#' @examples PlotRawDt(MyData,"Germ.temp")
#' PlotRawDt(MyRawData,"Germ.temp")
PlotRawDt <- function(Data, Treat1, Treat2)
{
  TreatData <- Data
  #MaxTime <- TreatData$CumTime[which.max(TreatData$CumTime)] #Gets the longest time measurement in the dataset provided.
  #PlotTime <- ceiling(MaxTime/5)*5 #make maxTime a multiple of 5 - ceiling() rounds up
  #Increment <- round(PlotTime/5, digits = 0) #define tick mark separation

  gp <- "geom_point(shape=19, size=2)" #Add standard fixed shape in case shape is not used as the second factor

  if (missing(Treat1)) { #treatment 1 not informed
    print("Informed treatment for factor.")
  } else {
    eval(parse(text=paste("TreatData$",Treat1, " <- (factor(TreatData$",Treat1,"))", sep = "")))
    T1 <- Treat1
  }
  if (missing(Treat2)) { #treatment 2 not informed
    T2 <- NA
  } else {
    gp <- "geom_point(size=2)" #Add fixed shape in case shape is not used as the second factor
    eval(parse(text=paste("TreatData$",Treat2, " <- (factor(TreatData$",Treat2,"))", sep = "")))
    T2 <- Treat2
  }
  #if (missing(Treat3)) { #treatment 3 not informed - possible in the near future
  #  T3 <- NA
  #  alph <- ""
  #} else {
  # eval(parse(text=paste("(as.factor(TreatData$",Treat3,"))", sep = "")))
  #  T3 <- Treat3
  #  alph <- "color=T1, shape=T2, alpha=T3"
  #}

  #Plot All Treatments with fitted equation (Whole data plot here, including repetitive percentages)
  pRaw <<- ggplot(data=TreatData, aes_string(x="CumTime", y="CumFract", color=T1, shape=T2 )) +
    eval(parse(text=gp)) + geom_line() + xlab("Time") + ylab("Cumulative (%)") +
    scale_y_continuous(labels = scales::percent, expand = c(0,0), limits = c(0,1.02)) +
    scale_x_continuous(expand = c(0,0)) + expand_limits(x = 0, y = 0) +
    theme_scatter_plot
  pRaw
}

#' A Function to clean cumulative curves on dataset.
#'
#' This function removes repetitive cumulative fractions/percentages, keeping only the initial presence of the value
#' @param Data object with the raw cumulative data that needs to be removed.
#' @param Treat1,Treat2,Treat3,Treat4,Treat5 are the names of the treatment columns to separate the dataset. The time course cumulative curves will be grouped for each distinct treatment that should be informed here.
#' @keywords Clean cumulative fraction repetitive percentage
#' @importFrom dplyr distinct
#' @export
#' @examples CleanData(mydata,"Treat.desc")
#' CleanData(mydata,"Treat.desc")
CleanData <- function(Data, Treat1, Treat2, Treat3, Treat4, Treat5) {
  #Clean Repetitive Percentages (keeps only initial presence of value)

  if (missing(Data)) { #data object not informed
    print("Informe the data object.")
  } else {
    TreatData <- Data
    if (missing(Treat1)) { #treatment 1 not informed
      print("Informed treatment for factor.")
    } else {
      T1 <-  Treat1
      if (missing(Treat2)) { #treatment 2 not informed
        T2 <- ""
      } else {
        T2 <- paste(",",Treat2, sep = "")
      }
      if (missing(Treat3)) { #treatment 3 not informed
        T3 <- ""
      } else {
        T3 <- paste(",",Treat3, sep = "")
      }
      if (missing(Treat4)) { #treatment 2 not informed
        T4 <- ""
      } else {
        T4 <- paste(",",Treat4, sep = "")
      }
      if (missing(Treat5)) { #treatment 2 not informed
        T5 <- ""
      } else {
        T5 <- paste(",",Treat5, sep = "")
      }

      TreatDataClean <- eval(parse(text=paste("distinct(TreatData,",T1,T2,T3,T4,T5,",CumFract, .keep_all = TRUE)", sep="")))

      return(TreatDataClean)
    }
  }
}

#ggplot package theme ----------------------------------------------------------------------------------
theme_scatter_plot <- theme(
  legend.background = element_blank(),
  legend.key = element_blank(),
  legend.title = element_text(size=12, color ="black"),
  legend.text = element_text(size=12, color ="black"),
  panel.background = element_blank(),
  panel.grid.minor.y=element_blank(),
  panel.grid.major.x=element_blank(),
  panel.grid.major.y=element_blank(),
  panel.grid.minor.x= element_blank(),
  panel.border = element_rect(colour = "grey50", fill=NA, size=0.5),
  strip.background = element_rect(colour="black", fill="white"),
  axis.ticks = element_line(color = "black", size =0.5),
  axis.text = element_text(size=12, color ="black"),
  axis.title = element_text(size=14, color ="black",face = "bold"),
  axis.title.x = element_text(margin = margin(t = 10, r = 0, b = 0, l = 0)),
  plot.title = element_blank())


#----------------------New Development - Under Testing