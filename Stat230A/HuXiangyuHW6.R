### Name: Xiangyu Hu

#### 1. Write down the log likelihood formula. Plot it as a function of theta
#### log likelihood = n*log(theta) - 2 sum(log(theta + x_i))

loglik=function (theta,data){
  n=nrow(data)
  l=n*log(theta)-2*sum(log(theta+data))
  return (l)
}
data=read.table("mle.dat")
theta_seq <- seq( 1 , 50 , length = 1000 )
plot( theta_seq , sapply(theta_seq,function(l)loglik(l,data)), 
      lwd = 2 , col = "blue" , xlab = expression(theta) , ylab = "log-likelihood" , 
      main = "Lab 10 Log-Likelihood" , cex.main = 2 , cex.axis = 1.5 , type = "l" )

#### 2. Find the MLE by numerical maximization
# Transformation of theta using log, to make sure the positive constraint is satisfied
loglik_tran=function (phi,data){
  theta=exp(phi)
  n=nrow(data)
  l=n*log(theta)-2*sum(log(theta+data))
  return (l)
}
# first derivative of log likelihood with respect to theta
d1_loglik_tran=function(phi, data){
  theta=exp(phi)
  n=nrow(data)
  d1=n/theta - 2* sum(1/(theta+data))
  return (d1)
}
# Second derivative will be used to check whether it is a min or max
d2_loglik_tran=function(phi, data){
  theta=exp(phi)
  n=nrow(data)
  d2= - n*theta^(-2) + 2* sum((theta+data)^(-2))
  return (d2)
}
mle_transformed = optimize(loglik_tran, lower=0.00001, upper=40,data=data,maximum=TRUE)$maximum
mle=exp(mle_transformed)
mle
#[1] 22.50974
d1_loglik_tran(mle_transformed,data)
#[1] 5.296697e-07
d2_loglik_tran(mle_transformed,data)
#[1] -0.03319703
# The first derivative is very close to 0, after I plug in the mle calculated. 
# The second derivative is negative, thus implies that it is maximum.

#### 3. Put a standard error on mle
# Use the third way, which is the observed information way to calculate the variance
d2_loglik=function(theta, data){
  n=nrow(data)
  d2= - n*theta^(-2) + 2* sum((theta+data)^(-2))
  return (d2)
}
variance=-1/d2_loglik(mle,data)
se=sqrt(variance)
se
# [1] 5.488458