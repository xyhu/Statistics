#### HW 10 Name: Xiangyu Hu ####
#### Preparation ####
d=load("HW10.rda")
data=get(d[2])
set.seed(123)

getR2=function(fity,y){
  SStot=sum((y-mean(y))^2)
  SSres=sum((y-fity)^2)
  r2=1-(SSres/SStot)
  return(r2)
}


CV10FoldFit=function(data){
  nPerFold=10
  mixUpRows = sample(nrow(data))
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
#### Part 1 ####
#### 1.(a) OLS fit full model ####
full=lm(Y~.,data=data)
#### 1.(b) compute R2 ####
R2_full=getR2(full$fitted,data$Y)
#### 1.(c) 10 fold CV ####
cvfity_full=CV10FoldFit(data)
R2_fullCV=getR2(cvfity_full,data$Y)

R2_full
# [1] 0.5011678 matches with the one from summary(full)
R2_fullCV
# [1] 0.1567169 is very different from the one from summary(full), some of the CV fit
# is very different from the observed y's, which result in big residuals, and thus
# very big sum of squares of residuals.The low R2 is implying that the model is not
# a good fit, since using the model from 9 fold of the data could not give a good
# fit the testing data(1 fold).

# From summary(full): Multiple R-squared:  0.5012,  Adjusted R-squared:  0.3749 

#### intercept model ####
intercept_model=lm(Y~1,data=data)
## R2_OLS=0, because the fitted values are all the same, which is the intercept est.
## So variance of fitted values = 0.
dat=data$Y
nPerFold=10
mixUpRows = sample(length(data$Y))
cvfity_intercept=numeric()
for (i in 1:10){
  test=dat[mixUpRows[(i*nPerFold-(nPerFold-1)):(i*nPerFold)]]
  train=dat[-mixUpRows[(i*nPerFold-(nPerFold-1)):(i*nPerFold)]]
  fit=lm(train~1)
  coef=fit$coefficients
  x_test=as.matrix(rep(1,10))
  cvfity_intercept[mixUpRows[(i*nPerFold-(nPerFold-1)):(i*nPerFold)]]=x_test %*% coef
}
R2_interceptCV=getR2(cvfity_intercept,data$Y)
# > R2_interceptCV
#[1] -0.02025637


#### Part 2 Backward Selection ####
backward=function(data){
  p=numeric()
  var_rm=character()
  R2_OLS=numeric()
  R2_CV=numeric()
  for (i in 1:(ncol(data)-1)){
    model=lm(Y~.,data=data)
    t_stat=summary(model)$coefficient[,3]
    newdata=data[,which(colnames(data) !=names(which.min(abs(t_stat))))]
    # variable to be removed from the model
    var_rm[i]=names(which.min(t_stat))
    # number of variables in the model(includes the one that is going to be removed
    # and the intercept)
    p[i]=22-i
    # calculate the OLS R2 for the model
    R2_OLS[i]=getR2(model$fitted,data$Y)
    # calculate the CV R2 for the model
    cvfity=CV10FoldFit(data)
    R2_CV[i]=getR2(cvfity,data$Y)
    # assign data as the new data to be used for the next loop
    data=newdata
  }
  results=data.frame("# of para"=p,"variable to be removed"=var_rm,
            "R2_OLS"=R2_OLS,"R2_CV"=R2_CV)
  return(results)
}

backward_selection=backward(data)

#### Part 3. Forward Selection ####
# for later steps where there are already vars included
selectBigR2=function(selectPool,existed,Y){
    X=selectPool
    R2s=apply(X,2,
              function(x){
                dat=data.frame(Y,existed,x)
                m=lm(Y~.,data=dat)
                r2=summary(m)$r.squared
              }
    )
  varToAdd=selectPool[,which(colnames(selectPool) ==names(which.max(R2s)))]
  varName=names(which.max(R2s))
  R2=max(R2s)
  data=data.frame(Y,existed,varToAdd)
  cvfity=CV10FoldFit(data)
  R2_CV=getR2(cvfity,Y)
  result=list("varName"=varName,"varValues"=varToAdd,"R2"=R2,"R2CV"=R2_CV)
  return(result)
}

forward=function(data){
  # Step1: start with the intercept model, which variable should be choose?
  # the design matrix
  x=data[,-1]
  Y=data$Y
  R2s=apply(x,2,
            function(x){
              m=lm(Y~x)
              r2=summary(m)$r.squared
            }
  )
  varToAdd=x[,which(colnames(x) ==names(which.max(R2s)))]
  varName=names(which.max(R2s))
  R2=max(R2s)
  d=data.frame(Y,varToAdd)
  cvfity=CV10FoldFit(d)
  R2_CV=getR2(cvfity,Y)
  # Step2: now the model already has one variable
  existed=varToAdd
  selectPool=x[,which(colnames(x) !=names(which.max(R2s)))]
  
  for (i in (1:18)){
    
      result=selectBigR2(selectPool,existed,Y)
      R2_CV=c(R2_CV,result$R2CV)
      R2=c(R2,result$R2)
      varName=c(varName,result$varName)
      existed=data.frame(existed,result$varValues)
      selectPool=selectPool[,which(colnames(selectPool) !=result$varName)]
  }
  varName=as.character(varName)
  final=cbind(varName,R2,R2_CV)
  return(final)
}

forward_selection=forward(data)

lastRow=c(setdiff(colnames(data[,-1]),forward_selection[,1]),R2_full,R2_fullCV)

forward_selection=rbind(forward_selection,lastRow)
forward_selection=data.frame(forward_selection,stringsAsFactors=FALSE)
## the sequence of models given by backward and forward selection are almost the same,
## this is not always true, since we use different criteron to determine which variable
## to add/delete.
#### Part 4 ####
backward_selection_sort=backward_selection[order(backward_selection[,1]),]
all=cbind(backward_selection_sort,forward_selection)
colnames(all)=c("p","varBack","R2_OLS_back","R2_CV_back","varForward","R2_OLS_forward","R2_CV_forward")

matplot(all[,1],all[,c(3,4,6,7)],type="b",pch=19:22,col=1:4,lty=1:4,xlab="number of parameters",ylab="R2")
abline(v=which.max(all[,3]),col=1,lty=1)
abline(v=which.max(all[,4]),col=2,lty=2)
abline(v=which.max(all[,6]),col=3,lty=3)
abline(v=which.max(all[,7]),col=4,lty=4)
legend("topleft",c("R2_OLS_back","R2_CV_back","R2_OLS_forward","R2_CV_forward"),lty=1:4,col=1:4,cex=0.5)
