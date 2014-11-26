#### HW9 Name: Xiangyu Hu
#### Lab 13 ####
n=1766
corr_matrix=read.table("rindcor.txt")
tcorr=t(corr_matrix)
# create a complete corr matrix, filling out the zeroes for the upper triangle
corr_matrix[upper.tri(corr_matrix)]=tcorr[upper.tri(tcorr)]
dimnames(corr_matrix) = list( 
  c("OCC", "RACE", "NOSIB","FARM","REGIN","ADOLF","REL","YCIG","FEC","ED","AGE"), # row names 
  c("OCC", "RACE", "NOSIB","FARM","REGIN","ADOLF","REL","YCIG","FEC","ED","AGE")) # column names 

### First Equation: ED = ...
x1=c("AGE", "RACE", "NOSIB","FARM","REGIN","ADOLF","REL","YCIG","OCC")
z1=c("FEC", "RACE", "NOSIB","FARM","REGIN","ADOLF","REL","YCIG","OCC")
y1=c("ED")
## THe following matrices originally need to multiplied by n, but all of them canceled
## out at the end when calculating beta_IVLS
tzz1=as.matrix(n * corr_matrix[z1,z1])
tzx1=as.matrix(n * corr_matrix[z1,x1])
tzy1=as.matrix(n * corr_matrix[z1,y1])
beta_IVLS1=solve(t(tzx1) %*% solve(tzz1) %*% tzx1) %*% t(tzx1) %*% solve(tzz1) %*% tzy1
beta_IVLS1
# Bonus Questions:
# 1. The coefficients for age here is 0.147, the one on the table is 0.130. It is a
# little different, but not very big. I think it is due to the rounding error of 
# correlation. The paper got the number by using the real data, whereas we calculate
# it from correlation matrix.
# 2. SE
txx1=as.matrix(n * corr_matrix[x1,x1])
tyx1=as.matrix(n * corr_matrix[y1,x1])
SigSqrHat1=as.numeric((n+t(beta_IVLS1) %*% txx1 %*% beta_IVLS1 - 2 %*% tyx1 %*% beta_IVLS1)/(n-9))
cov_beta_IVLS1=SigSqrHat1 * solve(t(tzx1) %*% solve(tzz1) %*% tzx1)
se1 = sqrt(diag(cov_beta_IVLS1))
se1

### Second Equation: AGE = ...
x2=c("ED", "RACE", "NOSIB","FARM","REGIN","ADOLF","REL","YCIG","FEC")
z2=c("FEC", "RACE", "NOSIB","FARM","REGIN","ADOLF","REL","YCIG","OCC")
y2=c("AGE")
## THe following matrices originally need to multiplied by n, but all of them canceled
## out at the end when calculating beta_IVLS
tzz2=as.matrix(n * corr_matrix[z2,z2])
tzx2=as.matrix(n * corr_matrix[z2,x2])
tzy2=as.matrix(n * corr_matrix[z2,y2])
beta_IVLS2=solve(t(tzx2) %*% solve(tzz2) %*% tzx2) %*% t(tzx2) %*% solve(tzz2) %*% tzy2
beta_IVLS2
# Bonus Questions:
# 1. The coefficients for education here is 0.485, the one on the table is 0.429. It is a
# little different, but not very big. I think it is due to the rounding error of 
# correlation. The paper got the number by using the real data, whereas we calculate
# it from correlation matrix.
# 2. SE
txx2=as.matrix(n * corr_matrix[x2,x2])
tyx2=as.matrix(n * corr_matrix[y2,x2])
SigSqrHat2=as.numeric((n+t(beta_IVLS2) %*% txx2 %*% beta_IVLS2 - 2 %*% tyx2 %*% beta_IVLS2)/(n-9))
cov_beta_IVLS2=SigSqrHat2 * solve(t(tzx2) %*% solve(tzz2) %*% tzx2)
se2 = sqrt(diag(cov_beta_IVLS2))
se2

#### Simulation ####
# Let q = 1, β = 1, and do the simulation 4 times total with these conditions: 
# n = 10 or n = 1000, and for each of those cases, with C = .1 or C = 0.5. 
# Let δi,εi have variance 1 and cov(δi,εi) is 0.3. As stated in the text description,
# p = 1, and no intercept is needed. Do a simulation to get 1000 repetitions 
# of (βˆOLS,βˆIV LS). 
# Compare the MSEs: which one performs best for each of the 4 simulations? 
# You need not compare methods for estimating var(εi). 
# Discuss briefly in the context of technical issue ii) on page 197.
beta=1
n1=10
n2=1000
c1=0.1
c2=0.5
simulation=function(n,c,truebeta,corr){
  delta=rnorm(n,0,1)
  gamma=rnorm(n,0,1)
  # generate correlated epsilon
  eps=corr*delta+sqrt(1-corr^2)*gamma
  z=rnorm(n,0,1)
  x=c*z + delta
  y=truebeta*x + eps
  # OLS-no intercept
  beta_OLS=lm(y~x -1)$coefficients
  # IVLS
  tzz=t(z) %*% z
  tzx=t(z) %*% x
  tzy=t(z) %*% y
  beta_IVLS=solve(t(tzx) %*% solve(tzz) %*% tzx) %*% t(tzx) %*% solve(tzz) %*% tzy
  beta_hat=c("beta_OLS"=beta_OLS,"beta_IVLS"=beta_IVLS)
  return (beta_hat) 
}

mat1=replicate(1000,simulation(n1,c1,beta,0.3))
mat2=replicate(1000,simulation(n1,c2,beta,0.3))
mat3=replicate(1000,simulation(n2,c1,beta,0.3))
mat4=replicate(1000,simulation(n2,c2,beta,0.3))

MSE_OLS_est1=mean((mat1[1,]-beta)^2)
MSE_IVLS_est1=mean((mat1[2,]-beta)^2)
MSE_OLS_est1
# [1] 0.1934601
MSE_IVLS_est1
# [1] 185.3819
# When n=10, c=0.1, the estimated MSE is smaller using OLS. Thus, OLS performs better.

MSE_OLS_est2=mean((mat2[1,]-beta)^2)
MSE_IVLS_est2=mean((mat2[2,]-beta)^2)
MSE_OLS_est2
# [1] 0.1339263
MSE_IVLS_est2
# [1] 119.8923
# When n=10, c=0.5, the estimated MSE is still smaller using OLS. Thus, OLS performs better.
# Therefore for smaller

MSE_OLS_est3=mean((mat3[1,]-beta)^2)
MSE_IVLS_est3=mean((mat3[2,]-beta)^2)
MSE_OLS_est3
# [1] 0.09004042
MSE_IVLS_est3
# [1] 0.6339384
# When n=1000, c=0.1, the estimated MSE is still smaller using OLS. Thus, OLS performs better.
# However, the difference between the two estimated MSEs are much smaller than small
# sample size


MSE_OLS_est4=mean((mat4[1,]-beta)^2)
MSE_IVLS_est4=mean((mat4[2,]-beta)^2)
MSE_OLS_est4
# [1] 0.05836724
MSE_IVLS_est4
# [1] 0.004006634
# When n=1000, c=0.5, the estimated MSE is smaller using IVLS. Thus, IVLS performs better.

