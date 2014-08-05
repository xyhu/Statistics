### Name: Xiangyu Hu

####### LAB 11 #########
#### 1. Generate 50 IID variables Ui that are uniform on [0, 1]. 
#### Set θ = 25 and Xi = θ Ui /(1 − Ui ). 
theta=25
U=runif(50)
X=theta*U/(1-U)

#### 2. Find the MLE θˆ by numerical maximization.
loglik=function (theta,data){
  n=length(data)
  l=n*log(theta)-2*sum(log(theta+data))
  return (l)
}
# first derivative of log likelihood with respect to theta
d1_loglik=function(theta, data){
  n=length(data)
  d1=n/theta - 2* sum(1/(theta+data))
  return (d1)
}
# Second derivative will be used to check whether it is a min or max
d2_loglik=function(theta, data){
  n=length(data)
  d2= - n*theta^(-2) + 2* sum((theta+data)^(-2))
  return (d2)
}
mle= optimize(loglik, lower=0.00001, upper=40,data=X,maximum=TRUE)$maximum

mle
d1_loglik(mle,X)
d2_loglik(mle,X)

#### 3. Repeat 1000 times.
mle_iter=numeric()
d2=numeric()
for (i in 1:1000){
  U=runif(50)
  X=theta*U/(1-U)
  mle= optimize(loglik, lower=0.00001, upper=40,data=X,maximum=TRUE)$maximum
  if (d2_loglik(mle,X)<0){mle_iter[i]=mle}
  else {print("second derivate is non-negative at ", i)}
  d2[i]=d2_loglik(mle,X)
}
#### 4. Plot a histogram for the 1000 realizations of θˆ.
hist(mle_iter,main=expression(paste("Histogram for the 1000 realizations of ",hat(theta))),
     xlab=expression(paste("mle of ", theta)))
#### 5. Calculate the mean and SD of the 1000 realizations of θˆ. 
mean(mle_iter)
sd(mle_iter)
#### How does the SD compare to 1/√50 · Iθ ? (The Fisher information Iθ is computed in exercise 7A8.) 
finfo=1/(3*theta^2)
1/sqrt(50*finfo)
## The SD of the 1000 realziation of theta hat is very close to the asymptotic SD using
## true fisher information.


#### 6.
# SD from part 5, asymptotic SD using true fisher information.
SD_fi=1/sqrt(50*finfo)
# SD using observed information
SD_oi= sqrt(-1/d2)

t_fi=(mle_iter-theta)/SD_fi
t_oi=(mle_iter-theta)/SD_oi

plot(density(t_fi), col = "blue", lwd=2, main="Comparing two t's")
lines(density(t_oi), col = "red", lwd=2)
legend("topleft",lty=c(1,1),lwd=c(2,2),col=c("blue","red"),c("asymptotic SD","observed info SD"),cex=0.7)
# It seems that asymptotica SD is more like a normal. The right tail of observed  info
# SD makes it a little skewed to the right.

#### 7. What happens to θˆ if you double θ, from 25 to 50? 
#### What about Fisher information? observed information?
theta2=50
mle_iter2=numeric()
d2_2=numeric()
for (i in 1:1000){
  U=runif(50)
  X=theta2*U/(1-U)
  mle= optimize(loglik, lower=0.00001, upper=40,data=X,maximum=TRUE)$maximum
  if (d2_loglik(mle,X)<0){mle_iter2[i]=mle}
  else {print("second derivate is non-negative at ", i)}
  d2_2[i]=d2_loglik(mle,X)
}
# Plot a histogram for the 1000 realizations of θˆ.
hist(mle_iter2,main=expression(paste("Histogram for the 1000 realizations of ",hat(theta))),
     xlab=expression(paste("mle of ", theta, "=50")), xlim=c(0,60))

#######-????_######
# When looking at the histogram, the majority of realizations are around 40. 
# fisher information
finfo2=1/(3*theta2^2)
# observed information
obinfo=-d2_2

50*finfo2
mean(obinfo)
#####????###### the mean of obinfo is a lot bigger than the information

########## LAB 12 #########
# AGE: Codes: 0-89  Age in years; 90  90 years of age or older
# SEX: Codes: 1  Male 2  Female
# RACE: Codes: 1  White 2  Black 3  Amer Indian or Aleut Eskimo 4  Asian or Pacific Islander
age=data12$V1
sex=data12$V2
race=data12$V3
edulevel=data12$V8
status=data12$V9
### redefine levels for age: 16–19 (0), 20–39 (1), 40–64 (2), 65 or above (3).
age[age<=19 & age>=16]=0
age[age<=39 & age>=20]=1
age[age<=64 & age>=40]=2
age[age>=65]=3

### redefine levels for race: white (1), non-white (0).
race[race != 1] = 0

### redefine the categories for education level to: 
### - not a high school graduate (0), 
### - a high school education but no more (1), 
### - more than a high school education (2).
edlevel=edulevel
# Less than 1st grade to 12th grade, no diploma = not a highschool graduate
edlevel[edlevel==31 |edlevel==32 |edlevel==33 |edlevel==34 |edlevel==35 
        |edlevel==36 |edlevel==37 |edlevel==38] = 0
# high school graduate, but no more
edlevel[edlevel== 39] = 1
# Some college but no degree to Doctoral degree = more than a high school education
edlevel[edlevel==40 |edlevel==41 |edlevel==42 |edlevel==43 |edlevel==44 
        |edlevel==45 |edlevel==46] = 2

### redefine the categories for status. The dependent variable Y is 1 if the person 
### is employed and at work (LABSTAT is 1). Otherwise, Y = 0.
status[status!= 1]=0

# For the baseline individual in the model, choose a person who is 
# male, non- white, age 16–19, and did not graduate from high school
# That is being said these should be level "0"(the first level, since if we factorize
# the variable, the first level will be considered as baseline level)

# factorize variables
age.f=as.factor(age)
sex.f=as.factor(sex)
edlevel.f=as.factor(edlevel)
race.f=as.factor(race)
status.f=as.factor(status)

### 1. What is the size of the design matrix?
### Answer: 4 * 13803 (4 variables, with 13803 obs)

### 2. fit the model, report the parameter estimates
model=glm(status.f~age.f+sex.f+edlevel.f+race.f, family="binomial")
summary(model)
# from the summary table, we can see that all the coefficients are significant

model$coefficient
# (Intercept)      age.f1      age.f2      age.f3      sex.f2  edlevel.f1  edlevel.f2 
#-0.7614540   1.3288752   1.2365194  -1.6668978  -0.7175275   0.7370485   0.9931833 
#race.f2 
#0.1826527 

### 3. Estimate the SEs; use observed information.#####
SE=out$coefficients[,2]
# > SE
#(Intercept)      age.f1      age.f2      age.f3      sex.f2  edlevel.f1  edlevel.f2 
#0.08051629  0.07486672  0.07562729  0.10143142  0.04088345  0.05657165  0.05066913 
#race.f1 
#0.05034075 

# Using observed information to calculate SE. SE=sqrt(1/(-L"(beta_hat)))
# L"(beta) = second partial derivative of log-likelihood w.r.t each beta
# Ln = - sum(log(1+exp(xi*beta))) + sum(xi*yi)*beta



### 4. What does the model say about employment?
lambda=function(x){
  exp(x)/(1+exp(x))
}
# If holding other things constant, then a person who ages between 20 and 39 has a higher
# chance (lambda(1.3288752*xi) more in probability) of employment compared to the 
# baseline (age: 16-19). 

# If holding other things constant, then a person who ages between 40 and 64 has a higher
# chance (lambda(1.2365194*xi) more in probability) of employment compared to the 
# baseline (age: 16-19). However, this chance is not as big as that of those who ages
# between 20 and 39.

# If holding other things constant, then a person who is at least 65 years old has a
# lower chance (lambda(-1.6668978*xi) more in probability) of employment compared to the 
# baseline (age: 16-19).

# If holding other things constant, a woman is less likely to be employed, with a 
# chance of lambda(-0.7175275*xi) lower.

# If holding other things constant, then a person who only has HS diploma has a higher
# chance (lambda(0.7370485*xi) more in probability) of employment compared to the 
# baseline (no HS degree)

# If holding other things constant, then a person who has more than a high school 
# education has a higher chance (lambda(0.9931833*xi) more in probability) of 
# employment compared to the baseline (no HS degree)

# If holding other things constant, then a person who is white has a higher chance 
# (lambda(0.1826527*xi) higher in probability) of employment compared to the 
# baseline (non-white)



### 5. Why use dummy variables for education, rather than EDLEVEL as a quantitative variable?
# Because in the job market, most of the time, education is considered base upon levels
# such as high school degree, bachelor's, master's, doctorals', instead of quantatitative
# values (e.g. number of years of education). For example, a person with 15yrs(a junior
# if in college) is considered a lot differently with a person with 16yrs(Bachelor's
# if graduated successfully). However, if we fit quantitatively, such effect won't be
# reflected in the model, and may also cause problems for our model.


### 6. For discussion. Why might women be less likely to have LABSTAT = 1? Are LABSTAT codes over 4 relevant to this issue?
# There are many reasons for this. 1) women may have lower education level compared
# to men, which will affect their competitivenes during job hunting. 2) At job market,
# even though there is regulation requiring non-discrimination based on sex, there are
# many jobs that are not women friendly (e.g. construction worker), or in other words
# most women tend not to choose these kinds of jobs. It results that women have less
# job opportunities to choose from compared to men, thus be less likely to be employed.
# 3) Codes over 4 is relevant(e.g. retirement, others). It is widely known that women
# tend to live longer. That being said, among those who are retired, there might be a 
# lot more women than men. Also, a lot of women choose to be housewives after they get
# married, which are probably classified as others(code 7).







