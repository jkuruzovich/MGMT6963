library(caret)
library(plyr)
library(ggplot2)
library(gridExtra)
library(pROC)

load(file = 'train_m.RData')
levels(train_m$requester_received_pizza) = list('fail' = F, 'success' = T)
save(train_m, file = 'train_m.RData')

#need to create another version of the dataset with dummy variables converted into integers
#in order to scale and center the data for neural networks (for regularization)
train_md = train_m
train_md$month_h1 = as.numeric(train_md$month_h1) - 1
train_md$gratitude = as.numeric(train_md$gratitude) - 1
train_md$hyperlink = as.numeric(train_md$hyperlink) - 1
train_md$reciprocity = as.numeric(train_md$reciprocity) - 1
train_md$sentiment_p = as.numeric(train_md$sentiment_p) - 1
train_md$sentiment_n = as.numeric(train_md$sentiment_n) - 1
train_md$posted_before = as.numeric(train_md$posted_before) - 1
save(train_md, file = 'train_md.RData')

set.seed(2014)
train_ind = createDataPartition(train_m$requester_received_pizza, p = .75, list = F)
train_tr = train_m[train_ind, ]
train_te = train_m[-train_ind, ]
train_tr_d = train_md[train_ind, ]
train_te_d = train_md[-train_ind, ]
save(train_tr, file = 'train_tr.RData')
save(train_te, file = 'train_te.RData')
save(train_tr_d, file = 'train_tr_d.RData')
save(train_te_d, file = 'train_te_d.RData')

#train the training set
ind_vars = names(train_tr)[1:length(train_tr)-1]
ctrl = trainControl(method = 'cv', summaryFunction = twoClassSummary, classProbs = T)

#logit (roc = .664)
sink('logit.txt')
set.seed(2014)
logit_m = train(requester_received_pizza ~ ., data = train_tr,
                method = 'glm', metric = 'ROC', trControl = ctrl)
summary(logit_m)
sink()
logit_imp = varImp(logit_m)
save(logit_m, file = 'logit_m.RData')

#random forests (mtry = 2, roc = .656)
rf_tune = expand.grid(.mtry = seq(2, 10))
set.seed(2014)
rf_m = train(x = train_tr[, ind_vars], y = train_tr$requester_received_pizza,
             method = 'rf', ntree = 1000, metric = 'ROC', 
             tuneGrid = rf_tune, trControl = ctrl, importance = T)
rf_imp = varImp(rf_m)
save(rf_m, file = 'rf_m.RData')

#gbm (n.trees = 500, interaction.depth = 3, shrinkage = .01, roc = .68)
gbm_tune = expand.grid(interaction.depth = seq(1, 9, 2),
                       n.trees = seq(500, 2000, 500),
                       shrinkage = c(.01, .1))
set.seed(2014)
gbm_m = train(x = train_tr[, ind_vars], y = train_tr$requester_received_pizza,
              method = 'gbm', tuneGrid = gbm_tune,
              metric = 'ROC', verbose = F, trControl = ctrl)
gbm_imp = varImp(gbm_m)
save(gbm_m, file = 'gbm_m.RData')

#nnet (size = 4, decay = 2, roc = .669)
nnet_tune = expand.grid(size = 1:10, decay = c(0, .1, 1, 2))
set.seed(2014)
nnet_m = train(train_tr_d[, ind_vars], y = train_tr_d$requester_received_pizza,
               method = 'nnet', tuneGrid = nnet_tune,
               metric = 'ROC', preProc = c('center', 'scale'),
               trControl = ctrl)
nnet_imp = varImp(nnet_m)
save(nnet_m, file = 'nnet_m.RData')

#plot resamples
r = resamples(list('Logistic regression' = logit_m, 'Random forest' = rf_m,
                   'Gradient boost tree' = gbm_m, 'Neural networks' = nnet_m))
parallelplot(r)

#plot importance
plot_imp = function(x) {
  df = data.frame(x[[1]])
  names(df) = 'importance'
  df$variable = row.names(df)
  var_order = df$variable[order(df$importance)]
  df$variable = factor(df$variable, levels = var_order)
  
  plot =
    ggplot(df, aes(x = importance, y = variable)) +
    geom_segment(aes(yend = variable), xend = 0, colour = 'grey50') +
    geom_point(size = 3, colour = '#1d91c0') +
    ggtitle(x[[2]]) + theme_bw() + guides(fill = F)
  return(plot)
}

p_logit_imp = plot_imp(logit_imp)
p_rf_imp = plot_imp(rf_imp)
p_gbm_imp = plot_imp(gbm_imp)
p_nnet_imp = plot_imp(nnet_imp)

grid.arrange(p_logit_imp, p_rf_imp, p_gbm_imp, p_nnet_imp, main = 'Variable importance')

#apply to test set
logit_p = predict(logit_m, train_te[, ind_vars], type = 'prob')
rf_p = predict(rf_m, train_te[, ind_vars], type = 'prob')
gbm_p = predict(gbm_m, train_te[, ind_vars], type = 'prob')
nnet_p = predict(nnet_m, train_te_d[, ind_vars], type = 'prob')

#combine results
mean_p = (logit_p$success + rf_p$success + gbm_p$success + nnet_p$success) / 4
roc(train_te$requester_received_pizza, mean_p)
#roc = .6907