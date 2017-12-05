#!/bin/bash
roslaunch dxl_armed_turtlebot hsi_color_filter.launch DEFAULT_NAMESPACE:=/camera/depth_registered INPUT:=points FILTER_NAME_SUFFIX:=houjicha h_min:=-20 h_max:=20 s_min:=120 i_min:=50
