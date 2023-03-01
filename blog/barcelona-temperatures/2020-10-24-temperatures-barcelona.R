#### 2020-10-24-temperatures-barcelona #########################################

#### set up ####################################################################

# load packages
library(tidyverse)
library(lubridate)
library(rstan)
library(tidybayes)
library(loo)
library(janitor)
library(ggdist)
library(patchwork)
library(here)

# set params
setwd(here("content", "posts", "2020-10-24-temperatures-barcelona"))
set.seed(888)
options(mc.cores=parallel::detectCores())
rstan_options(javascript = FALSE)

#### import data ###############################################################
dat <- read.csv("temperatures.csv", encoding = "UTF-8") %>% 
  as_tibble() %>% 
  clean_names() %>% 
  rename(year = any, month = mes, month_cat = desc_mes, temp = temperatura) %>% 
  mutate(date = as_date(paste(year, month, "01", sep = "/")),
         year1 = poly(year, 2)[,1],
         year2 = poly(year, 2)[,2],
         month = factor(month,
                        levels = 1:12,
                        labels = c("Gener", "Febrer", "Març", "Abril",
                                   "Maig", "Juny", "Juliol", "Agost",
                                   "Setembre", "Octubre", "Novembre", "Decembre"),
                        ordered = TRUE))

#### explore data ##############################################################

plot1 <- dat %>%
  group_by(year) %>% 
  summarise(mean_temp = mean(temp, na.rm = TRUE), .groups = "drop") %>% 
  ggplot(aes(year, mean_temp, colour = year)) +
  geom_line() +
  labs(x = "Year", y = "Mean temperature (Cº)", colour = "Year") 
  
  plot2 <- dat %>%
  ggplot(aes(month, temp, colour = year, group = year)) +
  geom_line(alpha = 0.5) +
  labs(x = "Year", y = "Temperature (Cº)", colour = "Year")

plot3 <- ggplot(dat, aes(year, temp, colour = year)) +
  facet_wrap(~month, ncol = 2, scales = "free") +
  geom_point() +
  geom_text(aes(x = Inf, y = Inf, hjust = 1.5, vjust = 1.5, label = month), colour = "black") +
  geom_smooth(colour = "black") +
  labs(x = "Year", y = "Temperature (Cº)", colour = "Year") 
  
  ((plot1 / plot2)| plot3) +
  plot_layout(guides = "collect") &
  scale_colour_gradient(low = "yellow", high ="red") &
  theme_minimal() &
  theme(axis.title = element_text(face = "bold"),
        legend.position = "left",
        strip.text = element_blank(),
        legend.title = element_text(face = "bold"))

#### fit models ################################################################
X <- unname(model.matrix(~1+year1+year2, dat))

dat_stan <- list(N = nrow(dat),
                 P = ncol(X),
                 n_u = ncol(X),
                 X = X,
                 Z_u = X,
                 J = length(levels(dat$month)),
                 y = dat$temp,
                 month = as.integer(dat$month))

fit <- stan("fit1.stan", dat = dat_stan, iter = 2000, sample_file = "draws")

print(fit1, pars = c("beta", "sigma", "sigma_u"), probs = 0.025, 0.5, 0.975)

p_fix <- gather_draws(fit1, `beta.*`, regex = TRUE)
ggplot(p_fix, aes(.value, fill = .variable)) +
  facet_wrap(~.variable, scales = "free") +
  stat_halfeye() +
  labs(x = "Value", y = "Posterior probability") +
  scale_y_continuous(limits = c(0, 1)) +
  theme_minimal() +
  theme(axis.title = element_text(face = "bold"),
        legend.position = "none")

ggplot(p_fixed, aes(.iteration, .value, colour = .chain)) +
  facet_wrap(~.variable, ncol = 2, scales = "free") +
  geom_line() +
  labs(x = "Iteration", y = "Value") +
  theme_minimal() +
  theme(axis.title = element_text(face = "bold"),
        legend.position = "none")

p_ran <- gather_draws(fit1, u[month,])
p_cor <- gather_draws(fit1, L_u[month,]) 

ggplot(p_ran, aes(month, .value)) +
  facet_wrap(~.variable, scales = "free") +
  stat_halfeye() +
  labs(x = "Month", y = "Temperature (Cº)") +
  theme_minimal() +
  theme(axis.title = element_text(face = "bold"),
        legend.position = "none")

p_ran_wide <- p_ran %>% 
  group_by(month, .variable) %>% 
  mean_qi() %>% 
  select(month, .variable, .value, .lower, .upper) %>% 
  mutate(.variable = paste0("beta[", .variable, "]")) %>% 
  pivot_wider(names_from = ".variable", values_from = c(".value", ".lower", ".upper")) %>% 
  clean_names()

ggplot(p_ran_wide, aes(`.value[1]`, `temp_beta[2]`,
                       xmin = `temp.lower_beta[1]`, xmax = `temp.upper_beta[1]`,
                       ymin = `temp.lower_beta[2]`, ymax = `temp.upper_beta[2]`)) +
  geom_point(colour = "orange") +
  geom_errorbar(width = 0, colour = "orange") +
  geom_errorbarh(height = 0, colour = "orange") +
  geom_smooth(method = "lm", formula = "y~x", colour = "black", fullrange = TRUE) +
  labs(x = "beta[1]", y = "beta[2]") +
  
  ggplot(p_ran_wide, aes(`temp_beta[1]`, `temp_beta[3]`,
                         xmin = `temp.lower_beta[1]`, xmax = `temp.upper_beta[1]`,
                         ymin = `temp.lower_beta[3]`, ymax = `temp.upper_beta[3]`)) +
  geom_point(colour = "orange") +
  geom_errorbar(width = 0, colour = "orange") +
  geom_errorbarh(height = 0, colour = "orange") +
  geom_smooth(method = "lm", formula = "y~x", colour = "black", fullrange = TRUE) +
  
  labs(x = "beta[1]", y = "beta[3]") +
  
  ggplot(p_ran_wide, aes(`temp_beta[2]`, `temp_beta[3]`,
                         xmin = `temp.lower_beta[2]`, xmax = `temp.upper_beta[2]`,
                         ymin = `temp.lower_beta[3]`, ymax = `temp.upper_beta[3]`)) +
  geom_point(colour = "orange") +
  geom_errorbar(width = 0, colour = "orange") +
  geom_errorbarh(height = 0, colour = "orange") +
  geom_smooth(method = "lm", formula = "y~x", colour = "black", fullrange = TRUE) +
  
  labs(x = "beta[2]", y = "beta[3]") +
  
  guide_area() +
  plot_layout(ncol = 2) &
  theme_minimal() &
  theme(axis.title = element_text(face = "bold"))

p_fix %>% 
  pivot_wider(names_from = ".variable", values_from = ".value") %>% 
  ggplot(aes(`beta[1]`, `beta[2]`)) +
  stat_density_2d_filled() +
  
  p_fix %>% 
  pivot_wider(names_from = ".variable", values_from = ".value") %>% 
  ggplot(aes(`beta[1]`, `beta[3]`)) +
  stat_density_2d_filled() +
  
  p_fix %>% 
  pivot_wider(names_from = ".variable", values_from = ".value") %>% 
  ggplot(aes(`beta[2]`, `beta[3]`)) +
  stat_density_2d_filled() +
  
  guide_area() +
  plot_layout(ncol = 2, guides = "collect") &
  theme_minimal() &
  theme(legend.position = "none",
        panel.grid = element_blank(),
        axis.title = element_text(face = "bold"))





####

log_lik0 <- extract_log_lik(fit0, merge_chains = TRUE)

loo0 <- loo(log_lik0, r_eff = NA)

print(fit0, pars = c("alpha", "sigma", "lp__"), probs = c(0.025, 0.975))

priors <- c(prior(normal(10, 5), class = "Intercept"),
            prior(exponential(2), class = "sigma"),
            prior(normal(0, 1), class = "b"),
            prior(exponential(2), "sd"),
            prior(lkj(2), class = "cor"))

print(fit1)
#### compare models ############################################################
comparisons <- loo_compare(loo(fit0), loo(fit1), loo(fit2), loo(fit3))

#### examine posterior #########################################################
posterior_fixed <- gather_draws(fit3, b_Intercept, b_any1, b_any2, sigma)
ggplot(posterior_fixed, aes(.value, fill = .variable)) +
  facet_wrap(~.variable, scales = "free_x") +
  geom_histogram(bins = 30) +
  stat_pointinterval(aes(y = 10)) +
  labs(x = "Value", y = "Count") +
  theme_minimal() +
  theme(axis.title = element_text(face = "bold"),
        legend.position = "none") 

posterior_random <- gather_draws(fit3, r_mes[mes, param]) %>% 
  mutate(mes = as.factor(mes))
ggplot(posterior_random, aes(.value, mes, colour = mes, fill = mes)) +
  facet_wrap(~param, scales = "free") +
  stat_slab() +
  stat_pointinterval(colour = "black") +
  labs(x = "Value", y = "Mes") +
  theme_minimal() +
  theme(axis.title = element_text(face = "bold"),
        legend.position = "none") 

#### posterior predictions #####################################################
posterior_preds <- expand.grid(any1 = seq(min(dat$any1), max(dat$any1), by = 0.25),
                               any2 = seq(min(dat$any2), max(dat$any2), by = 0.25),
                               mes = unique(dat$mes)) %>% 
  add_fitted_draws(fit3, n = 10) %>% 
  ungroup() %>% 
  left_join(select(dat, any, mes, temperatura) 
            mutate(intercept = fixef(fit3)$Estimate[1])
            rowwise(y = fixef(fit3)[1,1] + any2)
            ggplot(posterior_preds, aes(any1, .value, colour = any1, group = interaction(any2, .draw))) +
              facet_wrap(~mes) +
              geom_point(size = 0.1)
            
            
            
            
            
            
            