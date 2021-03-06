% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/PBTMsFunctions.R
\name{CalcTTSubOModel}
\alias{CalcTTSubOModel}
\title{A Function to calculate the Thermaltime model parameters. ------------------------}
\usage{
CalcTTSubOModel(Data, MaxCumFraction)
}
\arguments{
\item{Data}{time course and cumulative dataset to be used in the Thermaltime model. The original dataframe template should be used or column names should be modified similarly to the template. A column with time in hours (CumTime) + a column with cumulative fractions (CumFraction) and the experiment temperature (Germ.temp) are required. Filter the dataframe to only have treatments with temperature equal or under to  optimal temperature level.}

\item{MaxCumFraction}{sets the ceiling cumulative fraction for the model when treatment at optimal condition displays a lower maximum cumulative fraction. Use it on your own discretion.}
}
\description{
This function calculates the temperature base (Tb), the thermal time to 50% of the population (ThetaT50) and the standard deviation (sigma).
}
\examples{
CalcTTSubOModel(myData)
CalcTTSubOModel(myData)

}
\keyword{Thermal}
\keyword{model}
\keyword{parameters}
\keyword{time}
