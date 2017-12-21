#!/bin/bash
roslaunch dxl_armed_turtlebot hsi_color_filter.launch DEFAULT_NAMESPACE:=/camera/depth_registered INPUT:=points FILTER_NAME_SUFFIX:=houjicha h_min:=-36 h_max:=35 s_min:=0 s_max:=70 i_min:=0 i_max:=80
