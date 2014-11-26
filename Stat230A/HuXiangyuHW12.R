##### HW12 Name: Xiangyu Hu
#### Make data ####

## data for part 1
makedata=function(n=100, p=20, wh=15){
  X=matrix(rnorm(n*p),n,p)
  # For Part 2, you'll put in new code here to create X differently, but 
  # leave the rest of the function alone.
  exps=seq(-1, -2.5, length=wh)
  beta=rep(0,p)
  beta[1:wh]=exp(exps)
  Y=.5+X%*%beta+rnorm(n)
  return(data.frame(Y,X))   
}


## data for part 2
# generates correlated explanatory variables
makedata2 <- function(n=100, p=20, wh=15) {
  X = matrix(rnorm(n*p), n, p)                        
  cors = c(.1,.3,.5,.7,.9)     
  
  # groups the 15 vectors into 5 groups of 3 at random
  Xg <- split( sample.int(15,replace=FALSE) , 1:5 )
  tmp <- do.call( "cbind" , 
                  mapply( FUN = function(wh.x,cor) {
                    x <- X[, wh.x,drop=FALSE]
                    x1 <- x[,1]
                    x2 <- cor*x1 + sqrt(1-cor^2)*x[,2]
                    k = cor*sqrt((1-cor)/(1+cor))
                    x3 <- cor*x1 + k*x[,2] + sqrt(1-cor^2-k^2)*x[,3] 
                    xg = cbind( x1 , x2 , x3 )
                    return(xg)
                  } , 
                  Xg , cors , SIMPLIFY = FALSE ) )   
  
  # randomizes the order of the 20 vectors before assigning the coefficients
  X <- cbind( tmp, X[, (wh+1):p])[, sample.int(p)]
  exps = seq(-1,-2.5, length=wh)
  beta = rep(0, p)
  beta[1:15] = exp(exps)
  Y = .5 + X %*% beta + rnorm(n)
  return( data.frame(Y, X) ) 
}

## data for part 3
makedata3 <- function(n=100, p=20, wh=15) {
  library(Matrix)
  z = matrix(rnorm(n*5), n, 5)                           
  # generate the index for the corr matrix
  pair=combn(1:5,2)
  # run through for each column
  corr=matrix(,5,5)
  for (i in 1:10){
    corr[pair[1,i],pair[2,i]]=1-diff(pair[,i])/4
  }
  diag(corr)=1
  corr=forceSymmetric(corr)
  R=chol(corr)
  x1.5=z %*% R
  
  x6.10=x1.5^2
  
  # interactions
  x11.20=NULL
  for (i in 1:10){
    x=x1.5[,pair[1,i]] * x1.5[,pair[2,i]]
    x11.20=cbind(x11.20,x)
  }
  
  
  X=as.matrix(cbind(as.matrix(x1.5),as.matrix(x6.10),as.matrix(x11.20)))
  
  exps=seq(-1, -2.5, length=wh)
  beta=rep(0,p)
  beta[1:wh]=exp(exps)
  Y=.5+X%*%beta+rnorm(n)
  return(data.frame(Y,X)) 
}


#### Regr TREE ####
## DONE
### FUNCTION ###
CV10FoldFit=function(data,best){
  require(tree)
  nPerFold=10
  mixUpRows = sample(nrow(data))
  cvfity=numeric()
  for (i in 1:10){
    test=data[mixUpRows[(i*nPerFold-(nPerFold-1)):(i*nPerFold)],]
    train=data[-mixUpRows[(i*nPerFold-(nPerFold-1)):(i*nPerFold)],]
    modtree =tree(Y ~ ., train, control=tree.control(nobs=nrow(train), mindev=0, minsize=2))
    # prunes the perfect tree to a given size
    ptree = prune.tree(modtree, best=best)
    cvfity[mixUpRows[(i*nPerFold-(nPerFold-1)):(i*nPerFold)]] = predict(ptree, as.data.frame(test[,-1]))
  }
  return(cvfity)
}

chooseBest=function(data){
  RSS.tree=numeric()
  y=data[,1]
  for (i in 2:20){
    fittedtree=CV10FoldFit(data,best=i)
    RSS.tree[i-1]=sum((fittedtree-y)^2)
  }
  return(min(RSS.tree))
}




#### CV RSS model selection #####
#### Functions ####
##DONE
# computes criterion 
getCriterion <- function( res , p , s2 = NULL , 
                          method = c("cp","aic","bic","all") ) {
  
  method = match.arg( method , c("cp","aic","bic","all") )
  if( method == "cp" & is.null(s2) ) {
    stop( "'s2' must be given for method 'cp'" )
  }
  
  n = length(res)
  RSS = sum(res^2)
  stat = switch( method , 
                 "cp" = RSS / n + 2 * p / n * s2 , 
                 "aic" = log(RSS) + 2 * p / n , 
                 "bic" = log(RSS) + p * log(n) / n ,
                 "all" = c( "cp" = RSS/n + 2*p/n *s2 , "aic" = log(RSS) + 2*p/n , 
                            "bic" = log(RSS) + p*log(n)/n ) )
  return( stat )
}    


# computes K-fold CV RSS
cvFUN <- function(x=NULL, y, K) {
  just.int = FALSE
  if ( is.null(x) ) {
    just.int = TRUE 
  } else {
    x <- as.matrix(x)
  }
  
  y <- as.matrix(y)   
  if ( nrow(y)%%K != 0 ) {
    stop( "The number of rows of 'y' is not a multiple of 'K'. 
          This functionality is not yet available." )  
  }       
  
  data.split <- split(sample.int(nrow(y),replace=FALSE), 1:K)  
  
  cvrss <- sapply( 1:length(data.split) , 
                   FUN = function( i ) {
                     wh.test <- data.split[[i]]
                     x.test <- x[wh.test, , drop=FALSE]
                     y.test <- y[wh.test, , drop=FALSE]
                     y.train <- y[-wh.test, , drop=FALSE]
                     x.train <- x[-wh.test, , drop=FALSE]
                     
                     if(!just.int) {
                       coef.train <- coef(lm( y.train ~ x.train ))
                       fitted.test <- cbind(1,x.test) %*% coef.train
                     }  else {
                       coef.train <- coef(lm( y.train ~ 1 ))
                       fitted.test <- rep(coef.train,length(wh.test))
                     }             
                     
                     rss = sum((y.test-fitted.test)^2 )
                     return(rss)
                   } , 
                   simplify = TRUE ) 
  
  return( sum(cvrss) )                       
  }


# performs backward selection using the given criterion 
backMS <- function(x, y, method=c("cp", "aic", "bic", "cv"), K=10) {
  
  method = match.arg( method , c("cp", "aic", "bic", "cv") )
  
  x <- as.matrix(x)
  y <- as.matrix(y)
  p <- ncol(x)
  n <- nrow(x)
  df <- n - (p + 1)   
  
  # backward model selection starts with the full model
  res.full <- resid(lm(y ~ x))
  s2 <- sum(res.full^2)/df 
  
  vec <- rep(NA, p)
  names(vec) <- 1:p
  if (method != "cv") {
    vec[as.character(p)] <- getCriterion(res.full, p+1, s2, method)
  } else {
    vec[as.character(p)] <- cvFUN(x, y, K)
  }
  
  # for each step, choose the submodel with the smallest criterion
  dropped <- NULL
  iter <- 1
  while( iter < p ) { 
    newp <- p - iter
    current <- NULL
    for (vname in setdiff(colnames(x), dropped) ) { 
      cindex <- which(colnames(x) %in% c(dropped, vname))    
      newx <- x[, -cindex, drop=FALSE]
      fit <- lm(y ~ newx)     
      newres <- resid(fit) 
      news2 <- sum(newres^2) / (n - (newp + 1) )
      if (method != "cv") {
        val <- getCriterion(newres, newp + 1, news2, method)
      } else {
        val <- cvFUN(newx, y, K)
      }
      
      current <- c(current, val)
    }
    names(current) <- setdiff(colnames(x), dropped)
    
    dropped <- c(dropped, names(which.min(current)))
    
    iter <- iter + 1  
    vec[as.character(newp)] <- min(current)                    
  }
  
  return( list(vec, dropped))    
}  



#### Simulation ####
## run each method 100 times, and make box plot side by side

#### Function #####
oneRep=function(method=c("cv","ridge","lasso","tree"),wh.data=c("1","2","3")){
  method=match.arg(method,c("cv","ridge","lasso","tree"))
  
  wh.data <- as.character(wh.data)
  wh.data <- match.arg( wh.data , c("1","2","3") )
  gendata <- switch( wh.data , "1" = get("makedata") , "2" = get("makedata2"),"3" = get("makedata3") )
  data <- gendata(n=100,p=20,wh=15)
  colnames( data ) <- c( "Y" , letters[1:20] )
  
  x <- as.matrix(data[,-1,drop=FALSE])
  y <- as.matrix(data[,1,drop=FALSE])   
  
  #cvrss---done
  if (method == "cv"){
    cv=backMS(x,y,method="cv")
    RSS.cv=min(cv[[1]])
    return(RSS.cv)
  }
  
  #ridge---done
  if (method=="ridge"){
    require(glmnet)  
    mod.ridge = cv.glmnet(x, y, family="gaussian",alpha=0,standardize=FALSE)
    min.mse.ridge=min(mod.ridge$cvm)
    # mse = rss/n, n=100
    RSS.ridge=min.mse.ridge*100
    return(RSS.ridge)
  }
  
  
  #lasso----done
  if (method=="lasso"){
    require(glmnet)
    mod.lasso = cv.glmnet(x, y, family="gaussian",alpha=1,standardize=FALSE)
    min.mse.lasso=min(mod.lasso$cvm) # minimum MSE
    # mse = rss/n, n=100
    RSS.lasso=min.mse.lasso*100
    return(RSS.lasso)
  }
  
  
  #regr. tree
  if (method=="tree"){
    RSS.tree=chooseBest(data)
    return(RSS.tree)
  }
  
  
  
}


## DONE
getResults=function(method=c("cv","ridge","lasso","tree"),wh.data=c("1","2","3"),nrep){
  out=lapply(1:nrep,function(i){return(oneRep(method,wh.data))})
  val=sapply(out,"[[",1)
  return(val)
}
##DONE
getFourMethods=function(method,wh.data,nrep){
  if (method == "cv"){
    RSS.cv=getResults(method="cv",wh.data,nrep)
    return(RSS.cv)
  }
  
  else if (method=="ridge"){
    RSS.ridge=getResults(method="ridge",wh.data,nrep)
    return(RSS.ridge)
  }
  
  
  else if (method=="lasso"){
    RSS.lasso=getResults(method="lasso",wh.data,nrep)
    return(RSS.lasso)
  }
  
  else if (method=="tree"){
    RSS.tree=getResults(method="tree",wh.data,nrep)
    return(RSS.tree)
  }
  
}

#### RUN ####
# DONE
nrep=100
## part 1
RSS.cv.1=getFourMethods("cv","1",nrep)
RSS.ridge.1=getFourMethods("ridge","1",nrep)
RSS.lasso.1=getFourMethods("lasso","1",nrep)
RSS.tree.1=getFourMethods("tree","1",nrep)

## part 2
RSS.cv.2=getFourMethods("cv","2",nrep)
RSS.ridge.2=getFourMethods("ridge","2",nrep)
RSS.lasso.2=getFourMethods("lasso","2",nrep)
RSS.tree.2=getFourMethods("tree","2",nrep)

## part 3
RSS.cv.3=getFourMethods("cv","3",nrep)
RSS.ridge.3=getFourMethods("ridge","3",nrep)
RSS.lasso.3=getFourMethods("lasso","3",nrep)
RSS.tree.3=getFourMethods("tree","3",nrep)

#make the boxplot

rss1=data.frame(RSS.cv.1,RSS.ridge.1,RSS.lasso.1,RSS.tree.1)
rss2=data.frame(RSS.cv.2,RSS.ridge.2,RSS.lasso.2,RSS.tree.2)
rss3=data.frame(RSS.cv.3,RSS.ridge.3,RSS.lasso.3,RSS.tree.3)

pdf("HuXiangyuHW12_Boxplot.pdf")  
par(mfrow=c(3,1))

boxplot(rss1,main="rss for four methods, part1 data",names=names(rss1))
boxplot(rss2,main="rss for four methods, part2 data",names=names(rss2))
boxplot(rss3,main="rss for four methods, part3 data",names=names(rss3))

dev.off()





