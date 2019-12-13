fast.out.of.sample <- function(Jacobiano, th, lm, ts_training, num_points, ...){
  out_of_samp = c()
  coeff = list()
  ### Take the last point in the training set
  new_point = ts_training[nrow(ts_training), ]
  for(j in 1:num_points){
    ### Predict the first point in the training set and then allthe others
    new_point = Testing(Jacobiano$J, Jacobiano$c0, new_point)
    out_of_samp = rbind(out_of_samp, t(new_point))
    ts_training = Add_to_TS(ts_training, t(new_point))
    updated.fit = next.Jacobian(ts_training, TargetList, Embedding, th, lm, alpha)
    Jacobiano$J[length(Jacobiano$J)+1] = updated.fit$J
    Jacobiano$c0 = rbind(Jacobiano$c0, updated.fit$c0)
  }
  return(list(out_of_samp = out_of_samp))
}

