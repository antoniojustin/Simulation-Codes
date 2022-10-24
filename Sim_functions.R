library(pROC)
library(xgboost)
library(dplyr)
library(data.table)
source(helper.R)

logistic_auc = function(df, split = 0.8){
  # train test split
  smp_size <- floor(split * nrow(df))
  train_ind <- sample(seq_len(nrow(df)), size = smp_size)
  train <- df[train_ind, ]
  test <- df[-train_ind, ]
  
  # split into two datasets
  train2 = train[train$y_1 == 0,] 
  train2$y_1 = NULL
  
  # logistic 
  # one part model
  train_one_part = subset(train, select = -y_1)
  l1 = glm(y_2 ~., data = train_one_part, family = "binomial")
  pred_f = predict(l1, newdata = test, type = "response")
  
  # two parts model
  train_two_part = subset(train, select = -y_2)
  l2.1 = glm(y_1 ~., data = train_two_part, family = "binomial")
  l2.2 = glm(y_2 ~., data = train2, family = "binomial")
  pred_1 = predict(l2.1, newdata = test, type = "response")
  pred_2 = predict(l2.2, newdata = test, type = "response")
  pred_combined = pred_1 + pred_2 * (1 -  pred_1)
  
  # 1 parts and 2 parts test AUC
  a = roc(test$y_2, pred_f, quiet = T)
  b = roc(test$y_2, pred_combined, quiet = T)
  
  # 1 parts and 2 parts training AUC
  c = roc(train$y_2, l1$fitted.values, quiet = T)
  d_1 = roc(train$y_1,l2.1$fitted.values, quiet = T)
  d_2 = roc(train2$y_2,l2.2$fitted.values, quiet = T)
  
  # coefficients
  coef_l1 = l1$coefficients
  coef_l2.1 = l2.1$coefficients
  coef_l2.2 = l2.2$coefficients
  
  # average y_1 and y_2 values
  ay1 = sum(df$y_1)/length(df$y_1)
  ay2 = sum(df$y_2)/length(df$y_1)
  
  # loss metrics
  entro1 = entropy_s(test$y_2, pred_f)
  entro2 = entropy_s(test$y_2, pred_combined)
  br1 = brier_s(test$y_2, pred_f)
  br2 = brier_s(test$y_2, pred_combined)
  
  return(list(c(a$auc,b$auc, c$auc, d_1$auc, d_2$auc), 
              coef_l1, coef_l2.1, coef_l2.2, 
              c(ay1, ay2),
              c(entro1, entro2, br1, br2)))
}

xgb_auc = function(df, split = 0.8){
  
  # train test split
  smp_size <- floor(split * nrow(df))
  train_ind <- sample(seq_len(nrow(df)), size = smp_size)
  train <- df[train_ind, ]
  test <- df[-train_ind, ]
  
  # split into two datasets
  train2 = train[train$y_1 == 0,]
  
  param = list(booster = "gbtree",
               objective = "binary:logistic",
               eta = 0.3,
               gamma = 0,
               max_depth = 6,
               min_child_weight = 1,
               subsample = 1,
               colsample_bytree = 1,
               eval_metric = "auc")
  
  ta1 = select(train, -y_2)
  ta2 = select(train2, -y_1)
  taf = select(train, -y_1)
  fe = select(test, -c(y_1, y_2))
  
  # part 1
  setDT(ta1)
  lb1 = ta1$y_1
  tr_1 = model.matrix(~.+0, data = ta1[, -"y_1", with = F])
  tr1 = xgb.DMatrix(data = tr_1, label = lb1)
  
  set.seed(100)
  xgbcv = xgb.cv(params = param, data = tr1, nrounds = 100, nfold = 5, showsd = T, stratified = T, verbose = F, maximize = F)
  k1 = which.max(xgbcv$evaluation_log$test_auc_mean) #multiple then will choose the first one
  set.seed(100)
  xgb1 = xgb.train(params = param,
                   data = tr1,
                   nrounds = k1,
                   maximize = F)
  # train predict
  train_1 = roc(lb1, predict(xgb1, tr1), quiet = T)
  
  
  # part 2
  setDT(ta2)
  lb2 = ta2$y_2
  tr_2 = model.matrix(~.+0, data = ta2[, -"y_2", with = F])
  tr2 = xgb.DMatrix(data = tr_2, label = lb2)
  
  set.seed(100)
  xgbcv = xgb.cv(params = param, data = tr2, nrounds = 100, nfold = 5, showsd = T, stratified = T, verbose = F, maximize = F)
  k2 = which.max(xgbcv$evaluation_log$test_auc_mean) #multiple then will choose the first one
  set.seed(100)
  xgb2 = xgb.train(params = param,
                   data = tr2,
                   nrounds = k2,
                   maximize = F)
  # train predict
  train_2 = roc(lb2, predict(xgb2, tr2), quiet = T)
  
  # full model
  setDT(taf)
  lbf = taf$y_2
  tr_f = model.matrix(~.+0, data = taf[, -"y_2", with = F])
  trf = xgb.DMatrix(data = tr_f, label = lbf)
  
  set.seed(100)
  xgbcv = xgb.cv(params = param, data = trf, nrounds = 100, nfold = 5, showsd = T, stratified = T, verbose = F, maximize = F)
  kf = which.max(xgbcv$evaluation_log$test_auc_mean) #multiple then will choose the first one
  set.seed(100)
  xgbf = xgb.train(params = param,
                   data = trf,
                   nrounds = kf,
                   maximize = F)
  # train predict
  train_f = roc(lbf, predict(xgbf, trf), quiet = T)
  
  # testset
  setDT(fe)
  fe_f = model.matrix(~.+0, data = fe)
  test_f = xgb.DMatrix(data = fe_f, label = test$y_2)
  pre_1 = predict(xgb1, test_f)
  pre_2 = predict(xgb2, test_f)
  pre_f = predict(xgbf, test_f)
  pre_combined = pre_1 + pre_2 * (1 -  pre_1)
  
  a = roc(test$y_2, pre_f, quiet = T)
  b = roc(test$y_2, pre_combined, quiet = T)
  
  # loss metrics
  entro1 = entropy_s(test$y_2, pre_f)
  entro2 = entropy_s(test$y_2, pre_combined)
  br1 = brier_s(test$y_2, pre_f)
  br2 = brier_s(test$y_2, pre_combined)
  
  return(c(a$auc,b$auc, train_1$auc, train_2$auc, train_f$auc,
           c(entro1, entro2, br1, br2)))
}