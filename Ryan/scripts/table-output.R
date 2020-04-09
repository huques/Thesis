# export tables HOW tf do u export to worddddddd
library(outreg)
library(stargazer)

# OPTION 1: STARGAZER
# cts var sum stats
stargazer::stargazer(sfr.dat %>% select(cts_vars),
                     title="Summary Statistics", 
                     type = "text", digits = 2, out = here("Ryan", "figs", "tables", "cts.txt"))

# counts 
# table <- outreg(OLS, digits = 3L, alpha = c(0.1, 0.05, 0.01), 
#               bracket = c("se"), starred = c("coef"), robust = FALSE, small = TRUE,
#               constlast = FALSE, norepeat = TRUE)


# OPTION 2: OUTREG

  # regression table all 4
outreg::outreg(list(m1, m2, m3, m4), digits = 2L, alpha = c(0.1, 0.05, 0.01),
       bracket = c("se"), starred = c("coef"), robust = TRUE, small = TRUE,
       constlast = FALSE, norepeat = TRUE) %>% 
  kable("latex", booktabs = T) %>% 
  kable_styling(full_width = T)

makeCompTable(constraints, m4, m3)
makeCompTable(control_vars, fe = m4, nofe = m3)

makeCompTable(constraints, nofe = m1.sf, fe = m2.sf) %>% kable() %>% kable_styling()

