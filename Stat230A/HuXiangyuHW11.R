#### Name: Xiangyu Hu
#### Part 1 ####
makedata=function(p=20,wh=15,n){
  X=matrix(rnorm(n*p),n,p)
  # For Part 2, you'll put in new code here to create X differently, but 
  # leave the rest of the function alone.
  exps=seq(-1,-2.5,length=wh)
  beta=rep(0,p)
  beta[1:wh]=exp(exps)
  Y=.5+X%*%beta+rnorm(n)
  return(data.frame(Y,X))
}

data100=makedata(n=100)
data1k=makedata(n=1000)

lmout=lm(Y~.,data=data)
summary(lmout)

#### Part1.1 10 fold CV ####
getR2=function(fity,y){
  SStot=sum((y-mean(y))^2)
  SSres=sum((y-fity)^2)
  r2=1-(SSres/SStot)
  return(r2)
}

CV10FoldFit=function(data,n){
  nPerFold=n/10
  mixUpRows = sample(n)
  cvfity=numeric()
  for (i in 1:10){
    test=data[mixUpRows[(i*nPerFold-(nPerFold-1)):(i*nPerFold)],]
    train=data[-mixUpRows[(i*nPerFold-(nPerFold-1)):(i*nPerFold)],]
    fit=lm(Y~.,data=train)
    coef=fit$coefficients
    x_test=as.matrix(cbind(1,test[,which(colnames(test) !="Y")]))
    cvfity[mixUpRows[(i*nPerFold-(nPerFold-1)):(i*nPerFold)]]=x_test %*% coef
  }
  return(cvfity)
}

backward=function(data,n){
  p=numeric()
  R2_OLS=numeric()
  R2_CV=numeric()
  for (i in 1:(ncol(data)-1)){
    model=lm(Y~.,data=data)
    t_stat=summary(model)$coefficient[,3]
    # leave the variable with the smallest t-value
    newdata=data[,which(colnames(data) !=names(which.min(abs(t_stat))))]
    p[i]=22-i
    # calculate the CV R2 for the model
    cvfity=CV10FoldFit(data,n)
    R2_CV[i]=getR2(cvfity,data$Y)
    # assign data as the new data to be used for the next loop
    data=newdata
  }
  return(R2_CV)
}
CVR2_100=replicate(1000,backward(makedata(n=100),100),simplify="matrix")
CVR2_1k=replicate(1000,backward(data1k,1000),simplify="matrix")




#### Part 1.2 Mallow's Cp ####






#### Part 1.3 AIC ####









#### Part 1.4 BIC ####




