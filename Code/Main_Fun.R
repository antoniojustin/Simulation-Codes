source(Sim_functions.R)
source(Helper.R)

Simulation = function(patients_num = 1000, B = 100, hosp_coef_1, hosp_coef_2, ...){

  # check for coefficients input
  ls = list(...)
  len = length(ls)
  var_names = names(ls)
  beta_1 = c(-1,hosp_coef_1, unlist(ls, use.names = FALSE))
  beta_2 = c(-1,hosp_coef_2, unlist(ls, use.names = FALSE))
  
  # logistic part
  # test accuracy
  one_part_logi_full= 0
  two_part_logi_full = 0
  # coefficeints
  one_part_logi_coef_full = matrix(, nrow = B, ncol = len + 2)
  two_part_logi_coef_1_full = matrix(, nrow = B, ncol = len + 2)
  two_part_logi_coef_2_full = matrix(, nrow = B, ncol = len + 2)
  # cost metrics
  one_part_l_entro_full = 0
  two_part_l_entro_full = 0
  one_part_l_br_full = 0
  two_part_l_br_full = 0
  
  # XGB part
  one_part_xgb_full = 0
  two_part_xgb_full = 0
  one_part_xgb_train_full = 0
  two_part_xgb_train_1_full = 0
  two_part_xgb_train_2_full = 0
  # cost metrics
  one_part_x_entro_full = 0
  two_part_x_entro_full = 0
  one_part_x_br_full = 0
  two_part_x_br_full = 0
  
  # average death counts
  death_1_full = 0
  death_2_full = 0

  for (i in 1:B){
    
    # construct datamatrix 
    mx = cbind(rep(1, patients_num), 
               rbinom(patients_num, 1, 0.5),
               matrix(runif (patients_num * len , -1, 1), nrow = patients_num,ncol = len))
    colnames(mx) = c("intercept", "hospitalization", var_names)
    
    z1 = mx %*% beta_1
    pr1 = 1/(1 + exp(-z1))
    # simulate stage 1
    y_1 = rbinom(1000, 1, pr1)
    y_2 = y_1
    vac = sum(y_1 == 0)
    mx2 = mx[y_1 == 0,]
    z2 = mx2 %*% beta_2
    pr2 = 1/(1 + exp(-z2))
    # simulate stage 2
    y_2[y_2 == 0] = rbinom(vac, 1, pr2)
    # remove intercept
    df = data.frame(cbind(mx[,-1], y_1, y_2))

    k = logistic_auc(df)
    l = xgb_auc(df)
    
    # test auc
    one_part_logi_full[i] = k[[1]][1]
    two_part_logi_full[i] = k[[1]][2]
    one_part_xgb_full[i] = l[1]
    two_part_xgb_full[i] = l[2]
    # coefficients
    one_part_logi_coef_full[i,] = k[[2]]
    two_part_logi_coef_1_full[i,] = k[[3]]
    two_part_logi_coef_2_full[i,] = k[[4]]
    # death counts
    death_1_full[i] = k[[5]][1]
    death_2_full[i] = k[[5]][2]
    # cost metrics
    one_part_l_entro_full[i] = k[[6]][1]
    two_part_l_entro_full[i] = k[[6]][2]
    one_part_l_br_full[i] = k[[6]][3]
    two_part_l_br_full[i] =k[[6]][4]
    one_part_x_entro_full[i] = l[6]
    two_part_x_entro_full[i] = l[7]
    one_part_x_br_full[i] = l[8]
    two_part_x_br_full[i] = l[9]
    
    # track progress
    if (i %% 100 == 0){
      print(j)
    }
  }

# test auc
AUCs = c(mean(one_part_logi_full), 
         mean(two_part_logi_full),
         mean(one_part_xgb_full),
         mean(two_part_xgb_full))
# coefficeints
Coefs = rbind(colMeans(one_part_logi_coef_full),
              colMeans(two_part_logi_coef_1_full),
              colMeans(two_part_logi_coef_2_full))
colnames(Coefs) = c("intercept", "hospitalization", var_names)

# average death counts
death_counts = c(mean(death_1_full), mean(death_2_full))

# cost metrics
CM_logi = c(mean(one_part_l_entro_full),
            mean(two_part_l_entro_full),
            mean(one_part_l_br_full),
            mean(two_part_l_br_full))
CM_XGB = c(mean(one_part_x_entro_full),
           mean(two_part_x_entro_full),
           mean(one_part_x_br_full),
           mean(two_part_x_br_full))

return(named.list(AUCs, Coefs, death_counts, CM_logi, CM_XGB))
}
