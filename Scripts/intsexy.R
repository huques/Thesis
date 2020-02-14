#----------------------
# GDB sent 2/13 via Dropbox
gdb7 <- "./DATA/Intersectionzzz.gdb"


library(sf)

st_layers(gdb7)

intersections <- st_read(gdb7, "IntersectionzShell")

intersects <- intersections %>%
  select(STATE_ID, starts_with("con"), Shape_Area) %>%
  filter(STATE_ID %in% stateids) %>%
  group_by(STATE_ID)

conslist <- intersections %>%
  select(starts_with("con"))
conslist <- as.list(conslist)


getPercentConstraint <- function(dataset, conlist) {
  
  empty <- data.frame[37960, 28]
  connames <- names(conslist)
  print(connames)
      
  for (constraint in connames){
    
    name <- paste0(constraint, "_area")
    print(name)
    empty
    empty[[name]] <- ifelse(constraint == "True", 
                            sum(dataset$Shape_Area, 
                                na.rm = TRUE), 
                            0)
    print(empty[1,])
      } 
  return(empty)
  }


fuck <- getPercentConstraint(intersects, conslist)

-------------------------------------------------------------------
  
  
  for(i in 1:130){
    print(i)
    cola <- paste('col', i, sep= '')
    df[[cola]] <- ifelse(x == i, 1, 0)
  }

connames = names(conslist)

for (constraint in connames){
  print(constraint)
}

intersect_fld100 <- intersects %>%
  mutate(conFld100_area = ifelse(conFld100 == "True", 
                                 sum(Shape_Area, na.rm = TRUE), 0)) %>%
  mutate(percent_cons = )

                      