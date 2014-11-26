###  HW 2   Your Name:Xiangyu Hu
##########################################
###  Part 1.We will be using weight and bmi to predict height.  
###(Bmi is body mass index, commonly used to measure obesity.)  
###Using matrix algebra, create betahat and residuals, the vectors of 
###linear model coefficients and residuals, respectively.  
###Include an intercept term, so betahat should be a vector of length 3.

## Predicting height using weight and bmi
h=family[,4]
w=family[,5]
bmi=family[,6]

int=rep(1,length(h))
# creating design matrix X
X=cbind(int,w,bmi)
X_t=t(X)
# Calculating betahat
betahat=solve(X_t%*%X)%*%X_t%*%h
# Calculating residuals
residuals=h-X%*%betahat

###################################################
###  Part2) Plot height and weight as you did in HW 1, including the 
### regression line you found in HW 1.  Make the size of the points proportional to bmi 
### (seems appropriate).  Comment on the pattern you observe in the sizes of 
### the points and how this relates to the sign of the coefficient for bmi.  

out=lm(h~w)
# rescale bmi in order to be used by cex in plot
min_bmi=min(bmi)
max_bmi=max(bmi)
slope=10/(max_bmi-min_bmi)
intercept=10-slope*max_bmi
bmi_rescale=slope*bmi+intercept

plot(h~w,cex=bmi_rescale, xlab="weight", ylab="height",
     main="height~weight plot,BMI is proportional to the size of the circle ")
abline(out)

# Comment: Given that weight is fixed, e.g. circles at w=120, the cricle becomes
# bigger as height goes down. The coefficient for bmi is negative, which implies
# such pattern. bmi and height are negatively correlated.
#########################################################
###  Part3) Make a 3D plot and plot the regression plane through it 
###(x=weight, y=bmi, z=height).  You¡¯ll need the rgl package (you can 
###install it using the Packages tab in the lower right corner of RStudio,
### click on Install Packages, and type in rgl).  Use the functions 
###plot3d() and planes3d().
require(rgl)
plot3d(w,bmi,h, xlab="weight",ylab="bmi",zlab="height",
       main="3D plot")

planes3d(betahat["w",],betahat["bmi",],-1,betahat["int",],
         alpha=0.5,col="plum2")
##########################################################
###  Part4) Using the results of problem Ch 3 B17, and matrix algebra, 
###find the coefficients that you found in 1).  You don¡¯t have to do the 
###book problem, you can just use the results.

# M is the matrix that includes intercept and weight
# regress h on M
M=cbind(int,w)
M_t=t(M)
gammahat1=solve(M_t%*%M)%*%M_t%*%h
f=h-M%*%gammahat1

# N is the matrix of bmi, regress N on M
N=bmi
gammahat2=solve(M_t%*%M)%*%M_t%*%N
g=N-M%*%gammahat2

# regress f on g
g_t=t(g)
gammahat3=solve(g_t%*%g)%*%g_t%*%f

betahat2=rbind(gammahat1-gammahat2%*%gammahat3,gammahat3)

