xUnique = 1:5
trueCoeff = c(0, 1, 1)

getData = function(coefs = c(0, 1, 1), xs = 1:5, dupl = 10,
                   sd = 5, seed=2222){
  ### This function creates the artificial data
  set.seed(seed)
  x = rep(xs, each = dupl)
  y = coefs[1] + coefs[2]*x + coefs[3] * x^2 + 
      rnorm(length(x), 0, sd)
  return(data.frame(x, y))
}

data=getData()

##### Part1 ####
### 
genBootY = function(x, y, rep){
  ### For each unique x value, take a sample of the
  ### corresponding y values, with or without replacement.
  ### Return a vector of random y values the same length as y
  ### You can assume that the xs are sorted
  newy=numeric()
  for (i in 1:5){
        newy[(10*i-9):(10*i)]=sample(y[(10*i-9):(10*i)], 10, replace=rep)
  }
  
  return(newy)
}


genBootR = function(fit, err, rep){
  ### Sample the errors 
  ### Add the errors to the fit to create a y vector
  ### Return a vector of y values the same length as fit
  newy=fit+sample(err, replace=rep)
  return(newy)
}


#### Part 2 ####
fitModel = function(x, y, degree){
  ### use the lm function to fit a line of a quadratic 
  ### e.g. y ~ x or y ~ x + I(x^2)
  ### y and x are numeric vectors of the same length
  ### Return the coefficients as a vector 
  if (degree ==1){
    out=lm(y~x)
  }
  if (degree == 2) {
    out=lm(y~x+I(x^2))
  }
  coef=coefficients(out)
  return(coef)
}

#### Part 3 ####

oneBoot = function(data){
  ### data are your data (from call to getData)
  ###  err1 are errors from fit of line to data
  ###  err2 are errors from fit of quadratic to data
  ###  generate three bootstrap samples 
  ###  A. use genBootY
  BootY=genBootY(data$x,data$y,rep=TRUE)
  ###  B. use genBootR and errors from linear fit
  out=lm(y~x, data=data)
  fitY=fitted(out)
  res=residuals(out)
  bootR=genBootR(fitY,res,rep=FALSE)
  ###  C. use genBootR and errors from quadratic fit
  out.2=lm(y~x+I(x^2), data=data)
  fitY.2=fitted(out.2)
  res.2=residuals(out.2)
  bootR.2=genBootR(fitY.2,res.2,rep=FALSE)
  
  ### For A, fit a line to data$x and new y's
  A=fitModel(data$x, BootY, degree = 1)
  ### Repeat to fit a quadratic
  A.2=fitModel(data$x, BootY, degree = 2)
  ### For B, fit a line to data$x and the new y's
  B=fitModel(data$x, bootR, degree = 1)
  ### For C, fit a quadratic to data$x and new y's
  C=fitModel(data$x, bootR.2, degree = 2)
  ### Return the coefficients from the 4 fits in a list 
  l=list(A,A.2,B,C)
  return(l)
}

#### Part 4 ####

repBoot = function(data, B = 1000){
  
  ### replicate a call to oneBoot B times
  ### format the return value so that you have a list of
  ### length 4, one for each set of coefficients
  ### each element will contain a data frame with B rows
  ### and one or two columns, depending on whether the 
  ### fit is for a line or a quadratic
  ### Return this list
  l=oneBoot(data)
  for (i in (2:B)){
    l=mapply(rbind,oneBoot(data),l)
  }
  return(l)
} 

reBoot=repBoot(data,B=1000)
A.dataframe=reBoot[[1]]
A2.dataframe=reBoot[[2]]
B.dataframe=reBoot[[3]]
C.dataframe=reBoot[[4]]
## Confidence intervals for betas
ci_l1=quantile(sort(A.dataframe[,2]),c(0.025,0.975))
ci_q1=quantile(sort(A2.dataframe[,2]),c(0.025,0.975))
ci_l2=quantile(sort(B.dataframe[,2]),c(0.025,0.975))
ci_q2=quantile(sort(C.dataframe[,2]),c(0.025,0.975))

ci_l1
ci_q1
ci_l2
ci_q2

#### Part5 #####
bootPlot = function(data, coeff, trueCoeff){
  ### data is the original data set
  ### coeff is a data frame from repBoot
  ### trueCoeff contains the tru coefficients that generated
  ### data
  
  ### Make a scatter plot of data
  plot(data$y~data$x, col="red", main="plot of coefficients", xlab="x",ylab="y")
  ### Use mapply to add lines or curves for each row in coeff
  if (length(coeff[1,])==2){
    mapply(abline, coeff[,1],coeff[,2], col=rgb(1,0.2,0.8,alpha=0.5))
  }
  if (length(coeff[1,])==3){
    mapply(function(a,b,c){curve(a+b*x+c*(x^2),add=TRUE,col=rgb(1,0.2,0.8,alpha=0.4))}, coeff[,1],coeff[,2],coeff[,3])
  }
  ### Use transparency
  ### Use trueCoeff to add line or curve - make it stand out
  curve(trueCoeff[1]+trueCoeff[2]*x+trueCoeff[3]*(x^2),col="Blue", add=TRUE, lwd=5)
}

### Run your simulation
par(mfrow=c(2,2))
bootPlot(data,A.dataframe,trueCoeff)
bootPlot(data,A2.dataframe,trueCoeff)
bootPlot(data,B.dataframe,trueCoeff)
bootPlot(data,C.dataframe,trueCoeff)

#### Comment:
# When is the variability smallest? 
# Ans: when we fit the quadartic model useing the 2nd method-sampling from the residual

# Is there a problem with bias when the model being fitted is wrong? 
# Yes. When we fit linear models, the true line is very off from the simulated lines
# especially the second mehtod.

# Is there a problem with basing the bootstrap on the data, i.e. 
# are the data close to the truth? 
# Yes, there is a problem. The data is not close to the truth.
# If we fit the data quadratically, 
# (Intercept)           x      I(x^2) 
# 6.778566   -2.834267    1.463855 
# the coefficients is quite different from the true coefficients=c(0,1,1)

# Are any problems you find worse for one method than the other?
# I think the second mehtod-sampling from the residual is better since the variance
# of the simulated lines is smaller for either linear or quadratic models.

#### PART 6.####
### Generate data
library(lattice)
library(Matrix)
set.seed(1)
W = rnorm(100,1:100/5)

a1=1
a2=2
b=0.3
c=4
trueBeta=c(a1,a2,b,c)
y01=0
y02=0
k=matrix(c(1,0.5,0.5,2),2,2)
# real G
G=as.matrix(bdiag(replicate(50, k, simplify = FALSE)))
#### Generate correlated errors
z=rnorm(100)
R=chol(G)
eps=t(z) %*% R

# generate Y by pairs
Y=numeric()
Y[1]=a1+b*y01+c*W[1]+eps[1]
Y[2]=a2+b*y02+c*W[2]+eps[2]
for(i in seq(3,99,by=2)) {
  Y[c(i,i+1)] = c(a1,a2) + b*c(Y[i-2],Y[i-1]) + c*c(W[i],W[i+1]) + c(eps[i],eps[i+1])
}

# design matrix
X=cbind(rep(c(1,0),50), rep(c(0,1),50) , c(y01,y02,Y[1:(100-2)]), W) 

### OLS
beta_OLS=solve(t(X)%*%X)%*%t(X)%*%Y
# residuals from OLS, format them by pairs. Each row is one pair of e.
e_OLS=matrix(Y-X%*%beta_OLS, 50, 2, byrow=TRUE)

### One-step FGLS
# K hat PAGE164 on Freedman
# the following return a 4 by 50 matrix. 
eachrow=sapply(1:50, function(i) as.matrix(e_OLS[i,]) %*% e_OLS[i,])
empi.cov=rowMeans(eachrow)
k.hat=matrix(empi.cov,2,2)
# estimated G
G.hat=as.matrix(bdiag(replicate(50, k.hat, simplify = FALSE)))
beta_FGLS_1=solve(t(X) %*% solve(G.hat) %*% X) %*% t(X) %*% solve(G.hat) %*% Y
c_FGLS_1=beta_FGLS_1[4]

### Bootstrap one-step FGLS
BootFGLS = function(beta_hat, res, W, n, y01, y02){
  # Sample eps from residuals
  # sample the pairs of residuals = sample rows 
  row.index=sample(1:nrow(res),replace=TRUE)
  eps.pair=res[row.index,]
  # combine the paris of eps into one column
  eps=NULL
  for (i in 1:nrow(eps.pair)) {
    eps=c(eps,eps.pair[i,])  
  }
  
  Y=numeric()
  Y[1]=beta_hat[1]+beta_hat[3]*y01+beta_hat[4]*W[1]+eps[1]
  Y[2]=beta_hat[2]+beta_hat[3]*y02+beta_hat[4]*W[2]+eps[2]
  for(i in seq(3,n-1,by=2)) {
    Y[c(i,i+1)] = c(a1,a2) + b*c(Y[i-2],Y[i-1]) + c*c(W[i],W[i+1]) + c(eps[i],eps[i+1])
  }
  
  # design matrix
  X=cbind(rep(c(1,0),n/2), rep(c(0,1),n/2) , c(y01,y02,Y[1:(n-2)]), W) 
  
  ### OLS
  beta_OLS=solve(t(X)%*%X)%*%t(X)%*%Y
  # residuals from OLS, format them by pairs. Each row is one pair of e.
  e_OLS=matrix(Y-X%*%beta_OLS, 50, 2, byrow=TRUE)
  
  ### One-step FGLS
  # K hat PAGE164 on Freedman
  # the following return a 4 by 50 matrix. 
  eachrow=sapply(1:50, function(i) as.matrix(e_OLS[i,]) %*% e_OLS[i,])
  empi.cov=rowMeans(eachrow)
  k.hat=matrix(empi.cov,2,2)
  # estimated G
  G.hat=as.matrix(bdiag(replicate(50, k.hat, simplify = FALSE)))
  beta_FGLS_1=solve(t(X) %*% solve(G.hat) %*% X) %*% t(X) %*% solve(G.hat) %*% Y
  return(beta_FGLS_1)
}

# result is a 4 by 1000 matrix. Each column is a replicate. Each row is an estimate
result=replicate(1000,BootFGLS(beta_FGLS_1, e_OLS, W, n=100, y01=0, y02=0),simplify="matrix")
# for estimates of c, it is the 4th row of the result matrix
c_boot=result[4,]

### Bootstrap 95% CI for c
ci_c=quantile(sort(c_boot),c(0.025,0.975))
ci_c
#> ci_c
#   2.5%    97.5% 
#  3.795070 4.209436 
boot_bias=c_boot-c_FGLS_1
par(mfrow=c(1,1))
hist(boot_bias)
abline(v=mean(boot_bias), col="red", lwd=2)
legend("topright",col="red","mean of boot bias", lty=1,cex=0.5)
mean(boot_bias)
# [1] 0.0802318
c_FGLS_1-c
# [1] -0.07456767
## Comment: I think the boostrap is working really well. The bootstrap bias is really
## close to the bias of FGLS estimate, except the signs of them are opposite.