library(sf)

gdb4 <- "./DATA/tree_canopy.gdb"
st_layers(gdb4)
layers <- st_layers(gdb4)
layers

canopy <- st_read(gdb4, "canopy_class_2014_metro")
capacity2 <- st_read(gdb4, "bli_capacity_v2")
bli_constraints2 <- st_read(gdb4, "bli_constraints_v2_pts_run4")

treejoint <- st_join(testjoint4, canopy)
