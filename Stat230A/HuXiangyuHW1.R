###  HW 1   Your Name:Xiangyu Hu
###
###  Part 1.
###
### 1. put your code here for loading the data, write comments if anything
### isn't obvious.

load("D:/ÕýÊÂ/Berkeley/Courses/Stat230A/family.rda")
head(family)
#Output
#  firstName gender age height weight      bmi overWt
#1       Tom      m  77     70    175 25.16239   TRUE
#2       May      f  33     64    125 21.50106  FALSE
#3       Joe      m  79     73    185 24.45884  FALSE
#4       Bob      m  47     67    156 24.48414  FALSE
#5       Sue      f  27     64    105 18.06089  FALSE
#6       Liz      f  33     68    190 28.94981   TRUE

## Predicting weight from height
## height as covariate
x=family[,4]
## weight as response variable
y=family[,5]

## Find the equation for the regression line predicting weight from height in the dataset 
r=cor(x,y)
## length of x, and y
n_y=length(y)
n_x=length(x)
## calculating the sd using n as denominator instead of n-1
var_y=var(y)*(n_y-1)/n_y
var_x=var(x)*(n_x-1)/n_x
sd_y=sqrt(var_y)
sd_x=sqrt(var_x)
## calculating the mean of x, and y
y_bar=mean(y)
x_bar=mean(x)
## calculating the slope(b_hat)and intercept(a_hat)
b_hat=r*sd_y/sd_x
a_hat=y_bar-b_hat*x_bar
coef=c("Intercept"=a_hat,"Slope"=b_hat)
coef
#Output:
#Intercept     Slope 
#-455.6660    9.1537 

### 2. Write the function regcoef() as described in the assignment.
### You can change what I did but this is a suggestion as to how I'd
### start off writing the function.  For example it's not necessary to
### have a default for df but if you are going to be
### running and testing your function it will save typing.

regcoef=function(d){
  # This function takes input of a data frame and returns regression 
  # coefficients predicting the second variable from the first.
  if(!is.data.frame(d) | ncol(d) != 2 ) {
     stop( "Error: wrong data entry. Please provide data frame with 2 columns" )
  }      
  x=d[,1]
  y=d[,2]

  ## Find the equation for the regression line 
  r=cor(x,y)
  ## length of x, and y
  n_y=length(y)
  n_x=length(x)
  ## calculating the sd using n as denominator instead of n-1
  var_y=var(y)*(n_y-1)/n_y
  var_x=var(x)*(n_x-1)/n_x
  sd_y=sqrt(var_y)
  sd_x=sqrt(var_x)
  ## calculating the mean of x, and y
  y_bar=mean(y)
  x_bar=mean(x)
  ## calculating the slope(b_hat)and intercept(a_hat)
  b_hat=r*sd_y/sd_x
  a_hat=y_bar-b_hat*x_bar
  coef=c("Intercept"=a_hat,"Slope"=b_hat)
     
  return (coef)
}
d=family[,4:5]
regcoef(d)
#Output:
#Intercept     Slope 
#-455.6660    9.1537 
 
### 3. Similarly, write the regline() function.

regline=function(d){
  # This function plots points and regression line, doesn't need to return
  # anything.
  # Testing of correct data format will be carried out by function regcoef()
  coefs=regcoef(d)
  name=colnames(d)
  plot(d[,2]~d[,1],xlab=name[1],ylab=name[2])
  abline(coefs,col="red")
}
d=family[,4:5]
regline(d)