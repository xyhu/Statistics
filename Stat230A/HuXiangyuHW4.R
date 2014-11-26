### HW 4.  GLS and correlated errors.
### Part 2.  (Part 1 is the problems from the book.)
### 1) Generate correlated errors.

# First you write the code for making the matrix G.
# Use multiple lines if that seems easier.
# Then get the cholesky decomposition using the function chol().
# (a)
# n=100, r=0.05
G=matrix(.05,100,100) + diag(100)*.95
R=chol(G)

# The next line makes everyone start at the same seed to get the same 
# random numbers.  For fun you may want to comment the line out to see 
# what happens for different simulations.

set.seed(12345)

# The following line will generate uncorrelated random errors.

z = matrix(rnorm(100000),100,1000)

# Using a loop may not be the fastest way to do this (or maybe it is), but 
# I think it is the easiest to understand and my goal is to make this 
# understandable.  It runs plenty fast in any case...
# (b) 1000 replicates, each column is a replicate
eps=matrix(0,100,1000)
for(i in 1:1000){
  eps[,i] = z[,i] %*% R
}

# (c) 
# Calculate S_n, which is the column total for espsilon matrix
S_n=apply(eps,2,sum)
# Calculate empirical values of sigma squared for each replicate
# Calculate empirical values of correlation
sig_sqr=numeric(1000)
r=numeric(1000)
for (i in 1:1000){
  cov_hat=eps[,i] %*% t(eps[,i])
  sig_sqr[i]=mean(diag(cov_hat))
  r[i]=mean(cov_hat[lower.tri(cov_hat,diag=FALSE)]/sig_sqr[i])
}
head(r)
head(sig_sqr)
#> mean(sig_sqr)
#[1] 1.001229
#> mean(r)
#[1] 0.04524103

# variance of S_n
varS_n=var(S_n)
# True variance of S_n in CH4 Disc #17a, n=100, r=0.05, sigmasqr=1
TrueVarS_n=100*1+100*99*1*0.05

# Print out the two variance, and compare
varS_n
TrueVarS_n
#> varS_n
#[1] 603.1054
#> TrueVarS_n
#[1] 595

# Comment:By running through the codes above multiple times, 
# varS_n is really close to TrueVarS_n

### 2. OLS

# (a) Generate X

X = matrix(rnorm(100000),100,1000)

# That gets us past all the random number generation you'll need, I just
# wanted to make sure everyone would do this part in the same order
# so that everyone would get the same results.

# Now construct Y according to the model Y = Xb + eps
# where b=1 and Y will be a 100x1000 matrix, one column corresponding to
# each replication.  Note that when the HW refers to beta I'm talking about
# the coefficient b here.  Don't include an intercept term when you generate
# the data but do include one when you fit the model.
Y=X+eps
# Now you're on your own for the rest.  Don't use any fancy functions 
# (unless you want to check your work), I'd like you to do all this based 
# on matrix algebra for now.
# (b) Do OLS, estimating beta 1000 times
# Fit each column of X to each column of Y to get beta_hat
beta_hat=numeric(1000)
for (i in 1:1000) {
  beta_hat[i]=solve(t(X[,i]) %*% X[,i]) %*% t(X[,i]) %*% Y[,i]
}

# (c) Histogram of beta_hats, a vertical line for true beta=1
hist(beta_hat, main="Histogram of beta estimates-OLS", xlab="beta estimates-OLS")
abline(v=1,col="red",lwd=5)
# Comment: I think OLS does a good job of estimating beta. Based on
# the histogram, the majority of beta_hats are around 1, which is 
# the true beta.

### 3. One Step GLS
# (a) do one step GLS, estimate beta 1000 times, 
# and make the same histogram as you did for OLS. Comment briefly.

# do calculation col by col (by replicates)

beta_GLS_1=numeric(1000)
cor_GLS_1=numeric(1000)
v_hat=numeric(1000)
for (i in 1:1000) {
  # First, calculate residual from OLS
  e=Y[,i]-X[,i]*beta_hat[i]
  # To estimate cov, e %*% t(e)
  cov=e %*% t(e)
  v_hat[i]=mean(diag(cov))
  cor_GLS_1[i]=mean(cov[lower.tri(cov,diag=FALSE)]/v_hat[i])
  # G_hat matrix: diagnal is v_hat, other element is cor_GLS_1
  G_hat=matrix(cor_GLS_1[i],100,100)+diag(v_hat[i]-cor_GLS_1[i],100,100)
  beta_GLS_1[i]=solve( t(X[,i]) %*% solve(G_hat) %*% X[,i] ) %*% t(X[,i]) %*% solve(G_hat) %*% Y[,i]
    
}

# sigma
sigma_hat=sqrt(v_hat)

hist(beta_GLS_1, main="Histogram of beta estimates-one step GLS", xlab="beta estimates-GLS")
abline(v=1,col="red",lwd=5)

# Comment: Based on the histogram, one step GLS beta estimates is
# also good.

#(b)  true r=0.05
hist(cor_GLS_1, main="Histogram of r hat-one step GLS", xlab="r hat-one step GLS")
abline(v=0.05,col="red",lwd=5)
## Comment: The estimate looks good, the majority of them are clustered around the true value
#(c)  true sigma=1
hist(sigma_hat, main="Histogram of sigma hat-one step GLS", xlab="sigma hat-one step GLS")
abline(v=01,col="red",lwd=5)
## Comment: The estimate looks good, the majority of them are clustered around the true value

### 4. Five Step GLS

## Step 2
beta_GLS_2=numeric(1000)
cor_GLS_2=numeric(1000)
v_hat2=numeric(1000)
for (i in 1:1000) {
  # First, calculate residual from OLS
  e=Y[,i]-X[,i]*beta_GLS_1[i]
  # To estimate cov, e %*% t(e)
  cov=e %*% t(e)
  v_hat2[i]=mean(diag(cov))
  cor_GLS_2[i]=mean(cov[lower.tri(cov,diag=FALSE)]/v_hat2[i])
  # G_hat matrix: diagnal is v_hat, other element is cor_GLS_1
  G_hat=matrix(cor_GLS_2[i],100,100)+diag(v_hat2[i]-cor_GLS_2[i],100,100)
  beta_GLS_2[i]=solve( t(X[,i]) %*% solve(G_hat) %*% X[,i] ) %*% t(X[,i]) %*% solve(G_hat) %*% Y[,i]
  
}

## Step 3
beta_GLS_3=numeric(1000)
cor_GLS_3=numeric(1000)
v_hat3=numeric(1000)
for (i in 1:1000) {
  # First, calculate residual from OLS
  e=Y[,i]-X[,i]*beta_GLS_2[i]
  # To estimate cov, e %*% t(e)
  cov=e %*% t(e)
  v_hat3[i]=mean(diag(cov))
  cor_GLS_3[i]=mean(cov[lower.tri(cov,diag=FALSE)]/v_hat3[i])
  # G_hat matrix: diagnal is v_hat, other element is cor_GLS_1
  G_hat=matrix(cor_GLS_3[i],100,100)+diag(v_hat3[i]-cor_GLS_3[i],100,100)
  beta_GLS_3[i]=solve( t(X[,i]) %*% solve(G_hat) %*% X[,i] ) %*% t(X[,i]) %*% solve(G_hat) %*% Y[,i]
  
}

## Step 4
beta_GLS_4=numeric(1000)
cor_GLS_4=numeric(1000)
v_hat4=numeric(1000)
for (i in 1:1000) {
  # First, calculate residual from OLS
  e=Y[,i]-X[,i]*beta_GLS_3[i]
  # To estimate cov, e %*% t(e)
  cov=e %*% t(e)
  v_hat4[i]=mean(diag(cov))
  cor_GLS_4[i]=mean(cov[lower.tri(cov,diag=FALSE)]/v_hat4[i])
  # G_hat matrix: diagnal is v_hat, other element is cor_GLS_1
  G_hat=matrix(cor_GLS_4[i],100,100)+diag(v_hat4[i]-cor_GLS_4[i],100,100)
  beta_GLS_4[i]=solve( t(X[,i]) %*% solve(G_hat) %*% X[,i] ) %*% t(X[,i]) %*% solve(G_hat) %*% Y[,i]
  
}

## Step 5
beta_GLS_5=numeric(1000)
cor_GLS_5=numeric(1000)
v_hat5=numeric(1000)
for (i in 1:1000) {
  # First, calculate residual from OLS
  e=Y[,i]-X[,i]*beta_GLS_4[i]
  # To estimate cov, e %*% t(e)
  cov=e %*% t(e)
  v_hat5[i]=mean(diag(cov))
  cor_GLS_5[i]=mean(cov[lower.tri(cov,diag=FALSE)]/v_hat5[i])
  # G_hat matrix: diagnal is v_hat, other element is cor_GLS_1
  G_hat=matrix(cor_GLS_5[i],100,100)+diag(v_hat5[i]-cor_GLS_5[i],100,100)
  beta_GLS_5[i]=solve( t(X[,i]) %*% solve(G_hat) %*% X[,i] ) %*% t(X[,i]) %*% solve(G_hat) %*% Y[,i]
  
}

# Boxplot for beta estimates of all five steps
beta_GLS=data.frame(beta_GLS_1,beta_GLS_2,beta_GLS_3,beta_GLS_4,beta_GLS_5)
boxplot(beta_GLS)
abline(h=1,col="red")


# histogram of beta estimates of the fifth step
hist(beta_GLS_5, main="Histogram of beta estimates-five step GLS", xlab="beta estimates-GLS")
abline(v=1,col="red",lwd=5)
# Comment: Based on the histogram, one step GLS beta estimates is
# also good.

# Calculate the r and sigma for the last step
cor_GLS=numeric(1000)
v=numeric(1000)
for (i in 1:1000) {
  # First, calculate residual from OLS
  e=Y[,i]-X[,i]*beta_GLS_5[i]
  # To estimate cov, e %*% t(e)
  cov=e %*% t(e)
  v[i]=mean(diag(cov))
  cor_GLS[i]=mean(cov[lower.tri(cov,diag=FALSE)]/v[i])
}
sigma_GLS=sqrt(v)
#true r=0.05
hist(cor_GLS, main="Histogram of r hat-five step GLS", xlab="r hat-five step GLS")
abline(v=0.05,col="red",lwd=5)
## Comment: The estimate looks good, the majority of them are clustered around the true value
#true sigma=1
hist(sigma_GLS, main="Histogram of sigma hat-five step GLS", xlab="sigma hat-five step GLS")
abline(v=01,col="red",lwd=5)
## Comment: The estimate looks good, the majority of them are clustered around the true value
