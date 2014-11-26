#### HW 5 Name: Xiangyu Hu
#### Part 1: Lab 9 in the textbook ####

### 1. Compute the path coefficients in figure 6.2, using the method of section 6.1.
# number of states for repression, elite tolerance, and mass tolerance
N_R=50
N_E=26
N_M=36
# variable names: (E)Elite, (R)Repression, (M)Mass
cor_ME=0.52
cor_MR=-0.26
cor_ER=-0.42
# X=(M E), X'X
tXX=matrix(c(N_M,N_M*cor_ME,N_M*cor_ME,N_M),2,2,byrow=TRUE)
# X'R
tXR=matrix(c(N_M*cor_MR,N_M*cor_ER),2,1)
# estimate beta
beta_hat=solve(tXX) %*% tXR
#> beta_hat
#[,1]
#[1,] -0.05701754
#[2,] -0.39035088

### 2. Estimate σ2. Gibson had repression scores for all the states. He had 
### mass tolerance scores for 36 states and elite tolerance scores for 26 states. 
### You may assume the correlations are based on 36 states—this will understate the 
### SEs, by a bit—but you need to decide if p is 2 or 3.
# p = 3, for standardized variables, intercept is hidden
beta1_hat=beta_hat[1]
beta2_hat=beta_hat[2]
var_hat=(N_M/(N_M-3))*(1-(beta1_hat^2+beta2_hat^2+2*beta1_hat*beta2_hat*cor_ME))
#> var_hat
#[1] 0.8958852

### 3. Compute SEs for the estimates.
# Estimate covariance of beta hat given X
cov_betaHat=var_hat * solve(tXX)

beta1_SE=sqrt(cov_betaHat[1,1])
beta2_SE=sqrt(cov_betaHat[2,2])

### 4. Compute the SE for the difference of the two path coefficients. You will need 
### the off-diagonal element of the covariance matrix: see exercise 4B14(a). 
### Comment on the result.

# var(beta1_hat-beta2_hat|X)=var(beta1_hat|X)+var(beta2_hat|X)-2*cov(beta1_hat,beta2_hat|X)
var_betadiff=cov_betaHat[1,1]+cov_betaHat[2,2]-2*cov_betaHat[1,2]
SE_betadiff=sqrt(var_betadiff)

#### Comment: ####
# The standard deviation of the difference of the two parameters is bigger than the 
# the standard deviation of one single parameter.

#### Part 2: More with the same path model ####

### 1. Reproduce the hypothesis tests done by Gibson to show that the -0.35 in his 
### path diagram (page 88) is highly significant (p < 0.01) but that the -0.06 is not. 
### However, do it unweighted as Freedman argues he should have done on page 90.

# hypothesis testing for two coefficient using t-test
# For beta1, H0: beta1=0, two-sided alternative
t1=beta1_hat/beta1_SE
p_value1=2*pt(t1,df=N_M-3,lower.tail=TRUE)
#> p_value1
#[1] 0.7594691

# For beta2, H0: beta2=0, two-sided alternative
t2=beta2_hat/beta2_SE
p_value2=2*pt(t2,df=N_M-3,lower.tail=TRUE)
#> p_value2
#[1] 0.04219431

#### Comment on the result ####
# If the level of significance is 0.05, then beta1 is not significant. Therefore, we 
# will not reject the null hypothesis. Beta2 is significant, so we will reject the null
# hypothesis. The significance is a little different from the paper probably due to
# the different method of estimating betas.

### 2. Do the hypothesis test with the null that (β2 − beta1) = 0, discussed on pages
### 89-90.

tdiff=(beta2_hat-beta1_hat)/SE_betadiff
p_valuediff=2*pt(tdiff,df=N_M-3,lower.tail=TRUE)
#> p_valuediff
#[1] 0.3081186
#### Comment on the result ####
# The p-value shows that the result is not significant. Therefore, we will not reject
# the null hypothesis. That being said, we don't have strong evidence to show that 
# beta1 and beta2 are different.

### 3. Comment on the validity of these hypothesis tests and what conclusions can be
### drawn from them. (I know this is open-ended, please write 2-3 sentences about 
### each situation describing issues and conclusions.)

#### Comment  ####
# There are problems from the very fundamental set-up of the model.
# First, the way that we construct the path model assumes that there is causality 
# between mass tolerance and repression, and between elite tolerance and repression.
# However, why does this assumption holds. Also, why is the relationship linear? 
# Second, why are coefficients the same for all the states? Why are states 
# statistically independent?
# If we just look at the hypothesis test results above. beta1 is not significant. Beta2
# is significant. However, the test of difference shows that there is no strong
# evidence to declare that beta1 and beta2 are different. Then, there is an inconsistency
# between the hypothesis tests.