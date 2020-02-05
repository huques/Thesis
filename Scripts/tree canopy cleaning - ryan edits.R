library(sf)

gdb4 <- "./DATA/tree_canopy.gdb"
st_layers(gdb4)
layers <- st_layers(gdb4)
layers

canopy <- st_read(gdb4, "canopy_class_2014_metro")
capacity2 <- st_read(gdb4, "bli_capacity_v2")
bli_constraints2 <- st_read(gdb4, "bli_constraints_v2_pts_run4")

treejoint <- st_join(testjoint4, canopy)

st_geometry(taxlots_pruned)

lot_geometries <- taxlots_pruned %>%
  select(STATE_ID)

canopy %<>%
  lwgeom::st_make_valid()

can_intersect <- st_intersection(lot_geometries[1:10,], canopy)
