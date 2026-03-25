import numpy as np

# a) Setting up y and X in their respective arrays
y = np.array([
    [1],
    [-1],
    [2],
    [0],
    [4],
    [2],
    [2],
    [0],
    [2]])
print(y)

X = np.array([
    [1, 0, -1],
    [-1, 1, 0],
    [1, 0, 0],
    [0, 1, 0],
    [1, 2, 0],
    [0, 3, 0],
    [0, 0, 1],
    [1, -1, 1],
    [0, 0, 1]])
print(X)

# Calculating X transpose X
XTX = X.T @ X
print(XTX)

# Calculating the inverse of X transpose X
XTY = X.T @ y
print(XTY)

# Calculating the inverse of X transpose X
inv_XTX = np.linalg.inv(XTX)
print(inv_XTX)

# Calculating B using inverse of X transpose X times X transpose Y
b = inv_XTX @ XTY
print(b)

# Calculating the residuals
e = y - (X @ b)
print(e)

# Calculating the variance
N = 9
K = 3
sigmahatsquared = (e.T @ e)/(N-K)
print(sigmahatsquared)

# Setting up the covcariance matrix:
cov = sigmahatsquared * inv_XTX
print(cov)

# Verifying standard errors
se = np.sqrt(sigmahatsquared * np.diagonal(inv_XTX))
print(se)

# Estimating R squared
rsquared = 1 - ((e.T @ e)/( np.sum((y - np.average(y))**2, axis=0)))
print(rsquared)

# Estimating adjusted R squared
N = 9
K = 3
adjustedrsquared = 1 - ((N-1)/(N-K)) * (1-rsquared)
print(adjustedrsquared)


# All of our values match with the values calculated by hand in SAS/reports/Regression and Marginal Effect Practice Report