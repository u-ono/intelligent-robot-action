#!/bin/bash
roslaunch dxl_armed_turtlebot hsi_color_filter.launch DEFAULT_NAMESPACE:=/camera/depth_registered FILTER_NAME_SUFFIX:=ryokuball INPUT:=points h_min:=80 h_max:=127 s_min:=27 s_max:=255 i_min:=100 i_max:=255
