packages <- c("tidyverse", "stringr", "tidytext", "fiftystater",
              "data.table", "DescTools", "wordcloud", "lubridate",
              "RColorBrewer", "maps", "corrplot", "mapproj",
              "Rttf2pt1","xlsx", "broom", "dxcrmd", "devtools",
              "randomForest", "ranger", "glmnet", "caret", "tidyverse")


for (package in packages) {
  if (!require(package, character.only=T, quietly=T)) {
    install.packages(package, dependencies = TRUE,
                     repos = "https://cran.rstudio.com/")
    library(package, character.only=T)
  } else {
    library(package, character.only=T)
  }
}

# Read Data
data_lending <- read_csv("../inputs/loan.csv",
                         col_types = cols(
                           id = col_character(),
                           member_id = col_character(),
                           loan_amnt = col_double(),
                           funded_amnt = col_double(),
                           funded_amnt_inv = col_double(),
                           term = col_character(),
                           int_rate = col_double(),
                           installment = col_double(),
                           grade = col_character(),
                           sub_grade = col_character(),
                           emp_title = col_character(),
                           emp_length = col_character(),
                           home_ownership = col_character(),
                           annual_inc = col_double(),
                           verification_status = col_character(),
                           issue_d = col_character(),
                           loan_status = col_character(),
                           pymnt_plan = col_character(),
                           url = col_character(),
                           desc = col_character(),
                           purpose = col_character(),
                           title = col_character(),
                           zip_code = col_character(),
                           addr_state = col_character(),
                           dti = col_double(),
                           delinq_2yrs = col_double(),
                           earliest_cr_line = col_character(),
                           inq_last_6mths = col_double(),
                           mths_since_last_delinq = col_double(),
                           mths_since_last_record = col_double(),
                           open_acc = col_double(),
                           pub_rec = col_double(),
                           revol_bal = col_double(),
                           revol_util = col_double(),
                           total_acc = col_double(),
                           initial_list_status = col_character(),
                           out_prncp = col_double(),
                           out_prncp_inv = col_double(),
                           total_pymnt = col_double(),
                           total_pymnt_inv = col_double(),
                           total_rec_prncp = col_double(),
                           total_rec_int = col_double(),
                           total_rec_late_fee = col_double(),
                           recoveries = col_double(),
                           collection_recovery_fee = col_double(),
                           last_pymnt_d = col_character(),
                           last_pymnt_amnt = col_double(),
                           next_pymnt_d = col_character(),
                           last_credit_pull_d = col_character(),
                           collections_12_mths_ex_med = col_double(),
                           mths_since_last_major_derog = col_character(),
                           policy_code = col_double(),
                           application_type = col_character(),
                           annual_inc_joint = col_character(),
                           dti_joint = col_character(),
                           verification_status_joint = col_character(),
                           acc_now_delinq = col_double(),
                           tot_coll_amt = col_character(),
                           tot_cur_bal = col_character(),
                           open_acc_6m = col_character(),
                           open_il_6m = col_character(),
                           open_il_12m = col_character(),
                           open_il_24m = col_character(),
                           mths_since_rcnt_il = col_character(),
                           total_bal_il = col_character(),
                           il_util = col_character(),
                           open_rv_12m = col_character(),
                           open_rv_24m = col_character(),
                           max_bal_bc = col_character(),
                           all_util = col_character(),
                           total_rev_hi_lim = col_double(),
                           inq_fi = col_character(),
                           total_cu_tl = col_character(),
                           inq_last_12m = col_character()
                         ))

# Delete columns with more than 70% of missing values

missing_table <-  data_lending %>% 
  map_dbl(~ round(sum(is.na(.x))/length(.x), digits=2)) %>%
  data_frame(name=names(.), proportion=.) 

delete_missing <- missing_table %>% 
  filter(proportion>0.7) %>%
  select(name) %>% 
  unlist()

# Delete columns with more than 70 percents of missing values

data_lending_deleted_missing <- data_lending %>%
  select_if( !(colnames(data_lending)
               %in% delete_missing))


# Delete columns with more than 70 percents of missing values

data_lending_deleted_missing <- data_lending %>%
  select_if( !(colnames(data_lending)
               %in% delete_missing))


# Feature cleaning

# Function to extract numbers (tbd)

#extract numbers from term
data_clean <- data_lending_deleted_missing %>%
  mutate(term= as.numeric(str_extract_all
                          (term, "[[:digit:]]+")))

#extract numbers from employment length
data_clean <- data_clean %>%
  mutate(emp_length= as.numeric(str_extract_all
                                (emp_length, "[[:digit:]]+")))

#Binary Verification Status
data_clean <- data_clean %>%
  mutate(verification_status= ifelse
         (verification_status=="Not Verified", 0, 1))

#Issue Date into date format

months_dict <- c("01", "02", "03", "4", "5", "6", "7", "8", "9", "10", "11", "12")
names(months_dict) <- c("Jan", "Feb", "Mar", "Apr", "May",
                        "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")

data_clean <- data_clean %>%
  separate(issue_d, c("m_d", "y_d"), sep = "-") %>%
  mutate(d_d = "01") %>%
  mutate(good_m = months_dict[m_d]) %>%
  unite(issue_d, d_d, good_m, y_d, sep="-") %>%
  mutate(issue_d= dmy(issue_d)) %>%
  select(-m_d)

#Earliest Credit Line into date format

data_clean <- data_clean %>%
  separate(earliest_cr_line, c("m_d", "y_d"), sep = "-") %>%
  mutate(d_d = "01") %>%
  mutate(good_m = months_dict[m_d]) %>%
  unite(earliest_cr_line, d_d, good_m, y_d, sep="-") %>%
  mutate(earliest_cr_line= dmy(earliest_cr_line)) %>%
  select(-m_d)

# Last payment into date format

data_clean <- data_clean %>%
  separate(last_pymnt_d, c("m_d", "y_d"), sep = "-") %>%
  mutate(d_d = "01") %>%
  mutate(good_m = months_dict[m_d]) %>%
  unite(last_pymnt_d, d_d, good_m, y_d, sep="-") %>%
  mutate(last_pymnt_d= dmy(last_pymnt_d)) %>%
  select(-m_d)

# Last Credit Pull into date format

data_clean <- data_clean %>%
  separate(last_credit_pull_d, c("m_d", "y_d"), sep = "-") %>%
  mutate(d_d = "01") %>%
  mutate(good_m = months_dict[m_d]) %>%
  unite(last_credit_pull_d, d_d, good_m, y_d, sep="-") %>%
  mutate(last_credit_pull_d= dmy(last_credit_pull_d)) %>%
  select(-m_d)

# filtering non-individual loans

data_clean <- data_clean %>%
  filter(application_type=="INDIVIDUAL") %>%
  select(-application_type)

# Filtering current and non-finished loans

data_roi_analysis <- data_clean %>%
  filter(loan_status %in% c("Charged Off", "Default", "Fully Paid", "In Grace Period", "Late (16-30 days)", "Late (31-120 days)")) %>%
  filter(term==36 & issue_d<ymd("2012-06-01") | term==60 & issue_d<ymd("2010-06-01")) %>%
  filter(loan_amnt==funded_amnt)

# Filtering loans with 60 terms (as there are very few of them)

data_roi_analysis <- data_roi_analysis %>%
  filter(term==36)


# Adding new features


# Investor theoretical and actual ROI

data_roi <- data_roi_analysis %>% 
  mutate(theo_roi = (installment*term - loan_amnt) / loan_amnt) %>% 
  mutate(real_roi= (total_pymnt - loan_amnt) / loan_amnt)


# Mutate character col into vector
data_complete <- data_roi %>%
  mutate_if(is.character, as.factor) %>%
  mutate(id= as.character(id)) %>%
  mutate(member_id= as.character(member_id))

# Convert Grade and subgrade into numbers

data_complete <- data_complete %>%
  mutate(grade= ifelse(grade=="A", 1, ifelse(grade=="B", 2,
                                        ifelse(grade=="C", 3,
                                          ifelse(grade=="D", 4,
                                            ifelse(grade=="E", 5,
                                              ifelse(grade=="G", 6, 7))))))) %>%
  mutate(sub_grade= as.numeric(sub_grade))

# Dummify all the factor variables


# Check missing values in this new dataset
  
missing_table <-  data_complete %>% 
                 map_dbl(~ round(sum(is.na(.x))/length(.x), digits=2)) %>%
                 data_frame(name=names(.), proportion=.) 

delete_missing <- missing_table %>% 
  filter(proportion>0.6) %>%
  select(name) %>% 
  unlist()

# Delete columns with more than 60 percents of missing values

df_whithout_missing <- data_complete %>%
  select_if( !(colnames(data_complete)
               %in% delete_missing))

  
# Delete variables that incorporates future information
  
model_df <- df_whithout_missing %>% 
            select(-id, -member_id, -url, -funded_amnt, -funded_amnt_inv, -loan_status, 
                   -revol_bal, -revol_util, -out_prncp, -out_prncp_inv, -total_pymnt, 
                   -total_pymnt_inv, -total_rec_prncp, -total_rec_int, 
                   -total_rec_late_fee, -recoveries, -collection_recovery_fee, 
                   -last_pymnt_d, -last_pymnt_amnt, -last_credit_pull_d, -zip_code,
                   -earliest_cr_line,
                   -initial_list_status, -collections_12_mths_ex_med, -policy_code,
                   -acc_now_delinq, 
                   -emp_title, -issue_d, -title, -term
                   )

# Splitting into training and test




inTrain <- createDataPartition(y=model_df$real_roi,
                                  p=0.75,
                                  list = FALSE)

loan_training <- model_df[ inTrain,]
loan_test  <- model_df[-inTrain,]



loan_training_na <- na.omit(loan_training)
loan_test_na <- na.omit(loan_test)

#loan_training_na <- loan_training_na %>% select(-pymnt_plan)


fit_rf <- ranger(real_roi ~ ., data= loan_training_na, mtry = 3, num.trees = 500, write.forest = TRUE, importance = "impurity", min.node.size = 30)

rf_pred <- predict(fit_rf, loan_test_na)

RMSE <- sqrt(mean((loan_test_na$real_roi - rf_pre$predictions)^2))

ranger::importance(fit_rf)

# Penalized regression

#Training into sparse matrix

df_categorical <- loan_training_na %>% select_if(is.factor)

matrix_categorical <- model.matrix(~ . -1, data=df_categorical)
matrix_num <- as.matrix(loan_training_na %>% select_if(is.numeric))

matrix_glm <- cbind(matrix_categorical, matrix_num)

X= matrix_glm[, -84]
Y= matrix_glm[, 84]

# Test into sparse matrix

df_categorical <- loan_test_na %>% select_if(is.factor)

matrix_categorical_test <- model.matrix(~ ., data=df_categorical)
matrix_num_test <- as.matrix(loan_training_na %>% select_if(is.numeric))

matrix_test_glm <- cbind(matrix_categorical, matrix_num)

X_test= matrix_test_glm[, -84]
Y_test= matrix_test_glm[, 84]

fit_glm <- glmnet(x = X, y = Y, alpha = 1, family = "gaussian")
fit_cv_glm <- cv.glmnet(X, Y)

glm_pred <- predict.glmnet(fit_glm, X_test, type = "link", s = 0.0005944404)

print(fit_glm)



split_train_test <- function(df, y, proportion){
  inTrain <- createDataPartition(y = y,
                                 p = proportion,
                                 list = FALSE)
  loan_training <- df[ inTrain,]
  loan_test  <- df[-inTrain,]
  return(loan_training)
  return(loan_test)
}




#Some Ideas

#Length of text zone

#GPR by state

# Loan proportion or installement according to annual income 
