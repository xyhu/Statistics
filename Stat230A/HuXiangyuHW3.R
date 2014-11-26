### HW3 Name:Xiangyu Hu
##################################
### 1. Create a 100*4 data frame with columns HT, WT, BMI, and random err
### with the following conditions

## Height: normal with mean=66, SD=3
## Weight: normal with mean=180, SD=40, 
## Correlation between height and weight is 0.7.
rho=0.7
## First generate X,Y,and Z as std normal with desired correlations
## bivariate normal
X=rnorm(100,0,1)
Z=rnorm(100,0,1)
Y=rho*X+sqrt(1-rho^2)*Z

## Then transform to get Height, Weight, and random err
HT=66+Y*3
WT=180+X*40

# OLS model HT=a+b*WT+epsilon. 
# Let O=sqrt(1-rho^2)*Z, so Y=rho*X+O => (HT-66)/3=rho*(WT-180)/40+O
# =>HT=66+3*rho*(WT-180)/40+3*O=(66-0.7*3/40*180)+0.7*3/40*WT+3*O
# =>a=66-0.7*3/40*180, b=0.7*3/40, epsilon=3*O
O=sqrt(1-rho^2)*Z
epsilon=3*O

## BMI=(Weight in Pounds/(Height in inches x Height in inches))x703
BMI=(WT/(HT^2))*703

data=data.frame("Height"=HT,"Weight"=WT, "BMI"=BMI, "Random Err"=epsilon)

##################################
### 2. Use OLS to get coefficient estimates for the regression model 
### predicting height based on weight and BMI, including an intercept term.
### You can either use the function(s) you wrote for HW2 or use lm(). 
### What assumptions of the model are violated,if any?(See page42 of text,
### in particular.)

model=lm(HT~WT+BMI)

## Assumption violated: the data on Y are observed values of X*beta+epsilon
## When creating HT, we use HT=a+b*WT+epsilon. 
## However, the fitted model is HT=a+b1*WT+b2*BMI+epsilon. The data HT are 
## not observed values for the fitted model.

##################################
### 3. beta1=0.7*3/40=0.0525 #derivation is in part 1

##################################
### 4. If we use model in part 2, then the estimate of coefficient for 
### weight is biased, because the model includes BMI-correlated with weight
 
##################################
### 5. Plot residuals vs each column of X. (Four plots-note that in practice
### you would not be able to plot vs epsilon but it is kind of fun to be able
### to.) Are epsilon, and residuals orthogonal and/or independent to BMI, HT, 
### WT? (That is a total of 12 questions)

residual=model$residuals
par(mfrow=c(2,2))
plot(residual~HT,xlab="Height")
plot(residual~WT,xlab="Weight")
plot(residual~BMI)
plot(residual~epsilon, xlab="Random Err")

# 1&2)Residuals are NOT independent of BMI, Weight
# 3&4)Residuals are orthogonal to BMI, Weight
# 5)Errors are are independent of Weight
# 6)Errors are NOT orthogonal to Weight
# 7)Residuals are NOT independent of Height
# 8)Residuals are NOT orthogonal to Height
# 9)Errors are NOT independent of Height
# 10)Errors are NOT orthogonal to Height
# 11)Errors are NOT independent of BMI, since BMI is partially determined by height
# 12)Errors are NOT orthogonal to BMI, since BMI is partially determined by height

##################################
### 6. Repeat 1&2 1000 times 
### 7. Plot a histogram of the 1000 values of betahat1, and including a vertical
### line through the corresponding parameter. Comment on whether betahat1 looks
### biased

simulation=function(){
rho=0.7
## First generate X,Y,and Z as std normal with desired correlations
## bivariate normal
X=rnorm(100,0,1)
Z=rnorm(100,0,1)
Y=rho*X+sqrt(1-rho^2)*Z

## Then transform to get Height, Weight, and random err
HT=66+Y*3
WT=180+X*40

O=sqrt(1-rho^2)*Z
epsilon=3*O

## BMI=(Weight in Pounds/(Height in inches x Height in inches))x703
BMI=(WT/(HT^2))*703
# wrong model
fit_wrong=lm(HT~WT+BMI)
coef=fit_wrong$coefficient
# coefficient for weight
betahat1=coef["WT"]

return(betahat1)
}

beta=0.7*3/40
hist(replicate(1000,simulation()),xlim=c(0,0.25))
abline(v=beta,col="red",lwd=5)

### Comment: betahat1 is biased by checking the histogram. The true beta=0.0525
### However, based on the histogram of betahat1 (ranging from 0.15-0.2), the peak
### happens at around 0.18. Thus, it is biased.

##################################




