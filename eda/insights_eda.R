library(tidyverse)
library(feather)


data_lending <- read_csv("../inputs/loan.csv",
                         col_types = cols(
                           id = col_integer(),
                           member_id = col_integer(),
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
                           total_rev_hi_lim = col_character(),
                           inq_fi = col_character(),
                           total_cu_tl = col_character(),
                           inq_last_12m = col_character()
                         ))


# Target analysis
data_lending %>% 
  count(loan_status)


train_lending <- data_lending %>% 
  filter(loan_status %in% c("Charged Off", "Fully Paid"))

train_lending %>% 
  map_int(~ length(unique(.x))) %>% 
  data_frame("Feature" = names(.),
             "Unique_count" = .) %>% 
  mutate(Unique_ratio = Unique_count / nrow(train_lending),
         Unique_approx_ratio = round(Unique_ratio, digits=3)) %>% 
  arrange(desc(Unique_ratio)) %>% 
  View()


unique_frame <- train_lending %>% 
  map_int(~ length(unique(.x))) %>% 
  data_frame("Feature" = names(.),
             "Unique_count" = .) %>% 
  mutate(Unique_ratio = Unique_count / nrow(train_lending),
         Unique_approx_ratio = round(Unique_ratio, digits=3)) %>% 
  arrange(desc(Unique_ratio)) %>% 
  mutate(type = map_chr(~ ))

train_lending %>% 
  ggplot(aes(x = loan_amnt)) +
  geom_histogram(bins = 20)


train_lending %>% 
  ggplot(aes(x = loan_amnt)) +
  geom_density()

train_lending %>% 
  ggplot(aes(x = loan_amnt)) +
  geom_histogram() +
  geom_density()

# Histogram same scale as density : HOW TO ?

train_lending %>% 
  ggplot(aes(x = loan_status, y = loan_amnt)) +
  geom_boxplot()

train_lending %>% 
  group_by(loan_status) %>% 
  summarise(mean(loan_amnt))

train_lending %>% 
  ggplot(aes(x = loan_amnt, colour = loan_status)) +
  geom_density()

train_lending <- train_lending %>% 
  filter(loan_amnt == funded_amnt)

train_lending %>% 
  filter(funded_amnt > funded_amnt_inv)

train_lending %>% 
  mutate(has_funded_diff = as.integer((funded_amnt - funded_amnt_inv) > 0))


