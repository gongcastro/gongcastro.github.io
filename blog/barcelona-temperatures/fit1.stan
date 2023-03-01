// 2020-10-24-temperatures-barcelona
// Quadratuc varying intercepts and slopes model

data {
  int<lower=0> N; // number of observations
  int<lower=0> P; // number of fixed effects
  int<lower=0,upper=12> J; // number of months
  int<lower=0> n_u; // number random effects
  int<lower=1,upper=12> month[N]; // month indicator
  row_vector[P] X[N]; // fixed effects design matrix
  row_vector[n_u] Z_u[N]; // random effects design matrix
  real y[N]; // response variable (temperatures)
}

parameters {
  vector[P] beta; // fixed effect coefficients
  cholesky_factor_corr[n_u] L_u; // Cholesky factor of random effects correlation matrix
  vector<lower=0>[n_u] sigma_u; // month random effects SD
  real<lower=0> sigma; // residual SD
  vector[n_u] z_u[J]; // month random effects
}

transformed parameters {
  vector[n_u] u[J]; // month random effects
  {
    matrix[n_u, n_u] Sigma_u; // month random effects covariance matrix
    Sigma_u = diag_pre_multiply(sigma_u, L_u);
    for (j in 1:J){
      u[j] = Sigma_u * z_u[j];
    }
  }
}

model {
  real mu;
  // prior
  L_u ~ lkj_corr_cholesky(2);
  for (j in 1:J){
    z_u[j] ~ normal(0, 1);
  }
  // likelihood
  for (i in 1:N) {
    mu = X[i] * beta + Z_u[i] * u[month[i]];
    y[i] ~ normal(mu, sigma);
  }
}
